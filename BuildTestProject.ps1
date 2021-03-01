Clear-Host
# Set the project files path 

$BaseDirectory = "C:\Users\Fourier\HelloWorld"
$SolutionFilesPath = "$BaseDirectory\SolutionConfig.txt"

$ProjectFiles = Get-Content $SolutionFilesPath


$msbuild = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
$MSBuildLogger = "/flp1:Append;LogFile=Build.log;Verbosity=Normal;/flp2:LogFile=BuildErrors.log;Verbosity=Normal;errorsonly"

$DevEnv = "C:\Program Files\Microsoft Visual Studio 11.0\Common9\IDE\devenv.exe"

$Action = "Y"

 $ENV:Path + ";C:\Program Files\Microsoft SDKs\Windows\v7.0A"

 #Iterate through the project folder and look for the .sln file to build the Project.
 foreach ($ProjectFile in $ProjectFiles)
 {
    if ($ProjectFile.EndsWith(".sln"))
    {
        $ProjectFileAbsPath = "$BaseDirectory\$ProjectFile"

        $FileName = [System.IO.Path]::GetFileName($ProjectFile);
        $Action = "Y"
        while ($Action -eq "Y")
        {
            if (Test-Path $ProjectFileAbsPath)
            {
                Write-Host "Building $ProjectFileAbsPath"
                & $msbuild $ProjectFileAbsPath /t:rebuild /p:PlatformTarget=x86 /fl

# Log the generated Build logs in a logfile

"/flp1:logfile=$BaseDirectory\msbuild.log;Verbosity=Normal;Append;"
"/flp2:logfile=$BaseDirectory\errors.txt;errorsonly;Append;"
                & $DevEnv $projectFileAbsPath /Rebuild

                # Check for issues and fix the issues or Ignore it and proceed with the build

                if ($LASTEXITCODE -eq 0)
                {
                    Write-Host "Build SUCCESS"
                    Clear-Host
                    break

                }
                else
                {
                    Write-Host "Build FAILED"

                    $Action = Read-Host "Press Y to Fix then continue, N to Terminate, I to Ignore and continue the build"

                    if ($Action -eq "Y")
                    {
                        & $DevEnv $ProjectFileAbsPath
                        Wait-Process -Name Devenv 
                    }
                    else
                    {
                        if ($Action -eq "I")
                        {
                            Write-Host "Ignoring build failure ......"
                            break
                        }
                        else
                        {
                            Write-Host "Terminating Build.. Please fix the issue and restart the build"
                            break
                        }
                    }
                }
            }
            else
            {
                Write-Host "File does not exist : $ProjectFileAbsPath"
                break
            }
        }
        if ($Action -eq "N")
        {
            break;
        }
    }
 }


# Run a test using the test file in the Project folder



foreach ($ProjectFile in $ProjectFiles)
 {
    if ($ProjectFile.Equals("MyTest.csproj"))
    {
        $ProjectFileAbsPath = "$BaseDirectory\$ProjectFile"

        $FileName = [System.IO.Path]::GetFileName($ProjectFile);
        msbuild MyTests.csproj 
    }
 }

 # Publish to my a Publish Folder

$ProjectName = (Get-Item $BaseDirectory).BaseName
 
$PackageDir = "C:\PublishedPackage\' -f $ProjectName"
$Package = Resolve-Path –LiteralPath $PackageDir
return $Package
dotnet publish --output $Package -p:PublishReadyToRun=false