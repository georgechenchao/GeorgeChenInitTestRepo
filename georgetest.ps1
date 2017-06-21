param (
    [string]$contentRepoUrl = "https://b21c607a4eaf97f8392be661490b194ef2666b5d@github.com/TianqiZhang/ECMA2YamlTestRepo2.git",
    [string]$branch = "CITest4",
    [string]$xmlPath = "fulldocset/xml"
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
    <# Find out changed folders #>
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
    & git clone $contentRepoUrl $contentRepoPath
    Push-Location $contentRepoPath
    $checkBr = & git ls-remote --heads $contentRepoUrl $branch
    & git fetch
    & git checkout -B $branch
    if (-Not [string]::IsNullOrEmpty($checkBr)) {
        & git branch --set-upstream-to=origin/$branch
        & git pull
    }
    & git push --set-upstream origin $branch
    Pop-Location

    if (-Not (Test-Path $xmlPath))
    {
        New-Item $xmlPath -type directory
    }
    $dllFolderSet.Count;
    "TEST";
    "TEST";
    "TEST";
    "TEST";
    "TEST";
    "TEST";
    "TEST";
    "TEST";
    "TEST";
    ForEach($folderName in $dllFolderSet)
    {
        "Inner TEST";
        $folderName;
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