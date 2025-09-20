@echo off
setlocal enabledelayedexpansion
echo =======================================================
echo   Fetching GPU and VRAM Information. Please wait...
echo =======================================================

set "dxfile=%TEMP%\dxdiag_gpu.txt"
dxdiag /t "%dxfile%" >nul 2>&1

set "gpuName="
set "vramMB="

for /f "usebackq tokens=1* delims=:" %%A in ("%dxfile%") do (
    set "key=%%A"
    set "val=%%B"
    for /f "tokens=* delims= " %%K in ("!key!") do set "key=%%K"
    for /f "tokens=* delims= " %%K in ("!val!") do set "val=%%K"

    if /i "!key!"=="Card name" (
        set "gpuName=!val!"
    )
    if /i "!key!"=="Dedicated Memory" (
        for /f "tokens=1" %%M in ("!val!") do set "vramMB=%%M"
    )

    if defined gpuName if defined vramMB (
        echo GPU: !gpuName!
        echo VRAM: !vramMB! MB
        echo -------------------------------
        set "gpuName="
        set "vramMB="
    )
)

REM --- Get System RAM in MB ---
for /f "skip=1 tokens=2 delims=," %%A in ('wmic computersystem get TotalPhysicalMemory /format:csv') do set "sysRAMB=%%A"
for /f "delims=" %%A in ('powershell -Command "(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB"') do set "sysRAMMB=%%A"

REM --- Find GPU with Most VRAM ---
set "maxVRAM=0"
set "maxGPU="
for /f "usebackq tokens=1* delims=:" %%A in ("%dxfile%") do (
    set "key=%%A"
    set "val=%%B"
    for /f "tokens=* delims= " %%K in ("!key!") do set "key=%%K"
    for /f "tokens=* delims= " %%K in ("!val!") do set "val=%%K"

    if /i "!key!"=="Card name" (
        set "gpuName=!val!"
    )
    if /i "!key!"=="Dedicated Memory" (
        for /f "tokens=1" %%M in ("!val!") do set "vramMB=%%M"
    )

    if defined gpuName if defined vramMB (
        if !vramMB! gtr !maxVRAM! (
            set "maxVRAM=!vramMB!"
            set "maxGPU=!gpuName!"
        )
        set "gpuName="
        set "vramMB="
    )
)

REM --- Calculate Combined Memory ---
set /a halfRAM=sysRAMMB/2
set /a combinedMem=maxVRAM+halfRAM

echo System RAM: %sysRAMMB% MB
if defined maxGPU echo Main GPU: %maxGPU%
echo Main GPU VRAM: %maxVRAM% MB

echo.
echo Combined memory for LLM: %combinedMem% MB

echo =======================================================

REM --- Recommend LLM based on combined memory ---
set /a combinedGB=combinedMem/1024
if %combinedGB% lss 12 (
    set "llm=Qwen3 4B Instruct 2507"
) else (
    if %combinedGB% leq 64 (
        set "llm=GPT Oss 20B"
    ) else (
        set "llm=GPT Oss 120B"
    )
)
echo Recommended LLM: %llm%

REM --- Prompt user to accept recommendation or choose LLM ---
set "selectedLLM=%llm%"
set /p userChoice=Do you want to use the recommended LLM (%llm%)? (Y/N): 
if /i "%userChoice%"=="N" (
    echo Choose your LLM option:
    echo 1. Qwen3 4B Instruct 2507
    echo 2. GPT Oss 20B
    echo 3. GPT Oss 120B
    set /p llmChoice=Enter 1, 2, or 3: 
    if "%llmChoice%"=="1" set "selectedLLM=Qwen3 4B Instruct 2507"
    if "%llmChoice%"=="2" set "selectedLLM=GPT Oss 20B"
    if "%llmChoice%"=="3" set "selectedLLM=GPT Oss 120B"
)
echo You selected: %selectedLLM%

echo Checking for Python installation...

where python >nul 2>&1
if errorlevel 1 (
    echo Python is not installed. Please install Python from https://www.python.org/downloads/ and ensure it is added to your PATH.
    goto end
) else (
    echo Python is installed.
)

echo Continue with installation? (Y/N): 
set /p contChoice=
if /i "%contChoice%" neq "Y" (
    echo Installation aborted.
    goto end
)

set "WEBUI_URL=https://github.com/oobabooga/text-generation-webui/archive/refs/heads/main.zip"
echo Downloading Text Generation WebUI...
powershell -Command "Invoke-WebRequest -Uri '%WEBUI_URL%' -OutFile 'main.zip'"
echo Extracting WebUI...
powershell -Command "Expand-Archive -Path 'main.zip' -DestinationPath '.' -Force"
del main.zip
cd text-generation-webui-main
pause
