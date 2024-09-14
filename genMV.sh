#!/bin/bash

# Détecter le système d'exploitation
OS=$(uname -s)

# Afficher le système détecté
echo "Système détecté : $OS"

# Chemin vers VBoxManage pour Linux ou Windows
if [[ "$OS" == "Linux" ]]; then
    VBOXMANAGE="VBoxManage"
elif [[ "$OS" == MINGW* ]] || [[ "$OS" == MSYS* ]] || [[ "$OS" == CYGWIN* ]] || [[ "$OS" == MINGW64_NT* ]]; then
    VBOXMANAGE="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
else
    echo "Système non pris en charge : $OS"
    exit 1
fi

# Vérifier si VirtualBox est lancé
function check_virtualbox_open {
    if [[ "$OS" == "Linux" ]]; then
        if pgrep -x "VirtualBox" > /dev/null; then
            echo "VirtualBox est déjà lancé."
        else
            echo "VirtualBox n'est pas lancé."
            read -p "Voulez-vous lancer VirtualBox ? (O/N): " choix
            if [[ "$choix" == "O" || "$choix" == "o" ]]; then
                echo "Lancement de VirtualBox..."
                VirtualBox &
            else
                echo "Vous avez choisi de ne pas lancer VirtualBox."
            fi
        fi
    else
        tasklist | grep -i "VirtualBox.exe" > /dev/null
        if [[ $? -eq 0 ]]; then
            echo "VirtualBox est déjà lancé."
        else
            echo "VirtualBox n'est pas lancé."
            read -p "Voulez-vous lancer VirtualBox ? (O/N): " choix
            if [[ "$choix" == "O" || "$choix" == "o" ]]; then
                echo "Lancement de VirtualBox..."
                start "" "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe"
                sleep 5
            else
                echo "Vous avez choisi de ne pas lancer VirtualBox."
            fi
        fi
    fi
}

# Fonction pour lister les machines virtuelles avec leurs métadonnées
function list_vms {
    echo "Liste des machines virtuelles :"
    vms=$("$VBOXMANAGE" list vms)

    if [[ -z "$vms" ]]; then
        echo "Aucune machine virtuelle trouvée."
        return
    fi

    while read -r vm; do
        vm_name=$(echo "$vm" | cut -d'"' -f2)

        echo "VM : $vm_name"

        # Récupérer la date de création et le créateur
        creation_date=$("$VBOXMANAGE" getextradata "$vm_name" enumerate | grep "creation_date" | cut -d',' -f2 | cut -d' ' -f2-)
        creator=$("$VBOXMANAGE" getextradata "$vm_name" enumerate | grep "creator" | cut -d',' -f2 | cut -d' ' -f2-)

        # Obtenir les informations de la dernière connexion (allumage)
        last_start=$("$VBOXMANAGE" showvminfo "$vm_name" --machinereadable | grep "VMStateChangeTime=" | cut -d'=' -f2 | tr -d '"')

        # Afficher les informations si elles sont disponibles
        if [[ -n "$creation_date" ]]; then
            echo "Date de création : $creation_date"
        else
            echo "Date de création : non disponible"
        fi

        if [[ -n "$last_start" ]]; then
            echo "Dernière connexion (allumage) : $last_start"
        else
            echo "Dernière connexion : non disponible"
        fi

        if [[ -n "$creator" ]]; then
            echo "Créateur : $creator"
        else
            echo "Créateur : non disponible"
        fi

        echo "----------------------------------"
    done <<< "$vms"
}


# Fonction pour créer une nouvelle VM
function create_vm {
    while true; do
        read -p "Entrez le nom de la machine (format: Rôle-Localisation-Numéro): " VM_NAME

        # Vérification si une machine avec ce nom existe déjà
        existing_vm=$("$VBOXMANAGE" list vms | grep "\"$VM_NAME\"")
        if [[ -n "$existing_vm" ]]; then
            echo "Erreur : Une machine avec ce nom existe déjà."
            echo "Veuillez entrer un nouveau nom pour la machine."
            continue # Demander un autre nom
        fi

        # Vérification du format du nom
        if [[ ${#VM_NAME} -gt 15 ]]; then
            echo "Erreur : Le nom de la machine ne doit pas dépasser 15 caractères."
            continue
        fi

        if [[ ! "$VM_NAME" =~ ^[A-Za-z0-9_-]+$ ]]; then
            echo "Erreur : Le nom de la machine doit respecter la syntaxe : Rôle-Localisation-Numéro."
            continue
        fi

        break
    done

    # Vérification que la RAM est un entier
    while true; do
        read -p "Taille de la RAM (en MB, ex : 1024) : " RAM_SIZE
        if [[ ! "$RAM_SIZE" =~ ^[0-9]+$ ]]; then
            echo "Erreur : La taille de la RAM doit être un nombre entier."
            continue
        fi
        break
    done

    # Vérification que la taille du disque est un entier
    while true; do
        read -p "Taille du disque dur (en Go, ex : 32) : " HDD_SIZE
        if [[ ! "$HDD_SIZE" =~ ^[0-9]+$ ]]; then
            echo "Erreur : La taille du disque dur doit être un nombre entier."
            continue
        fi
        break
    done

    # Vérification que le nombre de CPU est un entier
    while true; do
        read -p "Nombre de CPU (ex : 2) : " CPU_COUNT
        if [[ ! "$CPU_COUNT" =~ ^[0-9]+$ ]]; then
            echo "Erreur : Le nombre de CPU doit être un nombre entier."
            continue
        fi
        break
    done

    read -p "Entrez le nom du créateur : " CREATOR_NAME

    echo "Récapitulatif des informations :"
    echo "Nom de la machine : $VM_NAME"
    echo "Taille de la RAM : $RAM_SIZE MB"
    echo "Taille du disque dur : $HDD_SIZE Go"
    echo "Nombre de CPU : $CPU_COUNT"
    echo "Créateur : $CREATOR_NAME"

    read -p "Confirmer la création de la machine ? (O/N) : " CONFIRMATION
    if [[ "$CONFIRMATION" != "O" && "$CONFIRMATION" != "o" ]]; then
        echo "Annulation de la création de la machine."
        return
    fi
# 
    # Création de la machine virtuelle
    echo "Création de la machine virtuelle $VM_NAME..."
    "$VBOXMANAGE" createvm --name "$VM_NAME" --ostype "Debian_64" --register
    "$VBOXMANAGE" modifyvm "$VM_NAME" --memory "$RAM_SIZE" --cpus "$CPU_COUNT" --nic1 nat --boot1 net
    "$VBOXMANAGE" createmedium disk --filename "$VM_NAME"_disk.vdi --size "$HDD_SIZE"
    "$VBOXMANAGE" storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAHCI
    "$VBOXMANAGE" storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_NAME"_disk.vdi

    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    "$VBOXMANAGE" setextradata "$VM_NAME" "creation_date" "$DATE"
    "$VBOXMANAGE" setextradata "$VM_NAME" "creator" "$CREATOR_NAME"

    echo "VM $VM_NAME créée avec succès à $DATE par $CREATOR_NAME."
}

# Fonction pour supprimer une VM
function delete_vm {
    read -p "Entrez le nom de la machine à supprimer: " VM_NAME
    "$VBOXMANAGE" unregistervm "$VM_NAME" --delete
    echo "VM $VM_NAME supprimée avec succès."
}

# Fonction pour démarrer une VM
function start_vm {
    read -p "Entrez le nom de la machine à démarrer: " VM_NAME
    "$VBOXMANAGE" startvm "$VM_NAME"
    echo "VM $VM_NAME démarrée."
}

# Fonction pour arrêter une VM
function stop_vm {
    read -p "Entrez le nom de la machine à arrêter: " VM_NAME
    "$VBOXMANAGE" controlvm "$VM_NAME" poweroff
    echo "VM $VM_NAME arrêtée."
}

### Fonction du menu
function menu {
    echo
    echo "Utilisation :"
    echo "L: Lister les machines virtuelles"
    echo "N: Créer une nouvelle machine virtuelle"
    echo "S: Supprimer une machine virtuelle"
    echo "D: Démarrer une machine virtuelle"
    echo "A: Arrêter une machine virtuelle"
    echo "Q: Quitter"
    read -p "Sélectionnez une option: " option

    case $option in
        L|l) list_vms ;;
        N|n) create_vm ;;
        S|s) delete_vm ;;
        D|d) start_vm ;;
        A|a) stop_vm ;;
        Q|q) exit 0 ;;
        *) echo "Option invalide." ;;
    esac
}

# Ajout des arguments en ligne de commande
if [[ $# -gt 0 ]]; then
    case $1 in
        L|l) list_vms ;;
        N|n) create_vm ;;
        S|s) delete_vm ;;
        D|d) start_vm ;;
        A|a) stop_vm ;;
        *) echo "Option invalide." ;;
    esac
    exit 0
fi

## Lancer la vérification de VirtualBox
check_virtualbox_open

# Boucle de menu
while true; do
    menu
done

read -p "Appuyez sur Entrée pour quitter..."


