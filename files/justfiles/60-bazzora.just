# ==================================================
# 🚀 SYSTEM & UPDATES
# ==================================================

# Ouverture et fermeture des ports pour GSConnect
setup-gsconnect:
    #!/usr/bin/bash
    set -euo pipefail
    echo -e "\033[1mConfiguration de GSConnect (Liaison Smartphone)\033[0m"
    read -p "Voulez-vous (O)uvrir ou (F)ermer les ports du pare-feu ? " choice
    case "$choice" in
        O|o)
            echo "🔓 Ouverture des ports pour GSConnect..."
            sudo firewall-cmd --permanent --add-service=kdeconnect
            sudo firewall-cmd --reload
            echo -e "✅ \033[32mPorts ouverts ! Ton PC est maintenant visible par ton téléphone.\033[0m"
            ;;
        F|f)
            echo "🔒 Fermeture des ports pour GSConnect..."
            sudo firewall-cmd --permanent --remove-service=kdeconnect
            sudo firewall-cmd --reload
            echo -e "❌ \033[31mPorts fermés. Ton PC est de nouveau invisible.\033[0m"
            ;;
        *) echo "Action annulée." ;;
    esac

# Restaure les configurations par défaut du système (/etc/skel)
restore-skel:
    #!/usr/bin/bash
    set -euo pipefail
    echo -e "\033[1mRestauration du dossier personnel (/etc/skel)\033[0m"
    echo "Le dossier /etc/skel contient les fichiers de configuration par défaut du système (ex: .bashrc, .config...)."
    echo ""
    read -p "Voulez-vous (M)anquants (copier sans écraser), (E)craser tout, ou (A)nnuler ? " choice
    case "$choice" in
        M|m)
            echo "📁 Copie uniquement des fichiers manquants..."
            cp -rn /etc/skel/. $HOME/
            echo -e "✅ \033[32mFichiers manquants restaurés ! Tes configurations actuelles n'ont pas été touchées.\033[0m"
            ;;
        E|e)
            echo "⚠️ Copie et écrasement des fichiers existants..."
            cp -r /etc/skel/. $HOME/
            echo -e "✅ \033[32mDossier personnel réinitialisé avec les paramètres par défaut !\033[0m"
            ;;
        *) echo "Action annulée." ;;
    esac

# Activer ou désactiver l'installation automatique des Flatpaks au démarrage (pour éviter le spam de notifications). Options: status | enable | disable
[group("system")]
toggle-flatpak-setup ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    
    # On cible le timer !
    SERVICE="system-flatpak-setup.timer"
    
    # Vérifier l'état actuel du timer
    if systemctl is-enabled --quiet "$SERVICE" 2>/dev/null; then
        STATUS="Enabled"
    else
        STATUS="Disabled"
    fi

    OPTION="{{ ACTION }}"
    
    if [ "$OPTION" == "help" ]; then
        echo "Utilisation : ujust toggle-flatpak-setup <option>"
        echo "  <option>: Spécifiez l'action pour passer le menu interactif"
        echo "  Utilisez 'enable' pour activer l'installation automatique au démarrage"
        echo "  Utilisez 'disable' pour désactiver l'installation automatique au démarrage"
        exit 0
    elif [ "$OPTION" == "status" ]; then
        echo "$STATUS"
        exit 0
    elif [ -z "$OPTION" ]; then
        echo "${bold}Configuration de l'installation automatique des Flatpaks${normal}"
        echo "Ce service vérifie et installe les Flatpaks manquants au démarrage."
        echo "S'il vous envoie une notification à chaque fois, vous pouvez le désactiver"
        echo "une fois l'installation initiale (ou le rebase) terminée."
        echo ""
        
        if [ "$STATUS" == "Enabled" ]; then
            echo -e "État actuel : ${green}${bold}Activé${normal}"
        else
            echo -e "État actuel : ${yellow}${bold}Désactivé${normal}"
        fi
        echo ""
        
        OPTION=$(ugum choose "Désactiver le service (Recommandé)" "Activer le service" "Quitter sans rien modifier")
    fi

    case "${OPTION}" in
        "Désactiver le service (Recommandé)"|"disable")
            echo "Désactivation du timer system-flatpak-setup..."
            sudo systemctl disable --now "$SERVICE"
            echo -e "${yellow}${bold}Désactivé !${normal} Vous n'aurez plus la notification au prochain démarrage."
            ;;
        "Activer le service"|"enable")
            echo "Activation du timer system-flatpak-setup..."
            sudo systemctl enable --now "$SERVICE"
            echo -e "${green}${bold}Activé !${normal} Le service se lancera au prochain démarrage."
            ;;
        *)
            echo "Aucune modification apportée."
            ;;
    esac

# ==================================================
# 🎮 GAMING
# ==================================================

# Force l'upgrade FSR 4
toggle-fsr4:
    #!/usr/bin/bash
    set -euo pipefail
    FILE="$HOME/.config/environment.d/99-proton-fsr4.conf"
    echo -e "\033[1mGlobal FSR4 (RDNA4)\033[0m"
    echo "Permet à Proton de forcer le FSR 4 sur les jeux compatibles (FSR 3.1+)."
    read -p "Voulez-vous (A)ctiver ou (D)ésactiver ? " choice
    case "$choice" in
        A|a)
            mkdir -p "$HOME/.config/environment.d"
            echo "PROTON_FSR4_UPGRADE=1" > "$FILE"
            echo -e "✅ \033[32mActivé\033[0m: PROTON_FSR4_UPGRADE=1"
            ;;
        D|d)
            rm -f "$FILE"
            echo -e "❌ \033[31mDésactivé\033[0m: PROTON_FSR4_UPGRADE retiré"
            ;;
        *) echo "Action annulée." ;;
    esac

# Débloque ou verrouille l'overdrive AMD GPU (ppfeaturemask) pour LACT / CoreCtrl
[group("gaming")]
toggle-amdgpu-overdrive:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    if rpm-ostree kargs | grep -q "amdgpu.ppfeaturemask=0xffffffff"; then
        STATUS="${green}${bold}Activé${normal}"
    else
        STATUS="${yellow}${bold}Désactivé${normal}"
    fi
    echo -e "État actuel de l'overdrive AMD GPU : $STATUS"
    echo "Nécessaire pour permettre à LACT ou CoreCtrl de modifier les fréquences,"
    echo "les tensions (undervolt) et les courbes de ventilation personnalisées."
    echo ""
    ACTION=$(ugum choose "Activer l'overdrive (0xffffffff)" "Désactiver l'overdrive" "Annuler")
    case "$ACTION" in
        "Activer l'overdrive (0xffffffff)")
            echo "Activation de amdgpu.ppfeaturemask=0xffffffff..."
            sudo rpm-ostree kargs --append-if-missing="amdgpu.ppfeaturemask=0xffffffff"
            echo -e "${green}${bold}Activé !${normal} Un redémarrage système est nécessaire pour appliquer."
            ;;
        "Désactiver l'overdrive")
            echo "Désactivation de amdgpu.ppfeaturemask..."
            sudo rpm-ostree kargs --delete-if-present="amdgpu.ppfeaturemask=0xffffffff"
            echo -e "${yellow}${bold}Désactivé !${normal} Un redémarrage système est nécessaire pour appliquer."
            ;;
        *) echo "Aucune modification apportée." ;;
    esac


# ==================================================
# 🍺 HOMEBREW & BBREW
# ==================================================

# Installe le wrapper bbrew
setup-brew:
    #!/usr/bin/bash
    set -euo pipefail

    echo "📦 Installation du dépôt et du paquet bbrew..."
    brew install Valkyrie00/homebrew-bbrew/bbrew

    echo -e "\n🎉 \033[32mInstallation terminée !\033[0m"
    echo "Ferme ce terminal et ouvres-en un nouveau pour utiliser la commande 'bbrew'."

# Gérer Visual Studio Code (usage: ujust manage-vscode install/uninstall)
manage-vscode action="install":
    #!/usr/bin/bash
    if [ "{{action}}" == "install" ]; then
        echo "--- Installation de VS Code via Homebrew ---"
        brew tap ublue-os/tap
        brew install --cask visual-studio-code-linux
        echo "✅ VS Code installé !"
    elif [ "{{action}}" == "uninstall" ]; then
        echo "--- Désinstallation de VS Code ---"
        brew uninstall --cask visual-studio-code-linux
        echo "🗑️ VS Code supprimé."
    else
        echo "Erreur : Utilisez 'ujust manage-vscode install' ou 'ujust manage-vscode uninstall'"
    fi
