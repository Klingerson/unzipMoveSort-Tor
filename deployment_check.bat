@echo off

:: Deployment check v 1.0
:: Written by Joshua Fox

:: TODO: instead of instruct user to add to path, 
:: search disk for it and add to path automatically if found

cls
echo Note: The shell needs to restart (new process) for path changes!

:: Check for admin and nag on fail
net session >NUL 2>&1
if not %errorlevel% == 0 (goto :MISSINGADMIN) else (goto :RUN)

:RUN

:CHECKPERL
where perl 2>NUL
if not %errorlevel% == 0 (goto :MISSINGPERL)

:CHECK7Z
where 7z 2>NUL
if not %errorlevel% == 0 (goto :MISSING7Z)

:: No errors found in above if statements
:SUCCESS
echo Deployment Check successful!
echo 7z and perl found in path!
pause
goto :eof

:: Can actually fix path but have to use with caution!
:: Only change directory path after C:\
:: setx /M path "%path%;C:\full path to\executable dir"

:: Checks and nags
:MISSINGADMIN
echo Script not running as admin (right click, run as admin)
echo This is okay for checking, but you will get errors
echo If you try to fix the path (feature not implemented yet)
pause
goto :RUN

:MISSINGPERL
echo perl not found in path!
echo If Strawberry Perl for Windows is already installed
echo Search google "Windows how to add perl to path"
pause
goto :CHECK7Z

:MISSING7Z
echo it appears 7z is missing!
echo if 7z is already installed 
echo Search google "Windows how to add 7z to path"
pause
goto :eof