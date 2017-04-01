chcp 437

git pull

git add .

For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%a-%%b-%%c)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)
SET commit_time = %mydate-%mytime
echo %commit_time%

git commit -m %commit_time

git push origin master:master