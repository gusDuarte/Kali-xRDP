# Stop vcxsrv proccess that contains "0.0" in the program window title
get-process vcxsrv | where { `$_.mainwindowtitle -like "*0.0*" } | stop-process
# Start vcxsrv process in a large program window on display number one
start-process "c:\program files\vcxsrv\vcxsrv.exe" -argument ":0.0 -ac -nowgl -multimonitors -dpms"