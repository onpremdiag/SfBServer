setlocal enabledelayedexpansion
powershell.exe -ExecutionPolicy Unrestricted -NoProfile -WindowStyle Hidden -File "%~dp0Create-NuGetPackage.ps1"
endlocal
exit /B %ERRORLEVEL%
