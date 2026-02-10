@echo off
echo ========================================
echo Connecting to GitHub Fork Repository
echo ========================================
echo.

cd /d "c:\Users\Ron063\Desktop\nodecrypt"

set GIT="C:\Users\Ron063\AppData\Local\GitHubDesktop\app-3.5.4\resources\app\git\cmd\git.exe"

echo Step 1: Configuring remote repository...
%GIT% remote remove origin 2>nul
%GIT% remote add origin https://github.com/uszhanghu/nodecrypt.git
echo Done!
echo.

echo Step 2: Setting branch to main...
%GIT% branch -M main
echo Done!
echo.

echo Step 3: Pulling from GitHub (merging with existing fork)...
%GIT% pull origin main --allow-unrelated-histories --no-edit
echo Done!
echo.

echo Step 4: Pushing all changes to GitHub...
%GIT% push -u origin main
echo Done!
echo.

echo ========================================
echo SUCCESS! Repository connected and pushed!
echo ========================================
echo.
echo Visit: https://github.com/uszhanghu/nodecrypt
echo.
pause
