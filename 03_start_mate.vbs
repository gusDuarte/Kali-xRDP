' Run PowerShell script in background
set application = createobject("shell.application")
application.shellexecute "powershell", "-file c:\users\USER_WIN\.ubuntu\01_reload_vcxsrv.ps1", "", "", 0
' Allow PowerShell script time to complete
wscript.sleep 1000
' Declare variables
dim shell_object, command_object, standard_output_string
' Check whether shell is inside the container
set shell_object = createobject("wscript.shell")

shell_object.run "wsl bash /mnt/c/users/USER_WIN/.ubuntu/02_start_mate.sh"", 0
