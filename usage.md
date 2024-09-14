# Script Multi-plateformes pour la Gestion de Machines Virtuelles (genMV_cross.sh)

## Description

`genMV_cross.sh` est un script multi-plateformes (Linux et Windows) permettant de gérer les machines virtuelles avec VirtualBox. Il permet de :

- Lancer virtualbox ou détecter qu'ilk est déjà lancer.
- Créer une nouvelle machine virtuelle avec des paramètres personnalisés (nom, taille de RAM, taille du disque dur, taille du CPU, etc.).
- Démarrer et arrêter les machines virtuelles.
- Supprimer une machine virtuelle.
- Lister les machines virtuelles avec leurs métadonnées (date de création, créateur, date de la dernièrre connexion).
- Automatiser l'installation via un fichier Preseed (facultatif).
- Lancer virtualbox 

Le script s'adapte à l'OS utilisé, et fonctionne à la fois sous **Linux** et **Windows** (via Git Bash, Cygwin ou MSYS2).

## Prérequis

- **VirtualBox** installé et configuré sur votre machine.
- **VBoxManage** doit être disponible dans le `PATH` ou spécifié dans le script.
- Pour **Windows**, il faut avoir installer **Git Bash**, **Cygwin** ou **MSYS2** pour exécuter le script.

## Utilisation

1. **Lancer le script :**

   - Sous Linux en utilisant la commande :
     ```bash
     genMV_cross.sh
     ```

   - Sous Windows en utilisant la commande  (via Git Bash ou Cygwin) :
     ```bash
     bash genMV_cross.sh
     ```
     > Ne pas oublier de se mettre dans le bon chemin du dossier contenant le script . 

2. **Menu d'options :** 

   Une fois lancé, le script propose plusieurs options <sub> NB: il n'est pas sensible à la casse!!!  </sub> :
   - **L** : Lister les machines virtuelles avec leurs métadonnées.
   - **N** : Créer une nouvelle machine virtuelle (demande les paramètres comme la RAM, le disque dur, etc.).
   - **S** : Supprimer une machine virtuelle existante.
   - **D** : Démarrer une machine virtuelle.
   - **A** : Arrêter une machine virtuelle.
   - **Q** : Quitter le script.

3. **Fichier Preseed (optionnel)** :
   Si vous souhaitez automatiser l'installation de Debian via un fichier Preseed, assurez-vous de définir le chemin du fichier Preseed dans le script.

   Exemple :
   ```bash
   PRESEED_PATH="~/path/to/preseed.cfg"

