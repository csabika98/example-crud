
Param(
    [string]$BUILD_TYPE = "Debug"
)


$mingwBinPath = "C:\msys64\mingw64\bin"
#$installPrefix = "C:\Users\CsabaSallai\oatpp-install"  # Set your user-space installation prefix


Remove-Item -Path "tmp" -Recurse -Force -ErrorAction SilentlyContinue


New-Item -Path "tmp" -ItemType Directory | Out-Null
Set-Location -Path "tmp"

##########################################################

function Install-Module {
    param(
        [string]$BuildType,
        [string]$ModuleName
    )


    $NPROC = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors


    if ($null -eq $NPROC -or 0 -eq $NPROC) {
        $NPROC = 1
    }

    Write-Host "`n`nINSTALLING MODULE '$ModuleName' ($BuildType) using $NPROC threads...`n`n"


    git clone --depth=1 "https://github.com/oatpp/$ModuleName"


    Set-Location -Path "$ModuleName"
    New-Item -Path "build" -ItemType Directory | Out-Null
    Set-Location -Path "build"


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

Install-Module -BuildType $BUILD_TYPE -ModuleName "oatpp"


$env:CMAKE_PREFIX_PATH = "$installPrefix;$env:CMAKE_PREFIX_PATH"

Install-Module -BuildType $BUILD_TYPE -ModuleName "oatpp-swagger"
Install-Module -BuildType $BUILD_TYPE -ModuleName "oatpp-sqlite"


Set-Location -Path ".."
Remove-Item -Path "tmp" -Recurse -Force









