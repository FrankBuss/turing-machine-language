@echo off

if "%1" == "" goto error
if "%2" == "" goto error
if "%3" == "" goto error

.\compiler\compiler.exe %1 code.tm
.\machine\machine.exe code.tm %2 %3

echo Input tape:
type %2
echo.
echo Output tape:
type %3
echo.
echo Done - have a nice day. Thank you for using the run script(tm).
goto done

:error
echo "Usage: run.bat code.tmsl input.tape output.tape"
:done
