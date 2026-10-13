#!/usr/bin/env bash
# Auto-initialisation de l'environnement Bazzora lors du premier lancement du terminal (Post-Rebase)

if [ -n "$PS1" ] && [ -t 0 ]; then
    if [ ! -f "$HOME/.config/bazzora-initialized" ]; then
        mkdir -p "$HOME/.config"
        
        # Déploiement des configurations depuis /etc/skel
        cp -rn /etc/skel/.config/fish "$HOME/.config/" 2>/dev/null || true
        cp -n /etc/skel/.config/starship.toml "$HOME/.config/" 2>/dev/null || true
        cp -rn /etc/skel/.config/MangoHud "$HOME/.config/" 2>/dev/null || true
        cp -rn /etc/skel/.config/scopebuddy "$HOME/.config/" 2>/dev/null || true
        
        # Configuration automatique du profil Ptyxis pour lancer Fish
        if command -v gsettings >/dev/null 2>&1; then
            PROFILE_ID=$(gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'" || true)
            if [ -n "$PROFILE_ID" ]; then
                gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${PROFILE_ID}/ use-custom-command true 2>/dev/null || true
                gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${PROFILE_ID}/ custom-command '/usr/bin/fish' 2>/dev/null || true
            fi
        fi
        
        # Définition de Fish comme shell par défaut pour l'utilisateur
        if [ "$SHELL" != "/usr/bin/fish" ] && command -v chsh >/dev/null 2>&1; then
            chsh -s /usr/bin/fish "$USER" 2>/dev/null || true
        fi
        
        # Marqueur pour ne plus jamais réexécuter ce script
        touch "$HOME/.config/bazzora-initialized"
        
        # Bascule immédiate sur Fish pour ce premier lancement
        if command -v fish >/dev/null 2>&1; then
            exec /usr/bin/fish
        fi
    fi
fi
