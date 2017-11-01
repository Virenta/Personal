param ($DataBases, $SDWExe) 
$XMLPath = "D:\SDW Scenario\Temp"
$XMLFile = "GlobalXB.xml"
$BuildVersion = $env:Build_BuildNumber
$BranchName = $env:Build_SourceBranchName
$XMLEdit = Get-Content $XMLPath\$XMLFile
$UpdatedDBarray = @()
$NotUpdatedDBarray = @()

function AmmmendXMLFile {
    if ($SQLServer -eq "sql_server1") {$SApassword = "pasword" }
    if ($SQLServer -eq "sql_server2") {$SApassword = "pasword" }
    if ($SQLServer -eq "sql_server3") {$SApassword = "pasword" }
    
    $XMLAmmend = '
    <Database>
        <Name CanBeEmpty="0" Value="$SQLDatabase" />
        <Version CanBeEmpty="0" Value="$BuildVersion" />
        <TimeOut CanBeEmpty="0" Value="10000" />
        <ReIndex CanBeEmpty="0" Value="0" />
        <ServerName CanBeEmpty="0" Value="$SQLServer" />
        <AuthType CanBeEmpty="0" Value="sa" />
        <Login CanBeEmpty="0" Value="sa" />
        <Password CanBeEmpty="0" Value="$SApassword" />
        <PathBackUp CanBeEmpty="1" Value="" />
        <PathRestore CanBeEmpty="1" Value="" />
        <MDFDest CanBeEmpty="1" Value="" />
        <LDFDest CanBeEmpty="1" Value="" />
        <MDFLogicalName CanBeEmpty="1" Value="" />
        <LDFLogicalName CanBeEmpty="1" Value="" />
    </Database>

'
    $XMLAmmend = $ExecutionContext.InvokeCommand.ExpandString($XMLAmmend)
    $XMLEdit[3] += $XMLAmmend
}


$DataBases = $DataBases.Split(",")
foreach ($DB in $DataBases) {
    $SQLServer = $DB.Split("\")[0]
    $SQLDatabase = $DB.Split("\")[1]
    try {
        $conn = New-Object System.Data.SqlClient.SqlConnection
        $conn.ConnectionString = "Data Source=$SQLserver;Initial Catalog=$SQLDatabase;Integrated Security=SSPI;"
        $conn.open()
        $conn.close()
        AmmmendXMLFile
        $UpdatedDBarray += $DB
        $XMLEdit | Set-Content "$XMLPath\GlobalXB_$BranchName.xml" -Encoding Unicode
    }
    catch {
        $NotUpdatedDBarray += $DB
        $ErrorMessage = $_.Exception.Message
        Write-Host "##vso[task.logissue type=warning;] $ErrorMessage"
    }
    
}
Write-Host "##vso[task.setprogress value=20;]Starting SDW Database upgrade"
Start-Process -FilePath $SdwExe -ArgumentList "`"$XMLPath\GlobalXB_$BranchName.xml`"", "false", "true" -Wait

Write-Host "##vso[task.setprogress value=75;]Sending Finish e-mail"
$MailFrom = "test_tfs_srv@totalobjects.spb.ru"
$MailTo = "vitaliy.barkanov@totalobjects.spb.ru"
$smtpServer = "tomail.totalobjects.spb.ru"
$Subject = "Build Finished $BranchName $BuildVersion"

$Body = "Пересобран $BranchName $BuildVersion<br>
Путь к инсталлятору:<br>
\\todata4\Public\Projects\COMMON\ActiveX\GlobalSystem\Dev\Setup.exe<br><br>
Обновлены базы:<br>"
foreach ($UpdatedDB in $UpdatedDBarray) {
    $SQLServer = $UpdatedDB.Split("\")[0]
    $SQLDatabase = $UpdatedDB.Split("\")[1]
    $Body += "$SQLDatabase на $SQLServer<br>" 
}

if ($NotUpdatedDBarray -ne $NULL) {
    $Body += "<br>Не обновлены базы:<br>"

    foreach ($NotUpdatedDB in $NotUpdatedDBarray) {
        $SQLServer = $NotUpdatedDB.Split("\")[0]
        $SQLDatabase = $NotUpdatedDB.Split("\")[1]
        $Body += "$SQLDatabase на $SQLServer<br>" 
    }
}

$Body += "<br>
Best regards,<br>
Deployment Team<br>"

Send-MailMessage -SmtpServer $smtpServer -To $MailTo -From $MailFrom -Subject $subject -BodyAsHtml -Body $body -Encoding UTF8