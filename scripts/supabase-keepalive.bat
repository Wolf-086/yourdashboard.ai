@echo off
setlocal enabledelayedexpansion
set LOG_DIR=%~dp0..\logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set LOG_FILE=%LOG_DIR%\supabase-keepalive.log

if exist "%~dp0.env" (
 for /f "usebackq delims=" %%i in (`"%~dp0.env"`) do (
  set "line=%%i"
  if not "!line:~0,1!"=="#" (
   for /f "tokens=1,* delims==" %%a in ("!line!") do (
    set "%%a=%%b"
   )
  )
 )
)

if "%SUPABASE_PROJECT_REF%"=="" (
 echo [%date:~0,4%-%date:~5,2%-%date:~8,2%T%time:~0,2%:%time:~3,2%:%time:~6,2%] FAIL MISSING_ENV>>"%LOG_FILE%"
 exit /b 1
)

curl -s -o NUL -w "%%{http_code}" ^
 -H "apikey: %SUPABASE_API_KEY%" ^
 -H "Accept: application/json" ^
 --max-time 30 ^
 "https://%SUPABASE_PROJECT_REF%.supabase.co/rest/v1/" > "%TEMP%\sp_code.txt" 2>nul
set /p HTTP_CODE=<"%TEMP%\sp_code.txt"
del "%TEMP%\sp_code.txt"

if "%HTTP_CODE:~0,1%"=="2" (
 set STATUS=OK
) else (
 set STATUS=FAIL
)

echo [%date:~0,4%-%date:~5,2%-%date:~8,2%T%time:~0,2%:%time:~3,2%:%time:~6,2%] %STATUS% %HTTP_CODE%>>"%LOG_FILE%"
endlocal
exit /b 0
