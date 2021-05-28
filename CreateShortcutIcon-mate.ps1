# Define location variables
$shortcut_location = "$env:userprofile\Desktop\Mate.lnk"
$program_location = "$env:userprofile\.ubuntu\03_start_mate.vbs"
$icon_location = "$env:userprofile\.ubuntu\ubuntu.ico"

# Create shortcut
$object = new-object -comobject wscript.shell
$shortcut = $object.createshortcut($shortcut_location)
$shortcut.targetpath = $program_location
$shortcut.iconlocation = $icon_location
$shortcut.save()