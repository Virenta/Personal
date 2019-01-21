$servers = "machine1", "machine2"
$ServicesFile = "D:\services2.htm"
[PSCustomObject[]]$global:output = @()
$head = @'
<Title>Global services Online status</Title>
<style>

body { background-color:#dddddd;
           font-family:Calibri;
	   font-size:12pt; }
td, th { border:1px solid black;
    border-collapse:collapse; }
th { color:white;
           background-color:black; }
           table, tr, td, th { padding: 2px; margin: auto }
table { background-color: white;
    margin: auto;
    max-width:auto;
    padding: 1px
 }
 h2 {
    width: 100%;
    text-align:center;
   }
</style>
'@

function Ammend-ServiceOutput {
    $ItemDetails = [PSCustomObject]@{    
        Server    = $computer
        Service   = $ServiceName
        SQLServer = $SQLServer
        Database  = $Database
        Version   = $version
        Status    = $servicestatus.Status
    }
    #Add data to array
    $global:output += $ItemDetails    
}

#AJGMessaging Service
function Get-Service1 {
    if ( Test-Path "\\$computer\c$\Program Files (x86)\Company\Company Test Service1\Library.dll") {
        $version = (Get-Item "\\$computer\c$\Program Files (x86)\Company\Company Test Service1\Library.dll").VersionInfo.FileVersion
        [xml]$XmlDocument = Get-Content -Path "\\$computer\c$\Program Files (x86)\Company\Company Test Service1\MsgGateAJGConfig.xml"
        $SQLServer = $XmlDocument.MsgGateAJG.Connection.Server 
        $Database = $XmlDocument.MsgGateAJG.Connection.Database 
        $servicestatus = Get-Service -ComputerName $computer | Where Name -like "Service1" 
        $ServiceName = "Service1"
        Ammend-ServiceOutput
    }
}
#AlertSender
function Get-Service2 {
    if ( Test-Path "\\$computer\c$\Program Files (x86)\Company\Service2\Library.dll") {
        $version = (Get-Item "\\$computer\c$\Program Files (x86)\Company\Service2\Library.dll").VersionInfo.FileVersion
        [xml]$XmlDocument = Get-Content -Path "\\$computer\c$\Program Files (x86)\Company\Service2\Service2Config.xml"
        $SQLServer = $XmlDocument.Service2.Profile.SQLServer.Instance
        $Database = $XmlDocument.Service2.Profile.SQLServer.Database.Name
        $servicestatus = Get-Service -ComputerName $computer | Where-Object Name -like "Service2" 
        $ServiceName = "Service2"
        Ammend-ServiceOutput
    }
}
#Auto Generation Account Statements
function Get-Service3 {
    if ( Test-Path "\\$computer\c$\Program Files (x86)\Company\Service3\Library.dll") {
        $version = (Get-Item "\\$computer\c$\Program Files (x86)\Company\Service3\Library.dll").VersionInfo.FileVersion
        [xml]$XmlDocument = Get-Content -Path "\\$computer\c$\Program Files (x86)\Company\Service3\Service3Config.xml"
        $SQLServer = $XmlDocument.Service3.Connection.Server
        $Database = $XmlDocument.Service3.Connection.Database
        $servicestatus = Get-Service -ComputerName $computer | Where-Object Name -like "Service3" 
        $ServiceName = "Service3"
        Ammend-ServiceOutput
    }
}
#BinderCloud Service
function Get-Service4 {
    if ( Test-Path "\\$computer\c$\Program Files (x86)\Company\Company Service4\Library.dll") {
        $version = (Get-Item "\\$computer\c$\Program Files (x86)\Company\Company Service4\Library.dll").VersionInfo.FileVersion
        [xml]$XmlDocument = Get-Content -Path "\\$computer\c$\Program Files (x86)\Company\Company Service4\Service4Config.xml"
        $SQLServer = $XmlDocument.Service4.Profile.SQLServer.Instance
        $Database = $XmlDocument.Service4.Profile.SQLServer.Database.Name
        $servicestatus = Get-Service -ComputerName $computer | Where Name -like "Service4" 
        $ServiceName = "Service4"
        Ammend-ServiceOutput
    }
}

#SPSUpload Service
function Get-Service5 {
    if ( Test-Path "\\$computer\c$\Program Files (x86)\Company\Service5\Library.dll") {
        $version = (Get-Item "\\$computer\c$\Program Files (x86)\Company\Service5\Library.dll").VersionInfo.FileVersion
        [xml]$XmlDocument = Get-Content -Path "\\$computer\c$\Program Files (x86)\Company\Service5\SPSUploadConfig.xml"
        $SQLServer = $XmlDocument.Service5.Profile.SQLServer.Instance
        $Database = $XmlDocument.Service5.Profile.SQLServer.Database.Name
        $servicestatus = Get-Service -ComputerName $computer | Where Name -like "Service5" 
        $ServiceName = "Service5"
        Ammend-ServiceOutput
    }
}

#BSM (Toxchange) Service
function Get-Service6 {
    if ( Test-Path "\\$computer\c$\Program Files (x86)\Company\Service6\Library.dll") {
        $version = (Get-Item "\\$computer\c$\Program Files (x86)\Company\Service6\Library.dll").VersionInfo.FileVersion
        [xml]$XmlDocument = Get-Content -Path "\\$computer\c$\Program Files (x86)\Company\Service6\options.xml"
        $connectionstring = $XmlDocument.options.connectionstring
        [Reflection.Assembly]::LoadFile("\\$computer\c$\Program Files (x86)\Company\Service6\Library.dll")
        $connectionstring = [Company.Mics.Cryptography]::Decrypt("$connectionstring")
        $SQLServer = ($connectionstring.Split(";")[1]).Split('"')[1]
        $Database = ($connectionstring.Split(";")[5]).Split('"')[1]
        $servicestatus = Get-Service -ComputerName $computer | Where Name -like "Service6" 
        $ServiceName = "Service6"
        Ammend-ServiceOutput
    }
}

#CLASS service
function Get-Service7 {
    if ( Test-Path  "\\$computer\c$\Program Files (x86)\Company\Company Service7\Library.dll") {
        $version = (Get-Item "\\$computer\c$\Program Files (x86)\Company\Company Service7\Library.dll").VersionInfo.FileVersion
        [xml]$XmlDocument = Get-Content -Path "\\$computer\c$\Program Files (x86)\Company\Company Service7\Service7.exe.config"
        $connectionstring = $XmlDocument.configuration.connectionStrings.add.connectionString
        $SQLServer = (($connectionstring.Split(";")[1]).Split('"')).Split('=')[1]
        $Database = (($connectionstring.Split(";")[0]).Split('"')[0]).Split('=')[1]
        $servicestatus = Get-Service -ComputerName $computer | Where-Object Name -like "Service7" 
        $ServiceName = "Service7"
        Ammend-ServiceOutput
    }
}
#CLASS service
function Get-Service8 {
    if ( Test-Path  "\\$computer\c$\Program Files (x86)\Company\Test Service8\Library.dll") {
        $version = (Get-Item "\\$computer\c$\Program Files (x86)\Company\Test Service8\Library.dll").VersionInfo.FileVersion
        [xml]$XmlDocument = Get-Content -Path "\\$computer\c$\Program Files (x86)\Company\Test Service8\Configuration.xml"
        $SQLServer = $XmlDocument.options.ftp.destinationdatabases.database.server
        $Database = $XmlDocument.options.ftp.destinationdatabases.database.database
        $servicestatus = Get-Service -ComputerName $computer | Where-Object Name -like "Service8" 
        $ServiceName = "Service8"
        Ammend-ServiceOutput
    }
}
#WorldCheck service
function Get-Service9 {
    if ( Test-Path  "\\$computer\c$\Program Files (x86)\Company\Company Test Service9\Library.dll") {
        $version = (Get-Item "\\$computer\c$\Program Files (x86)\Company\Company Test Service9\Library.dll").VersionInfo.FileVersion
        [xml]$XmlDocument = Get-Content -Path "\\$computer\c$\Program Files (x86)\Company\Company Test Service9\WorldCheckExportConfig.xml"
        $SQLServer = $XmlDocument.Service9.connection.server
        $Database = $XmlDocument.Service9.connection.database
        $servicestatus = Get-Service -ComputerName $computer | Where-Object Name -like "Service9" 
        $ServiceName = "Service9"
        Ammend-ServiceOutput
    }
}
ForEach ($computer in $servers) {
    Get-Service1
    Get-Service2
    Get-Service3
    Get-Service4
    Get-Service5
    Get-Service6
    Get-Service7
    Get-Service8
    Get-Service9
    
}

function HTMLColor {
    $PSItem -replace "Stopped", "<span style='background-color: #FF8080'>Stopped</span>" -replace "Running", "<span style='background-color: #40ff00'>Running</span>"
}
#$servicename = $output.Service[0]
$output  | Where-Object Service -Like 'Service1' | Sort-Object  Service | ConvertTo-HTML -head $head | ForEach-Object {HTMLColor} | Out-File $ServicesFile 
$output  | Where-Object Service -Like 'Service2' | Sort-Object  Service | ConvertTo-HTML -head $head | ForEach-Object {HTMLColor} | Out-File $ServicesFile -Append
$output  | Where-Object Service -Like 'Service3' | Sort-Object  Service | ConvertTo-HTML -head $head | ForEach-Object {HTMLColor} | Out-File $ServicesFile -Append
$output  | Where-Object Service -Like 'Service4' | Sort-Object  Service | ConvertTo-HTML -head $head | ForEach-Object {HTMLColor} | Out-File $ServicesFile -Append
$output  | Where-Object Service -Like 'Service5' | Sort-Object  Service | ConvertTo-HTML -head $head | ForEach-Object {HTMLColor} | Out-File $ServicesFile -Append
$output  | Where-Object Service -Like 'Service6' | Sort-Object  Service | ConvertTo-HTML -head $head | ForEach-Object {HTMLColor} | Out-File $ServicesFile -Append
$output  | Where-Object Service -Like 'Service7' | Sort-Object  Service | ConvertTo-HTML -head $head | ForEach-Object {HTMLColor} | Out-File $ServicesFile -Append
$output  | Where-Object Service -Like 'Service8' | Sort-Object  Service | ConvertTo-HTML -head $head | ForEach-Object {HTMLColor} | Out-File $ServicesFile -Append
$output  | Where-Object Service -Like 'Service9' | Sort-Object  Service | ConvertTo-HTML -head $head | ForEach-Object {HTMLColor} | Out-File $ServicesFile -Append

& $ServicesFile