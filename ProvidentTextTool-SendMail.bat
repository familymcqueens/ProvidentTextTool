@echo off
c:\Windows\System32\cmd.exe /q /c start /min ProvidentTextTool-SendMail.pl 
start chrome %CD%\ProvidentTextTool-SendMail.html
taskkill /F /IM Wwebserver.exe > nul




