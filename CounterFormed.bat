@echo off
chcp 65001 >nul

:loop
setlocal enabledelayedexpansion
cls

set /P "directory=Введите директорию*: "
set /P "extensions=Введите расширения (через запятую, например: txt,bat,cmd)*: "
set /P "ignore_dirs=Введите директории для игнора (через запятую, например: temp,backup): "

:: общий счётчики
set /a total_lines=0
set /a total_lines_empty=0
set /a total_file=0

:: разбиваем список расширений и игнорируемые директории
set "ext_list=%extensions:,= %"
set "dirs_to_ignore=%ignore_dirs%"
set "dirs_to_ignore=!dirs_to_ignore:,= !"

for %%E in (!ext_list!) do (
    echo.
    echo ===============================================================================  
    echo ^| Название файла                      ^| С пустыми строками ^| Без пустых строк ^|  
    echo ===============================================================================  

    rem перебираем только *.%%E, чтобы не захватывать файлы с суффиксом ~
    for /r "%directory%" %%F in (*.%%E) do (
        rem пропускаем файлы в игнорируемых директориях
        set "ignore_file="
        set "file_path=%%~dpF"
        for %%D in (!dirs_to_ignore!) do (
            if /i "!file_path:%%D=!" neq "!file_path!" (
                set "ignore_file=1"
            )
        )

        if not "%%~xF"==".%extensions%~" if not defined ignore_file (
            set "filename=%%~nxF"
            set /a line_count=0
            set /a line_count_empty=0

            rem считаем все строки (включая пустые)
            for /f "delims=" %%A in ('findstr /R /N "^" "%%F" ^| find /c ":"') do set line_count=%%A
            rem считаем только непустые строки
            for /f "delims=" %%A in ('findstr /R /N "." "%%F" ^| find /c ":"') do set line_count_empty=%%A

            rem выравнивание по столбцам
            call :strlen "!filename!" strlenName
            call :spaces "!strlenName!" 35 spacesName

            call :strlen "!line_count!" strlenCount
            call :spaces "!strlenCount!" 19 spacesCount

            call :strlen "!line_count_empty!" strlenEmpty
            call :spaces "!strlenEmpty!" 17 spacesEmpty

            echo ^| !filename!!spacesName! ^|!spacesCount!!line_count! ^|!spacesEmpty!!line_count_empty! ^|

            set /a total_lines+=line_count
            set /a total_lines_empty+=line_count_empty
            set /a total_file+=1
        )
    )
)

echo ===============================================================================

call :strlen "!total_file!" strlenFile
call :spaces "!strlenFile!" 62 spacesFile

call :strlen "!total_lines_empty!" strlenTotalEmpty
call :spaces "!strlenTotalEmpty!" 50 spacesTotalEmpty

call :strlen "!total_lines!" strlenTotalLines
call :spaces "!strlenTotalLines!" 52 spacesTotalLines

echo ^| ИТОГО:								      ^|
echo ^| Всего файлов: !total_file!!spacesFile!^|
echo ^| Всего с пустыми строками: !total_lines_empty!!spacesTotalEmpty!^|
echo ^| Всего без пустых строк: !total_lines!!spacesTotalLines!^|
echo ===============================================================================

echo.
echo.
echo.
endlocal
pause
goto :loop

:strlen
setlocal enabledelayedexpansion
set "str=%~1"
set /a len=0
:strlen_loop
    set "ch=!str:~%len%,1!"
    if defined ch (
        set /a len+=1
        goto :strlen_loop
    )
endlocal & set "%~2=%len%"
goto :eof

:spaces
setlocal enabledelayedexpansion
set /a input=%~1, minus=%~2, count=minus-input
if !count! LSS 0 set /a count=0
set "result="
:spaces_loop
    if !count! LEQ 0 goto :spaces_done
    set "result=!result! "
    set /a count-=1
    goto spaces_loop
:spaces_done
endlocal & set "%~3=%result%"
goto :eof
