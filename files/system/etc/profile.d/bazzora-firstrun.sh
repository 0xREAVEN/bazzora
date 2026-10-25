# shellcheck shell=bash
# Auto-initialisation de l'environnement Bazzora au premier lancement d'un terminal (post-rebase).
# Fichier sourcé par les shells interactifs : aucun exec, aucune commande bloquante.

if [ -n "${BASH_VERSION:-}" ] && [[ $- == *i* ]] && [ -t 0 ]; then
    # v2 : migration Fish -> Bash (rejoue l'initialisation pour les utilisateurs déjà initialisés)
    if [ ! -f "$HOME/.config/bazzora-initialized-v2" ]; then
        mkdir -p "$HOME/.config"

        # Déploiement des configurations depuis /etc/skel sans écraser l'existant
        cp --update=none /etc/skel/.config/starship.toml "$HOME/.config/" 2>/dev/null || true
        cp -r --update=none /etc/skel/.config/MangoHud "$HOME/.config/" 2>/dev/null || true
        cp -r --update=none /etc/skel/.config/scopebuddy "$HOME/.config/" 2>/dev/null || true

        if command -v gsettings >/dev/null 2>&1; then
            # Ptyxis : retour au shell de connexion (supprime l'ancienne commande /usr/bin/fish)
            PROFILE_ID=$(gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'" || true)
            if [ -n "$PROFILE_ID" ]; then
                gsettings set "org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${PROFILE_ID}/" use-custom-command false 2>/dev/null || true
            fi
            # Curseur Bibata et thème d'icônes Papirus
            gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' 2>/dev/null || true
            gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
        fi

        # Cohérence d'accès aux icônes et au curseur pour les Flatpaks utilisateur
        if command -v flatpak >/dev/null 2>&1; then
            flatpak override --user --filesystem=/usr/share/icons:ro --env=XCURSOR_PATH=/run/host/usr/share/icons 2>/dev/null || true
        fi

        # Signale un shell de connexion devenu invalide (ancien Fish)
        LOGIN_SHELL=$(getent passwd "$USER" | cut -d: -f7)
        if [ -n "$LOGIN_SHELL" ] && [ ! -x "$LOGIN_SHELL" ]; then
            echo "⚠️  Votre shell de connexion ($LOGIN_SHELL) n'existe plus : exécutez 'sudo usermod --shell /bin/bash $USER'."
        fi

        rm -f "$HOME/.config/bazzora-initialized"
        touch "$HOME/.config/bazzora-initialized-v2"
    fi
fi
