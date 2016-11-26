@echo off
tasklist /FI "IMAGENAME eq wwebserver.exe" 2>NUL | find /I /N "wwebserver.exe">NUL
if not "%ERRORLEVEL%"=="0" (c:\Wwebserver\wwebserver.exe /q /c /min)

c:\Windows\System32\cmd.exe /q /c start /min ProvidentTextTool_1.pl 
start chrome %CD%\ProvidentTextTool.html





