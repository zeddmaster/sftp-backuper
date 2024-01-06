@echo off

goto :main


:main
    call :parseConfigs
    call :prepareFolder
    call :runBackup
goto :eof



:parseConfigs

    if not exist config.ini exit \b "Please, create config.ini file"
    
    for /f "tokens=1,2 delims==" %%a in (config.ini) do (
        if %%a==host set host=%%b
        if %%a==hostUser set hostUser=%%b
        if %%a==password set password=%%b
        if %%a==hostkey set hostkey=%%b
    )
goto :eof
    
    
    
    
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
    

:runBackup
    echo %backupPath%
    rem exit /b
    ".\WinSCP\WinSCP.com" ^
      /log="WinSCP.log" /ini=nul ^
      /command ^
        "option echo off" ^
        "option batch on" ^
        "option confirm off" ^
        "open sftp://%hostUser%:%password%@%host%/ -hostkey=*" ^
        "lcd %backupPath%" ^
        "get MasterWorld*" ^
        "get plugins" ^
        "get *.json" ^
        "get *.yml" ^
        "get server.properties" ^
        "exit"


    set WINSCP_RESULT=%ERRORLEVEL%
    if %WINSCP_RESULT% equ 0 (
      echo Success
    ) else (
      echo Error
    )

    exit /b %WINSCP_RESULT%
goto :eof