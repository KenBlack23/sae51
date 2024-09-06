@echo off

set VM_NAME=Debian1
set RAM_SIZE=4096
set HDD_SIZE=64000

:: Création de la machine virtuelle
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createvm --name %VM_NAME% --ostype "Debian_64" --register
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm %VM_NAME% --memory %RAM_SIZE% --nic1 nat --boot1 net
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createmedium disk --filename "%VM_NAME%_disk.vdi" --size %HDD_SIZE%
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storagectl %VM_NAME% --name "SATA Controller" --add sata --controller IntelAHCI
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach %VM_NAME% --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "%VM_NAME%_disk.vdi"

:: Pause pour vérifier la création
pause

:: Suppression de la machine virtuelle
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" unregistervm %VM_NAME% --delete

