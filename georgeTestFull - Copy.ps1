param (
    [string]$contentRepoUrl = "https://1ddeb6f0cbf6cbf40fdbfbcb43a8da3239d5f5dd@github.com/georgechenchao/georgechenchaoRepo1215041730.git",
    [string]$branch = "CITest003",
    [string]$xmlPath = "CITestConsole2/xml"
)

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

$url = "https://github.com/mono/api-doc-tools/releases/download/preview-5.0.0.14/preview-mdoc-5.0.0.14.zip"
$currentCommit = GIT_COMMIT
$lastCommit = GIT_PREVIOUS_COMMIT

$currentCommit;
$lastCommit;

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Push-Location $scriptPath

$mdocZipPath = Join-Path $scriptPath "mdoc.zip"
$mdocPath = Join-Path $scriptPath "mdoc"
$mdocExePath = Join-Path $mdocPath "mdoc.exe"
if (Test-Path $mdocZipPath)
{
    Remove-Item $mdocZipPath
}
if (Test-Path $mdocPath)
{
    Remove-Item $mdocPath -Recurse
}
New-Item $mdocPath -type directory
Write-Output "Dowloading mdoc from $url"
Invoke-WebRequest -Uri $url -OutFile $mdocZipPath
Unzip $mdocZipPath $mdocPath

$contentRepoPath = Join-Path $scriptPath "contentRepo"
$xmlPath = Join-Path $contentRepoPath $xmlPath
if (-Not (Test-Path $xmlPath))
{
    New-Item $xmlPath -ItemType directory
}
& git clone $contentRepoUrl $contentRepoPath
Push-Location $contentRepoPath
$checkBr = & git ls-remote --heads $contentRepoUrl $branch
& git fetch
& git checkout -B $branch
if (-Not [string]::IsNullOrEmpty($checkBr)) {
    & git branch --set-upstream-to=origin/$branch
    & git pull
}
Pop-Location

& $mdocExePath fx-bootstrap .\dotnet
& $mdocExePath update -o $xmlPath -fx .\dotnet -use-docid

Push-Location $contentRepoPath
& git add -A
& git commit -m "mdoc CI update"
& git push --set-upstream origin $branch
Pop-Location

Pop-Location