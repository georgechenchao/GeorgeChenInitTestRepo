$testStr = "dotnet/netcore-4.0/mscorlib.dll
dotnet/netcore-5.0/mscorlib.dll
microsoft/netcore-3.0/mscorlib.dll";

$testStrArray = $testStr.Split("`n");
$testStrArray;
$testStrArray.Count;
$folderArray= New-Object System.Collections.Generic.List[System.Object];
for ($index = 0; $index -lt $testStrArray.Count; $index++)
{
    $index + 1;
    $testStrArray[$index];
    if ($testStrArray[$index].Trim().EndsWith("dll"))
    {
        "This is test";
        $folderStarterName = $testStrArray[$index].Split("/")[0].Trim();
        if ($folderArray -notcontains $folderStarterName)
        {
            $folderArray.Add($folderStarterName);
        }
    }
}
$folderArray.Count;
$folderArray;
