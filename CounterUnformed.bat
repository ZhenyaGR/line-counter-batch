@echo off
chcp 65001 >nul
:loop
setlocal enabledelayedexpansion

cls

set /P "directory=Введите директорию*: "
set /P "extensions=Введите расширения (через запятую, например: txt,bat,cmd)*: "
set /P "ignore_dirs=Введите директории для игнора (через запятую, например: temp,backup): "

set /a total_lines=0
set /a total_lines_empty=0
set /a total_file=0

rem Преобразуем расширения и игнорируемые директории в массивы
set "ext_list=%extensions:,= %"
set "dirs_to_ignore=%ignore_dirs%"
set "dirs_to_ignore=!dirs_to_ignore:,= !"

for %%E in (!ext_list!) do (
    for /r "%directory%" %%F in (*%%E) do (
        rem Проверяем, находится ли файл в игнорируемой директории
        set "ignore_file="
        set "file_path=%%~dpF"

        for %%D in (!dirs_to_ignore!) do (
            if /i "!file_path:%%D=!" neq "!file_path!" (
                set "ignore_file=1"
            )
        )

        rem Пропускаем файлы в игнорируемых директориях
        if not "%%~xF"==".%extensions%~" if not defined ignore_file (
            set "filename=%%~nxF"
            set /a line_count=0
            set /a line_count_empty=0

            for /f "usebackq delims=" %%A in ("%%F") do (
                set /a line_count+=1
            )

            for /f %%A in ('findstr /n "^" "%%F" ^| find /c ":"') do (
                set line_count_empty=%%A
            )

            echo Количество строк в файле !filename!: !line_count! ^| !line_count_empty!

            set /a total_lines+=line_count
            set /a total_lines_empty+=line_count_empty
            set /a total_file+=1
        )
    )
)

echo {без пустых строк} ^| {с пустыми строками}
echo. 
echo Общее количество строк во всех файлах без пустых строк: !total_lines!
echo Общее количество строк во всех файлах с пустыми строками: !total_lines_empty!
echo Общее количество файлов: !total_file!

endlocal

echo. 
echo. 
echo. 

pause
goto loop
