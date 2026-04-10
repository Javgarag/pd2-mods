@echo off

:: Remove first part of the complex extension
for /R "%~dp0" %%F in (*.english.stream) do ren "%%F" "%%~nF" 

:: Rename .english to .wem
for /R "%~dp0" %%F in (*.english) do ren "%%F" "%%~nF.wem" 

:: Rename .stream to .wem
for /R "%~dp0" %%F in (*.stream) do ren "%%F" "%%~nF.wem" 

:: Move them all to folder containing this script
for /R "%~dp0" %%F in (*.wem) do move /y "%%F" "%~dp0" 
PAUSE