Param([string]$WORKSPACE, [string]$GIT_COMMIT_HASH)

Write-Host $WORKSPACE
Write-Host $GIT_COMMIT_HASH

$ASSEMBLY_INFO_PATH = "$WORKSPACE\src\Playground.Sample\Properties\AssemblyInfo.cs"
$ASSEMBLY_INFO_CONTENT = Get-Content $ASSEMBLY_INFO_PATH

$ASSEMBLY_VERSION = [regex]::Match($ASSEMBLY_INFO_CONTENT, "AssemblyVersion\(`"(.+?)`"\)").Groups[1].Value
$ASSEMBLY_INFORMATIONAL_VERSION = [string]::Format("[assembly: AssemblyInformationalVersion(`"{0}-{1}`")]", $ASSEMBLY_VERSION, $GIT_COMMIT_HASH.Substring(0, 7))

# 取得できたバージョンを表示
Write-Host $ASSEMBLY_INFORMATIONAL_VERSION

Add-Content -Path $ASSEMBLY_INFO_PATH -Value $ASSEMBLY_INFORMATIONAL_VERSION