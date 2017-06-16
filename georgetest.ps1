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
$currentCommit = &GIT_COMMIT
$lastCommit = &GIT_PREVIOUS_COMMIT

$currentCommit;
$lastCommit;
