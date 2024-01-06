@echo off

goto :main


rem Main executable method 
:main
    call :parseConfigs
    call :prepareFolder
    call :runBackup
goto :eof



rem Parse ini file
:parseConfigs

    if not exist config.ini exit \b "Please, create config.ini file"
    
    for /f "tokens=1,2 delims==" %%a in (config.ini) do (
        if %%a==host set host=%%b
        if %%a==hostUser set hostUser=%%b
        if %%a==password set password=%%b
    )
goto :eof
    
    
    
rem Prepare folder structure
:prepareFolder
    set backupFolder=.\backups\
    
    :: Name for folder by current day
    for /f "tokens=1* delims=" %%a in ('date /T') do set dailyFolder=%%a
    
    :: Folder for download files
    set backupPath=%backupFolder%%dailyFolder%
    
    :: Create directories
    if not exist %backupFolder% mkdir %backupFolder%
    if not exist %backupPath% mkdir %backupPath%
    
goto :eof
    

rem Run backuping with WinSCP
:runBackup
    echo %backupPath%
    rem exit /b
    ".\WinSCP\WinSCP.com" ^
      /ini=nul ^
      /command ^
        "option echo off" ^
        "option batch on" ^
        "option confirm off" ^
        "open sftp://%hostUser%:%password%@%host%/ -hostkey=*" ^
        "lcd %backupPath%" ^
        "get *"
        :: "get MasterWorld*" ^
        :: "get plugins" ^
        :: "get *.json" ^
        :: "get *.yml" ^
        :: "get server.properties" ^
        "exit"


    set WINSCP_RESULT=%ERRORLEVEL%
    if %WINSCP_RESULT% equ 0 (
      echo Success
    ) else (
      echo Error
    )

goto :eof