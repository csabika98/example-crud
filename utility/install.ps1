# Define the script parameters
Param(
    [string]$BUILD_TYPE = "Debug"
)

# Path to the compilers and make tool
$mingwBinPath = "C:\msys64\mingw64\bin"
#$installPrefix = "C:\Users\CsabaSallai\oatpp-install"  # Set your user-space installation prefix

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

    # Set the C and C++ compilers and add the path to the environment
    $env:PATH = "$mingwBinPath;$env:PATH"
    $makeProgram = "$mingwBinPath\mingw32-make.exe"

    $cmakeCommand = @()
    $cmakeCommand += "-G"
    $cmakeCommand += "MinGW Makefiles"
    $cmakeCommand += "-DCMAKE_C_COMPILER=$mingwBinPath\x86_64-w64-mingw32-gcc.exe"
    $cmakeCommand += "-DCMAKE_CXX_COMPILER=$mingwBinPath\x86_64-w64-mingw32-g++.exe"
    $cmakeCommand += "-DCMAKE_MAKE_PROGRAM=$makeProgram"
    $cmakeCommand += "-DCMAKE_BUILD_TYPE=$BuildType"
    #$cmakeCommand += "-DCMAKE_INSTALL_PREFIX=$installPrefix"
    if ($ModuleName -eq 'oatpp-sqlite') {
        $cmakeCommand += "-DOATPP_SQLITE_AMALGAMATION=ON"
    }
    $cmakeCommand += "-DOATPP_BUILD_TESTS=OFF"
    $cmakeCommand += ".."

    cmake $cmakeCommand

    cmake --build . --target install -- -j $NPROC

    Set-Location -Path "../.."
}

##########################################################
# Invoke the install function for each module
Install-Module -BuildType $BUILD_TYPE -ModuleName "oatpp"

# Set CMAKE_PREFIX_PATH for subsequent modules
$env:CMAKE_PREFIX_PATH = "$installPrefix;$env:CMAKE_PREFIX_PATH"

Install-Module -BuildType $BUILD_TYPE -ModuleName "oatpp-swagger"
Install-Module -BuildType $BUILD_TYPE -ModuleName "oatpp-sqlite"

# Cleanup
Set-Location -Path ".."
Remove-Item -Path "tmp" -Recurse -Force









