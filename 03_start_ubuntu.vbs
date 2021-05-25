' Run PowerShell script in background
set application = createobject("shell.application")
application.shellexecute "powershell", "-file c:\users\USER_WIN\.ubuntu\01_reload_vcxsrv.ps1", "", "", 0
' Allow PowerShell script time to complete
wscript.sleep 1000
' Declare variables
dim shell_object, command_object, standard_output_string
' Check whether shell is inside the container
set shell_object = createobject("wscript.shell")
set command_object = shell_object.exec("wsl genie --is-in-bottle")
standard_output_string = command_object.stdout.readall

' Run bash script if shell is inside the container
If instr(standard_output_string, "inside") > 0 Then
  shell_object.run "bash /mnt/c/users/USER_WIN/.ubuntu/02_start_desktop.sh", 0
  ' Run bash script using genie in wsl if shell is outside the container
Else
  shell_object.run "wsl genie -c bash /mnt/c/users/USER_WIN/.ubuntu/02_start_desktop.sh", 0
End If