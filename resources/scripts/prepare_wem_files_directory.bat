@echo off
for /R "%~dp0" %%F in (*.english.stream) do ren "%%F" "%%~nF" :: Remove first part of the complex extension
for /R "%~dp0" %%F in (*.english) do ren "%%F" "%%~nF.wem" :: Rename .english to .wem
for /R "%~dp0" %%F in (*.stream) do ren "%%F" "%%~nF.wem" :: Rename .stream to .wem
for /R "%~dp0" %%F in (*.wem) do move /y "%%F" "%~dp0" :: Move them all to folder containing this script
PAUSE