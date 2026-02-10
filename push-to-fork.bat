@echo off
echo ========================================
echo Push Changes to GitHub
echo ========================================
echo.

cd /d "c:\Users\Ron063\Desktop\nodecrypt"

set GIT="C:\Users\Ron063\AppData\Local\GitHubDesktop\app-3.5.4\resources\app\git\cmd\git.exe"

echo Adding modified files...
%GIT% add .gitignore
%GIT% add client/css/style.css
%GIT% add -u
echo Done!
echo.

echo Committing changes...
%GIT% commit -m "feat: Hide download button in file messages"
echo Done!
echo.

echo Pushing to GitHub...
%GIT% push origin main
echo Done!
echo.

echo ========================================
echo SUCCESS! Changes pushed to GitHub!
echo ========================================
echo.
echo Visit: https://github.com/uszhanghu/nodecrypt
echo.
pause
