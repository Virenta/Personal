param ($VersionMajor, $VersionMinor, $VersionRevision, $VersionBuild)
[String]$buildID = "$env:BUILD_BUILDID"
[String]$project = "$env:SYSTEM_TEAMPROJECT"
[String]$projecturi = "$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI"

$buildurl = $projecturi + $project + "/_apis/build/builds/" + $buildID + "?api-version=2.0"

$getbuild = Invoke-RestMethod -Uri $buildurl -UseDefaultCredentials -Method Get |select definition

$definitionid = $getbuild.definition.id

$defurl = $projecturi + $project + "/_apis/build/definitions/" + $definitionid + "?api-version=2.0"

$definition = Invoke-RestMethod -Uri $defurl -UseDefaultCredentials -Method Get

[int]$definition.variables.VersionBuild.value += 1

$json = @($definition) | ConvertTo-Json  -Depth 100

$updatedef = Invoke-RestMethod  -Uri $defurl -UseDefaultCredentials -Method Put -Body $json -ContentType "application/json"
$VersionBuild = [int]$definition.variables.VersionBuild.value
Write-Verbose -Verbose "##vso[build.updatebuildnumber]$VersionMajor.$VersionMinor.$VersionRevision.$VersionBuild"