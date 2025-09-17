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

del "%dxfile%" >nul 2>&1
REM --- Get System RAM in MB ---
for /f "skip=1 tokens=2 delims=," %%A in ('wmic computersystem get TotalPhysicalMemory /format:csv') do set "sysRAMB=%%A"
set /a sysRAMMB=%sysRAMB:~0,-6%

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
pause
