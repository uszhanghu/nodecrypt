@echo off
echo ========================================
echo FORCE PUSH to GitHub Fork
echo ========================================
echo.
echo WARNING: This will overwrite the remote repository
echo with your local changes!
echo.
pause

cd /d "c:\Users\Ron063\Desktop\nodecrypt"

set GIT="C:\Users\Ron063\AppData\Local\GitHubDesktop\app-3.5.4\resources\app\git\cmd\git.exe"

echo Step 1: Adding all files...
%GIT% add -A
echo Done!
echo.

echo Step 2: Committing changes...
%GIT% commit -m "feat: Add media preview support for images and videos" -m "- Add image preview in chat messages" -m "- Add video player for video files" -m "- Support both sender and receiver preview" -m "- Add Docker Compose deployment" -m "- Add GitHub Actions workflow" -m "- Add deployment documentation"
echo Done!
echo.

echo Step 3: Force pushing to GitHub...
echo This may take a moment...
%GIT% push -f origin main
echo Done!
echo.

echo ========================================
echo SUCCESS! All changes pushed to GitHub!
echo ========================================
echo.
echo Visit: https://github.com/uszhanghu/nodecrypt
echo.
pause
