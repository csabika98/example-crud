# Define the script parameters
Param(
    [string]$BUILD_TYPE = "Debug"
)

# Clean up old temporary directory
Remove-Item -Path "tmp" -Recurse -Force -ErrorAction SilentlyContinue

# Create a new temporary directory
New-Item -Path "tmp" -ItemType Directory | Out-Null
Set-Location -Path "tmp"

##########################################################
## Function to install oatpp module
function Install-Module {
    param(
        [string]$BuildType,
        [string]$ModuleName
    )

    # Get the number of processors
    $NPROC = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors

    # Properly use $null on the left side of the equality
    if ($null -eq $NPROC -or 0 -eq $NPROC) {
        $NPROC = 1
    }

    Write-Host "`n`nINSTALLING MODULE '$ModuleName' ($BuildType) using $NPROC threads...`n`n"

    # Clone the repository
    git clone --depth=1 "https://github.com/oatpp/$ModuleName"

    # Build the module
    Set-Location -Path "$ModuleName"
    New-Item -Path "build" -ItemType Directory | Out-Null
    Set-Location -Path "build"

    # Customize build commands based on module
    if ($ModuleName -eq 'oatpp') {
        cmake -DOATPP_BUILD_TESTS=OFF ..
    }
    if ($ModuleName -eq 'oatpp-sqlite') {
        cmake -DOATPP_BUILD_TESTS=OFF -DOATPP_SQLITE_AMALGAMATION=ON ..
    } else {
        cmake -DOATPP_BUILD_TESTS=OFF ..
    }
    cmake --build . --target install -- /m:$NPROC

    Set-Location -Path "../.."
}

##########################################################
# Invoke the install function for each module
Install-Module -BuildType $BUILD_TYPE -ModuleName "oatpp"
Install-Module -BuildType $BUILD_TYPE -ModuleName "oatpp-swagger"
Install-Module -BuildType $BUILD_TYPE -ModuleName "oatpp-sqlite"

# Cleanup
Set-Location -Path ".."
Remove-Item -Path "tmp" -Recurse -Force



