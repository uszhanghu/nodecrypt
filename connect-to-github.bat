@echo off
echo Connecting to existing GitHub repository...
echo.

cd /d "c:\Users\Ron063\Desktop\nodecrypt"

git remote add origin https://github.com/uszhanghu/nodecrypt.git
git branch -M main
git pull origin main --allow-unrelated-histories
git push -u origin main

echo.
echo Done! Repository connected and pushed to GitHub.
pause
