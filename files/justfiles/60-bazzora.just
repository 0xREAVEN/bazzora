# ==================================================
# 🚀 SYSTEM & UPDATES
# ==================================================

# Nommée bazzora-update pour ne pas entrer en conflit avec « ujust update » de Bazzite.
# (ujust affiche la dernière ligne de commentaire comme description)
# Mise à jour unifiée en parallèle (système, Flatpaks, Homebrew, Distrobox) avec version de secours épinglée
[group("system")]
bazzora-update:
    #!/usr/bin/bash
    set -uo pipefail
    LOGDIR=$(mktemp -d -t bazzora-update.XXXXXX)
    echo -e "\033[1m🔄 Mise à jour unifiée Bazzora\033[0m"
    echo "Journaux détaillés : $LOGDIR"
    sudo -v || { echo "Authentification refusée."; exit 1; }
    # Maintient le ticket sudo valide pendant les tâches longues
    ( while true; do sudo -n true; sleep 50; done ) 2>/dev/null &
    KEEPALIVE=$!
    trap 'kill "$KEEPALIVE" 2>/dev/null' EXIT

    BREW=""
    if command -v brew >/dev/null 2>&1; then BREW=$(command -v brew)
    elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then BREW=/home/linuxbrew/.linuxbrew/bin/brew; fi

    declare -A PIDS
    lancer() {
        local nom=$1; shift
        ( "$@" ) >"$LOGDIR/$nom.log" 2>&1 &
        PIDS[$nom]=$!
        echo "  ▶ $nom"
    }

    # Version de secours : épingle le déploiement actuel (il fonctionne, on l'utilise) avant toute mise à jour
    if [ -x /usr/libexec/bazzora/pin-deployment ]; then
        sudo /usr/libexec/bazzora/pin-deployment || echo "⚠️  Épinglage impossible, la mise à jour continue."
    fi

    lancer systeme sudo rpm-ostree upgrade
    lancer flatpak-systeme sudo flatpak update -y --system --noninteractive
    lancer flatpak-utilisateur flatpak update -y --user --noninteractive
    [ -n "$BREW" ] && lancer homebrew bash -c "\"$BREW\" update && \"$BREW\" upgrade"
    command -v distrobox >/dev/null 2>&1 && lancer distrobox distrobox upgrade --all

    ECHECS=0
    for nom in "${!PIDS[@]}"; do
        if wait "${PIDS[$nom]}"; then
            echo -e "  ✅ $nom"
        else
            echo -e "  ❌ \033[31m$nom\033[0m (voir $LOGDIR/$nom.log)"
            ECHECS=$((ECHECS + 1))
        fi
    done

    # Nettoyage des runtimes Flatpak orphelins, une fois toutes les mises à jour terminées
    sudo flatpak uninstall --unused -y --system --noninteractive >/dev/null 2>&1 || true
    flatpak uninstall --unused -y --user --noninteractive >/dev/null 2>&1 || true

    rpm-ostree status --pending-exit-77 >/dev/null 2>&1
    if [ $? -eq 77 ]; then
        echo -e "\n🔁 \033[1mNouvelle image système installée : redémarrez pour l'appliquer.\033[0m"
    fi
    if [ "$ECHECS" -eq 0 ]; then
        echo -e "\n🎉 \033[32mTout est à jour.\033[0m"
    else
        echo -e "\n⚠️  \033[33m$ECHECS tâche(s) en échec.\033[0m"
        exit 1
    fi

# Diagnostic en lecture seule : image, GPU AMD, réglages gaming, noyau et services
[group("system")]
bazzora-doctor:
    /usr/libexec/bazzora/doctor

# Ouverture et fermeture des ports pour GSConnect
[group("system")]
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

# Restaure les configurations du système (/etc/skel), Bash et le terminal Ptyxis
[group("system")]
restore-skel:
    #!/usr/bin/bash
    set -euo pipefail
    echo -e "\033[1mInitialisation des configurations Bazzora (/etc/skel)\033[0m"
    echo "Cette commande déploie vos configurations Bash, Starship, MangoHud et configure Ptyxis."
    echo ""
    read -p "Voulez-vous (M)anquants (copier sans écraser), (E)craser tout, ou (A)nnuler ? " choice
    case "$choice" in
        M|m)
            echo "📁 Copie uniquement des fichiers manquants..."
            cp -r --update=none /etc/skel/. "$HOME/"
            echo -e "✅ \033[32mFichiers manquants restaurés !\033[0m"
            ;;
        E|e)
            echo "⚠️ Copie et écrasement des fichiers existants..."
            cp -r /etc/skel/. "$HOME/"
            echo -e "✅ \033[32mDossier personnel réinitialisé avec les paramètres Bazzora !\033[0m"
            ;;
        *)
            echo "Action annulée."
            exit 0
            ;;
    esac

    # Bash comme shell de connexion (Fish n'est plus fourni par l'image)
    LOGIN_SHELL=$(getent passwd "$USER" | cut -d: -f7)
    if [ "$LOGIN_SHELL" != "/bin/bash" ] && [ "$LOGIN_SHELL" != "/usr/bin/bash" ]; then
        echo "🐚 Définition de Bash comme shell par défaut..."
        # chsh absent de Bazzite (util-linux-user non fourni) : usermod depuis shadow-utils
        sudo usermod --shell /bin/bash "$USER" || true
    fi
    if command -v gsettings >/dev/null 2>&1; then
        PROFILE_ID=$(gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'" || true)
        if [ -n "$PROFILE_ID" ]; then
            echo "💻 Ptyxis : utilisation du shell de connexion (Bash)..."
            gsettings set "org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${PROFILE_ID}/" use-custom-command false 2>/dev/null || true
        fi
        echo "🎨 Application des thèmes Bazzora (Bibata Modern Ice & Papirus-Dark)..."
        gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
    fi
    echo -e "🎉 \033[32mBash, Starship et les thèmes sont configurés ! Fermez et rouvrez votre terminal pour appliquer.\033[0m"

# Activer ou désactiver l'installation automatique des Flatpaks au démarrage (pour éviter le spam de notifications). Options: status | enable | disable
[group("system")]
toggle-flatpak-setup ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    
    # Timers installés par le module BlueBuild default-flatpaks (v2)
    SERVICE="system-flatpak-setup.timer"
    USER_SERVICE="user-flatpak-setup.timer"
    
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
            echo "Désactivation de l'installation automatique des Flatpaks..."
            sudo systemctl disable --now "$SERVICE"
            sudo systemctl disable --global "$USER_SERVICE"
            systemctl --user disable --now "$USER_SERVICE" 2>/dev/null || true
            echo -e "${yellow}${bold}Désactivé !${normal} L'installation automatique est désactivée au démarrage."
            ;;
        "Activer le service"|"enable")
            echo "Activation de l'installation automatique des Flatpaks..."
            sudo systemctl enable --now "$SERVICE"
            sudo systemctl enable --global "$USER_SERVICE"
            echo -e "${green}${bold}Activé !${normal} Le service se lancera au prochain démarrage."
            ;;
        *)
            echo "Aucune modification apportée."
            ;;
    esac

# Nettoie les résidus Flatpak, Homebrew et le cache rpm-ostree
[group("system")]
clean-bazzora:
    #!/usr/bin/bash
    set -euo pipefail
    if flatpak list --app 2>/dev/null | grep -q "io.github.ilya_zlobintsev.LACT"; then
        echo "🗑️ Suppression de la version Flatpak de LACT (remplacée par le RPM natif)..."
        flatpak uninstall -y io.github.ilya_zlobintsev.LACT 2>/dev/null || true
    fi
    echo "🧹 Suppression des runtimes Flatpak inutilisés..."
    flatpak uninstall --unused -y
    if command -v brew >/dev/null 2>&1; then
        echo "🍺 Nettoyage du cache Homebrew..."
        brew cleanup --prune=all
    fi
    echo "📦 Nettoyage des métadonnées rpm-ostree..."
    sudo rpm-ostree cleanup -bm
    echo -e "✅ \033[32mSystème Bazzora nettoyé avec succès !\033[0m"

# ==================================================
# 🎮 GAMING & HDR
# ==================================================

# Délègue à « ujust global-fsr4 » de Bazzite (même fichier, gestion des versions de Proton à jour).
# Force l'upscaling FSR 4 (RDNA 4) sur les jeux FSR 3.1+ sous Proton. Options : enable | disable
[group("gaming")]
toggle-fsr4 ACTION="":
    #!/usr/bin/bash
    set -euo pipefail
    ujust global-fsr4 {{ ACTION }}

# Active/Désactive le HDR et Wayland natif sous Proton (sans Gamescope) ou affiche les Nits EDID de l'écran
[group("gaming")]
toggle-proton-hdr:
    #!/usr/bin/bash
    set -euo pipefail
    FILE="$HOME/.config/environment.d/99-proton-wayland-hdr.conf"
    echo -e "\033[1mProton Wayland & HDR Natif (GNOME / Mutter)\033[0m"
    echo "Active le pilote Wayland natif de Proton et le pass-through HDR direct vers Mutter."
    echo "Astuce : Réglez la luminosité SDR du bureau via le curseur du menu rapide GNOME (40-60%)."
    echo ""
    read -p "Voulez-vous (A)ctiver globalement, (D)ésactiver, ou (I)nspecter les Nits HDR de l'écran ? " choice
    case "$choice" in
        A|a)
            mkdir -p "$HOME/.config/environment.d"
            printf "PROTON_ENABLE_WAYLAND=1\nPROTON_ENABLE_HDR=1\n" > "$FILE"
            echo -e "✅ \033[32mActivé\033[0m : PROTON_ENABLE_WAYLAND=1 & PROTON_ENABLE_HDR=1"
            echo "Reconnectez votre session GNOME (ou utilisez ces variables par jeu dans Steam)."
            ;;
        D|d)
            rm -f "$FILE"
            echo -e "❌ \033[31mDésactivé\033[0m : Configuration globale Proton Wayland/HDR retirée."
            ;;
        I|i)
            echo -e "\n🔍 \033[1mMétadonnées HDR (EDID) rapportées par votre écran au noyau :\033[0m"
            if command -v drm_info >/dev/null 2>&1; then
                drm_info | grep -A 8 "HDR_OUTPUT_METADATA" || echo "Aucune métadonnée HDR active détectée."
            elif command -v gdctl >/dev/null 2>&1; then
                gdctl show || true
            else
                echo "Outil drm_info/gdctl non disponible."
            fi
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
[group("brew")]
setup-brew:
    #!/usr/bin/bash
    set -euo pipefail

    echo "📦 Installation du dépôt et du paquet bbrew..."
    brew install Valkyrie00/homebrew-bbrew/bbrew

    echo -e "\n🎉 \033[32mInstallation terminée !\033[0m"
    echo "Ferme ce terminal et ouvres-en un nouveau pour utiliser la commande 'bbrew'."

# Gérer Visual Studio Code (usage: ujust manage-vscode install/uninstall)
[group("brew")]
manage-vscode action="install":
    #!/usr/bin/bash
    set -euo pipefail
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
