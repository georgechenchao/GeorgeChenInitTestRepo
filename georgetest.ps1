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
$currentCommit = $env:GIT_COMMIT
$lastCommit = $env:GIT_PREVIOUS_COMMIT
$changeListForRepo = &git diff --name-only $lastCommit $currentCommit
if ($currentCommit -ne $lastCommit -and $changeListForRepo)
{
    $changeListForRepoArray = $changeListForRepo.Split("`n");
    $dllFolderSet = New-Object System.Collections.Generic.List[System.Object];
    ForEach($fileItem in $changeListForRepoArray)
    {
        if ($fileItem.Trim().EndsWith("dll"))
        {
            $folderName = $fileItem.Split("/")[0].Trim();
            if ($dllFolderSet -notcontains $folderName)
            {
                $dllFolderSet.Add($folderName);
            }
        }
    }
    $dllFolderSet;

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
    & git clone $contentRepoUrl $contentRepoPath
    $xmlPath = Join-Path $contentRepoPath $xmlPath
    if (-Not (Test-Path $xmlPath))
    {
        New-Item $xmlPath -ItemType directory
    }
    Push-Location $contentRepoPath
    $checkBr = & git ls-remote --heads $contentRepoUrl $branch
    & git fetch
    & git checkout -B $branch
    if (-Not [string]::IsNullOrEmpty($checkBr)) {
        & git branch --set-upstream-to=origin/$branch
        & git pull
    }
    Pop-Location

    ForEach($folderName in $dllFolderSet)
    {
        & $mdocExePath fx-bootstrap (".\" + $folderName)
        & $mdocExePath update -o $xmlPath -fx (".\" + $folderName) -use-docid
    }

    Push-Location $contentRepoPath
    & git add .
    & git commit -m "mdoc CI update"
    & git push
    Pop-Location

    Pop-Location
}