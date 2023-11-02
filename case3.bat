@echo off

:menu
echo ===== Batch Command Menu =====
echo 1. Copy File/Folders by Name
echo 2. Delete Files/Folders outside date range
echo 3. Delete File/Folders by Name
echo 4. Delete Empty Folders and Subfolders
echo 5. Exit
echo ==============================
set /p choice=Enter your choice:

if "%choice%"=="1" (
goto copy_folder
) else if "%choice%"=="2" (
goto delete_old_files_and_folders
) else if "%choice%"=="3" (
goto delete__filesfolders_by_name
) else if "%choice%"=="4" (
goto delete_empty_folders_and_subfolders
) else if "%choice%"=="5" (
exit
) else (
echo Invalid choice. Please try again.
timeout /t 2 > nul
goto menu
)

:copy_folder
echo You selected menu 1. Copy files/folders by name.
setlocal enableextensions enabledelayedexpansion

set /p "sourceFolder=Enter the source folder path: "
set /p "destFolder=Enter the destination folder path: "
set /p "nameToCopy=Enter the partial name to copy: "

if not exist "%destFolder%" mkdir "%destFolder%"

set /a folderCounter=1
set /a fileCounter=1

for /d /r "%sourceFolder%" %%i in ("*%nameToCopy%*") do (
    set "destPath=%destFolder%\%%~nxi"
    if !folderCounter! gtr 1 (
        set "destPath=!destPath! (!folderCounter!)"
    )
    if not exist "!destPath!" (
        xcopy /E /I /Y "%%i" "!destPath!" >nul 2>nul
    )
    set /a folderCounter+=1
)

for /r "%sourceFolder%" %%i in ("*%nameToCopy%*") do (
    set "destPath=%destFolder%\%%~ni"
    set "extension=%%~xi"
    if !fileCounter! gtr 1 (
        set "destPath=!destPath! (!fileCounter!)"
    )
    if not exist "!destPath!!extension!" (
        copy /Y "%%i" "!destPath!!extension!" >nul 2>nul
    )
    set /a fileCounter+=1
)

echo Files/folders with the name %nameToCopy% have been copied to %destFolder%.
echo.
timeout /t 1 > nul
endlocal
goto menu


:delete_old_files_and_folders
echo You have selected menu 2. Delete files/folders outside date range

@echo off
setlocal EnableDelayedExpansion

set /p source_folder=Enter the source folder path:
set /p start_date=Enter the start date (DD/MM/YYYY):
set /p end_date=Enter the end date (DD/MM/YYYY):

set "start_year=!start_date:~6,4!"
set "start_month=!start_date:~3,2!"
set "start_day=!start_date:~0,2!"
set "start_date=!start_year!!start_month!!start_day!"

set "end_year=!end_date:~6,4!"
set "end_month=!end_date:~3,2!"
set "end_day=!end_date:~0,2!"
set "end_date=!end_year!!end_month!!end_day!"

set file_count=0
set folder_count=0

echo Searching for files and folders outside the date range %start_date% to %end_date%...

for /f "delims=" %%a in ('dir /s /b /a-d "%source_folder%"') do (
    set "file_date=%%~ta"
    set "file_year=!file_date:~6,4!"
    set "file_month=!file_date:~0,2!"
    set "file_day=!file_date:~3,2!"
    set "file_date=!file_year!!file_month!!file_day!"
    if "!file_date!" lss "%start_date%" (
        set /a "file_count+=1"
        del /q "%%a"
    ) else if "!file_date!" gtr "%end_date%" (
        set /a "file_count+=1"
        del /q "%%a"
    )
)

for /f "delims=" %%b in ('dir /s /b /ad "%source_folder%"') do (
    set "folder_date=%%~tb"
    set "folder_year=!folder_date:~6,4!"
    set "folder_month=!folder_date:~0,2!"
    set "folder_day=!folder_date:~3,2!"
    set "folder_date=!folder_year!!folder_month!!folder_day!"
    if "!folder_date!" lss "%start_date%" (
        set /a "folder_count+=1"
        rmdir /s /q "%%b"
    ) else if "!folder_date!" gtr "%end_date%" (
        set /a "folder_count+=1"
        rmdir /s /q "%%b"
    )
)

echo %file_count% files deleted.
echo %folder_count% folders deleted.
echo.
timeout /t 1 > nul
endlocal
goto :menu

:delete__filesfolders_by_name
echo You have selected menu 3. Delete file folders by name
set /p "folder_path=Enter the folder path: "
echo %folder_path%

set /p "name_to_delete=Enter the name delete: "
echo %name_to_delete%

set /p "condition=Enter the condition 1.Specific(a) or 2.Partial(*a) or 3.Partial(a*) or 4.Partial(*a*) or 5.Partial(*.a): "


set "deleted_folders=0"
set "deleted_files=0"

if "%condition%" == "1" (
for /d /r "%folder_path%" %%d IN (*) DO (
    if /i "%%~nxd"=="%name_to_delete%" (
        rd /s /q "%%d" && set /a "deleted_folders+=1"
    )
)


for /r "%folder_path%" %%f IN ("%name_to_delete%.*") DO (
    if /i "%%~nxf" neq "%name_to_delete%.%%~xf" (
        del /f /q "%%f" && set /a "deleted_files+=1"
    )
)

) else if "%condition%" == "2" (
    for /d /r "%folder_path%" %%d IN ("*%name_to_delete%") DO (
    rd /s /q "%%d" && set /a "deleted_folders+=1"
)


for /r "%folder_path%" %%f IN ("*%name_to_delete%.*") DO (
    if /i "%%~nxf" neq "%name_to_delete%.%%~xf" (
        del /f /q "%%f" && set /a "deleted_files+=1"
    )
)

) else if "%condition%" == "3" (
    for /d /r "%folder_path%" %%d IN ("%name_to_delete%*") DO (
    rd /s /q "%%d" && set /a "deleted_folders+=1"
    )


    for /r "%folder_path%" %%f IN ("%name_to_delete%*.*") DO (
    if /i "%%~nxf" neq "%name_to_delete%.%%~xf" (
        del /f /q "%%f" && set /a "deleted_files+=1"
    )
)

) else if "%condition%" == "4" (
    for /d /r "%folder_path%" %%d IN ("*%name_to_delete%*") DO (
    rd /s /q "%%d" && set /a "deleted_folders+=1"
)


for /r "%folder_path%" %%f IN ("*%name_to_delete%*.*") DO (
    if /i "%%~nxf" neq "%name_to_delete%.%%~xf" (
        del /f /q "%%f" && set /a "deleted_files+=1"
    )
)

) else if "%condition%" == "5" (

for /r "%folder_path%" %%f IN ("*.%name_to_delete%") DO (
    if /i "%%~nxf" neq "%name_to_delete%.%%~xf" (
        del /f /q "%%f" && set /a "deleted_files+=1"
    )
)

) else (
    echo Invalid condition. Please try again.
    timeout /t 2 > nul
    endlocal
    goto delete__filesfolders_by_name
)

echo %deleted_folders% folders and %deleted_files% files deleted.

echo.
timeout /t 1 > nul
goto menu

:delete_empty_folders_and_subfolders
echo You have selected menu 4. Delete Empty Folders and Subfolders
@echo off
setlocal enabledelayedexpansion

set /p "folder_path=Enter the folder path: "

set "deleted_dirs=0"

for /f "delims=" %%i in ('dir /s /b /ad "%folder_path%" ^| sort /r') do (
    rd /q "%%i" 2>nul
    if not exist "%%i" set /a "deleted_dirs+=1"
)

echo %deleted_dirs% empty directories have been deleted.

echo.
timeout /t 1 > nul
endlocal
goto menu