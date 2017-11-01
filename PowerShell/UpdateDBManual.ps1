$SdwExe = 'C:\Program Files (x86)\SDW\DeploymentSrvWizard35.exe'
$ComponentsDir = 'D:\Components'
$ConfigDir = 'D:\'
$FtpComponents = '\\FTP\Packed'
$SQLServer = read-host "Enter SQL Server [e.g. sql_server_1]"
$SQLDatabase = read-host "Enter SQL Database [e.g. Database_Test]"

Try {
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = "Data Source=$SQLserver;Initial Catalog=$SQLDatabase;Integrated Security=SSPI;"
    $conn.open()
    $conn.close()
}
Catch {
    $_.Exception.Message
    Break
}
$GlobalVersionDev = Get-ChildItem -Path $FtpComponents | Where-Object name -like 'Dev*' | Sort-Object LastWriteTime -Descending  | Select-Object -first 1 
$GlobalVersionV6111SR = Get-ChildItem -Path $FtpComponents | Where-Object name -like 'V6.11.1*' | Sort-Object LastWriteTime -Descending  | Select-Object -first 1 
$GlobalVersionV6110SR = Get-ChildItem -Path $FtpComponents | Where-Object name -like 'V6.11.0*' | Sort-Object LastWriteTime -Descending  | Select-Object -first 1 
$GlobalVersionV6109SR = Get-ChildItem -Path $FtpComponents | Where-Object name -like 'V6.10.9*' | Sort-Object LastWriteTime -Descending  | Select-Object -first 1 
$GlobalVersionV6108SR = Get-ChildItem -Path $FtpComponents | Where-Object name -like 'V6.10.8*' | Sort-Object LastWriteTime -Descending  | Select-Object -first 1 
$GlobalVersionV697SR = Get-ChildItem -Path $FtpComponents | Where-Object name -like 'V6.9.7*' | Sort-Object LastWriteTime -Descending  | Select-Object -first 1 

do {$SelectVersion = Read-Host `n 1. $GlobalVersionDev created on $GlobalVersionDev.LastWriteTime.ToShortDateString() `n 2. $GlobalVersionV6111SR created on $GlobalVersionV6111SR.LastWriteTime.ToShortDateString() `n 3. $GlobalVersionV6110SR created on $GlobalVersionV6110SR.LastWriteTime.ToShortDateString() `n 4. $GlobalVersionV6109SR created on $GlobalVersionV6109SR.LastWriteTime.ToShortDateString() `n 5. $GlobalVersionV6108SR created on $GlobalVersionV6108SR.LastWriteTime.ToShortDateString() `n 6. $GlobalVersionV697SR created on $GlobalVersionV697SR.LastWriteTime.ToShortDateString() `n 7. Enter custom version `n Choose Global XB Version}
until  (($SelectVersion -match "1") -OR ($SelectVersion -match "2") -OR ($SelectVersion -match "3") -OR ($SelectVersion -match "4") -OR ($SelectVersion -match "5") -OR ($SelectVersion -match "6") -OR ($SelectVersion -match "7"))

switch ($SelectVersion) {
    1 {$GlobalVersion = $GlobalVersionDev.BaseName.Split('()')[1]}
    2 {$GlobalVersion = $GlobalVersionV6111SR.BaseName.Split('()')[1]}
    3 {$GlobalVersion = $GlobalVersionV6110SR.BaseName.Split('()')[1]}
    4 {$GlobalVersion = $GlobalVersionV6109SR.BaseName.Split('()')[1]}
    5 {$GlobalVersion = $GlobalVersionV6108SR.BaseName.Split('()')[1]}
    6 {$GlobalVersion = $GlobalVersionV697SR.BaseName.Split('()')[1]}
    7 {$GlobalVersion = read-host "Enter version of Global XB"}
}

$req = Get-ChildItem -Path $FtpComponents -Name "*$GlobalVersion*"
Write-host "Found archives on SPB FTP: $req"
do {
    $Continue = Read-Host "Continue? [Yes\No]"
} until (($Continue -match "Yes") -OR ($Continue -match "No"))
switch ($Continue) {
    Yes {
        $FolderName = [io.path]::GetFileNameWithoutExtension($req) 
        function Unzip($zipfile, $outdir) {
    
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $archive = [System.IO.Compression.ZipFile]::OpenRead($zipfile)
            foreach ($entry in $archive.Entries | Where-Object {($_.FullName -like 'Database/*') -or ($_.Fullname -like 'Reports/*')}) {
                $entryTargetFilePath = [System.IO.Path]::Combine($outdir, $entry.FullName)
                $entryDir = [System.IO.Path]::GetDirectoryName($entryTargetFilePath)
        
                #Ensure the directory of the archive entry exists
                if (!(Test-Path $entryDir )) {
                    New-Item -ItemType Directory -Path $entryDir | Out-Null 
                }
        
                #If the entry is not a directory entry, then extract entry
                if (!$entryTargetFilePath.EndsWith("\")) {
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $entryTargetFilePath, $true);
                }
            }
        }
        Write-Host "Downloading Components Files"
        Unzip $Ftpcomponents\$req $ComponentsDir\$FolderName
    
        $XMLFile = "$ConfigDir\$SQLServer.xml"
        [xml]$XmlDocument = Get-Content -Path $XmlFile
        $XmlDocument.Deployment.Entity.Database.Name.Value = "$SQLDatabase"
        $XmlDocument.Deployment.Entity.Database.Version.Value = "$GlobalVersion"
        $XmlDocument.Save($XMLFile)
        do {$ReportsUpload = Read-Host "Upload reports? [Yes\No]"} until
        (($ReportsUpload -match "Yes") -OR ($ReportsUpload -match "No"))
        Switch ($ReportsUpload) { 
            Yes
            {(Get-Content $XMLFile).replace('<PathReports CanBeEmpty="0" FileName="IBA Reports.rptproj" Install="0" UseOfflineReportsScript="" Value="\Reports" />', '<PathReports CanBeEmpty="0" FileName="IBA Reports.rptproj" Install="1" UseOfflineReportsScript="" Value="\Reports" />') | Set-Content $XMLFile -Encoding Unicode}
            No
            {(Get-Content $XMLFile).replace('<PathReports CanBeEmpty="0" FileName="IBA Reports.rptproj" Install="1" UseOfflineReportsScript="" Value="\Reports" />', '<PathReports CanBeEmpty="0" FileName="IBA Reports.rptproj" Install="0" UseOfflineReportsScript="" Value="\Reports" />') | Set-Content $XMLFile -Encoding Unicode}
        }
        

        & $SdwExe $XMLFile
    }


    No {
        Write-host "Bye!"
    }
}