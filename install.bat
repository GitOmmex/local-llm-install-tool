@echo off
setlocal enabledelayedexpansion
echo ===========================================
echo   GPU and VRAM Information
echo ===========================================

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
pause
