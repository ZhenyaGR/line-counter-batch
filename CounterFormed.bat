@echo off
chcp 65001 >nul

:loop
setlocal enabledelayedexpansion
cls

set /P "directory=Введите директорию*: "
set /P "extensions=Введите расширения (через запятую, например: txt,bat,cmd)*: "
set /P "ignore_dirs=Введите директории для игнора (через запятую, например: temp,backup): "

:: Переменная с кучей пробелов для форматирования (60 пробелов хватит)
set "SPACES=                                                            "

:: общий счётчики
set /a total_lines=0
set /a total_lines_empty=0
set /a total_file=0

:: разбиваем список расширений и игнорируемые директории
set "ext_list=%extensions:,= %"
set "dirs_to_ignore=%ignore_dirs%"
if defined dirs_to_ignore set "dirs_to_ignore=!dirs_to_ignore:,= !"

for %%E in (!ext_list!) do (
    echo.
    echo ===============================================================================  
    echo ^| Название файла                      ^| С пустыми строками ^| Без пустых строк ^|  
    echo ===============================================================================  

    rem перебираем файлы
    for /r "%directory%" %%F in (*.%%E) do (
        set "ignore_file="
        set "file_path=%%~dpF"
        
        rem Проверка на игнор директорий
        if defined dirs_to_ignore (
            for %%D in (!dirs_to_ignore!) do (
                if /i "!file_path:%%D=!" neq "!file_path!" (
                    set "ignore_file=1"
                )
            )
        )

        if not "%%~xF"==".%extensions%~" if not defined ignore_file (
            set "filename=%%~nxF"
            set /a line_count=0
            set /a line_count_empty=0

            rem Считаем строки.
            rem ВАЖНО: Сам запуск findstr занимает время для каждого файла. 
            rem В Batch это узкое место, которое нельзя убрать без перехода на PowerShell.
            for /f %%A in ('type "%%F" ^| find /c /v ""') do set line_count=%%A
            
            rem Считаем непустые (через findstr regex)
            for /f %%A in ('findstr /R /N "." "%%F" ^| find /c ":"') do set line_count_empty=%%A
            
            rem === МГНОВЕННОЕ ФОРМАТИРОВАНИЕ ===
            
            rem 1. Имя файла (выравнивание ВЛЕВО, ширина 35)
            rem Добавляем пробелы справа, потом берем первые 35 символов
            set "fmt_name=!filename!!SPACES!"
            set "fmt_name=!fmt_name:~0,35!"

            rem 2. Строки всего (выравнивание ВПРАВО, ширина 19)
            rem Добавляем пробелы слева, потом берем последние 19 символов
            set "fmt_count=!SPACES!!line_count!"
            set "fmt_count=!fmt_count:~-19!"

            rem 3. Строки непустые (выравнивание ВПРАВО, ширина 17)
            set "fmt_empty=!SPACES!!line_count_empty!"
            set "fmt_empty=!fmt_empty:~-17!"

            echo ^| !fmt_name! ^|!fmt_count! ^|!fmt_empty! ^|

            set /a total_lines+=line_count
            set /a total_lines_empty+=line_count_empty
            set /a total_file+=1
        )
    )
)

echo ===============================================================================

rem === Форматирование итогов ===

rem Всего файлов (ВПРАВО, ширина 62)
set "fmt_total_file=!SPACES!!total_file!"
set "fmt_total_file=!fmt_total_file:~-62!"

rem Всего с пустыми (ВПРАВО, ширина 50)
set "fmt_total_lines=!SPACES!!total_lines!"
set "fmt_total_lines=!fmt_total_lines:~-50!"

rem Всего без пустых (ВПРАВО, ширина 52)
set "fmt_total_empty=!SPACES!!total_lines_empty!"
set "fmt_total_empty=!fmt_total_empty:~-52!"

echo ^| ИТОГО:								      ^|
echo ^| Всего файлов: !fmt_total_file!^|
echo ^| Всего с пустыми строками: !fmt_total_lines!^|
echo ^| Всего без пустых строк: !fmt_total_empty!^|
echo ===============================================================================

echo.
echo.
echo.
endlocal
pause
goto :loop
