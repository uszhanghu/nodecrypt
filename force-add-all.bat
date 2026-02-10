@echo off
echo ========================================
echo Force Add All Modified Files to Git
echo ========================================
echo.

cd /d "c:\Users\Ron063\Desktop\nodecrypt"

set GIT="C:\Users\Ron063\AppData\Local\GitHubDesktop\app-3.5.4\resources\app\git\cmd\git.exe"

echo Adding all files (including modified ones)...
%GIT% add -A
echo Done!
echo.

echo Checking status...
%GIT% status
echo.

echo ========================================
echo All files added! Now go to GitHub Desktop
echo and you should see all your changes!
echo ========================================
pause
