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

$currentCommit;
$lastCommit;

$changeListForRepo = &git diff --name-only $lastCommit $currentCommit
$testText = "Test Text";
$testText;
$changeListForRepo;
$changeListForRepoArray = $changeListForRepo.Split("`n");
$changeListForRepoArray.Count;
$changeListForRepoArray;
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
$dllFolderSet.Count;
$dllFolderSet;
