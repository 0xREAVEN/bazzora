#!/usr/bin/env bash
set -oue pipefail

echo "=== Début du nettoyage complet de Bazzite (Debloat Bazzora) ==="

echo "1. Suppression complète des extensions GNOME préinstallées..."
rm -rf /usr/share/gnome-shell/extensions/*

echo "2. Nettoyage et remplacement des schémas d'overrides glib..."
# Supprime les overrides Bazzite (dash, dossiers, extensions, thème)
rm -f /usr/share/glib-2.0/schemas/zz0-01-bazzite-desktop-silverblue-dash.gschema.override
rm -f /usr/share/glib-2.0/schemas/zz0-02-bazzite-desktop-silverblue-folders.gschema.override
rm -f /usr/share/glib-2.0/schemas/zz0-03-bazzite-desktop-silverblue-extensions.gschema.override
rm -f /usr/share/glib-2.0/schemas/zz0-04-bazzite-desktop-silverblue-theme.gschema.override
find /usr/share/glib-2.0/schemas/ -type f \( -name "*compiz*.override" -o -name "*logomenu*.override" \) -exec rm -vf {} +

# Override du dock GNOME (favoris épurés sans icônes orphelines Lutris/Bazaar/Yafti)
cat << 'EOF' > /usr/share/glib-2.0/schemas/zz0-01-bazzora-dash.gschema.override
[org.gnome.shell]
favorite-apps=['org.mozilla.firefox.desktop', 'steam.desktop', 'org.gnome.Ptyxis.desktop', 'org.gnome.Nautilus.desktop']
EOF

# Override des dossiers d'applications GNOME (suppression du dossier Waydroid)
cat << 'EOF' > /usr/share/glib-2.0/schemas/zz0-02-bazzora-folders.gschema.override
[org.gnome.desktop.app-folders]
folder-children=['Games', 'GamingUtilities', 'Utilities', 'Containers', 'Wine', 'YaST', 'Pardus']
EOF

# Création de l'override de thème Bazzora épuré
cat << 'EOF' > /usr/share/glib-2.0/schemas/zz0-04-bazzora-theme.gschema.override
[org.gnome.desktop.interface]
color-scheme='prefer-dark'
enable-hot-corners=false
document-font-name='Noto Sans 11'
font-name='Noto Sans 11'
monospace-font-name='Fira Code weight=450 10'

[org.gnome.mutter]
center-new-windows=true

[org.gnome.desktop.wm.preferences]
button-layout='appmenu:minimize,maximize,close'

[org.gnome.desktop.background]
color-shading-type='solid'
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/bazzora/background.png'
picture-uri-dark='file:///usr/share/backgrounds/bazzora/background.png'
primary-color='#202646'
secondary-color='#36438E'

[org.gnome.desktop.screensaver]
color-shading-type='solid'
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/bazzora/background.png'
primary-color='#202646'
secondary-color='#36438E'
EOF

# Recompilation des schémas glib
glib-compile-schemas /usr/share/glib-2.0/schemas/

echo "3. Nettoyage de la configuration dconf..."
# Supprime les règles dconf liées aux extensions Bazzite et anciens dossiers
rm -f /etc/dconf/db/distro.d/*compiz* 2>/dev/null || true
rm -f /etc/dconf/db/distro.d/00-bazzite-desktop-silverblue-global 2>/dev/null || true
rm -f /etc/dconf/db/distro.d/01-bazzite-desktop-silverblue-folders 2>/dev/null || true

# Configuration des raccourcis claviers propres (Ctrl+Alt+T pour Ptyxis, Ctrl+Shift+Esc pour Mission Center)
cat << 'EOF' > /etc/dconf/db/distro.d/00-bazzora-global
[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
binding='<Control><Alt>t'
command='ptyxis --new-window'
name='Terminal'

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1]
binding='<Control><Alt>KP_Delete'
command='flatpak run io.missioncenter.MissionCenter'
name='Mission Center'

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2]
binding='<Control><Shift>Escape'
command="flatpak run io.missioncenter.MissionCenter"
name='Mission Center'
EOF

# Configuration des dossiers d'applications épurés dans dconf (sans Waydroid ni paquets supprimés)
cat << 'EOF' > /etc/dconf/db/distro.d/01-bazzora-folders
[org/gnome/desktop/app-folders/folders/GamingUtilities]
apps=['com.github.Matoking.protontricks.desktop', 'discover_overlay_configure.desktop', 'com.vysp3r.ProtonPlus.desktop', 'io.github.benjamimgois.goverlay.desktop', 'com.gerbilsoft.rom-properties.rp-config.desktop', 'input-remapper-gtk.desktop', 'steamos-nested-desktop.desktop', 'dev.lizardbyte.app.Sunshine.desktop', 'io.github.radiolamp.mangojuice.desktop']
name='Gaming Utilities'
translate=false

[org/gnome/desktop/app-folders/folders/Pardus]
categories=['X-Pardus-Apps']
name='X-Pardus-Apps.directory'
translate=true

[org/gnome/desktop/app-folders/folders/Utilities]
apps=['system-update.desktop', 'tuned-gui.desktop', 'rog-control-center.desktop', 'fish.desktop', 'nvtop.desktop', 'btop.desktop', 'com.github.tchx84.Flatseal.desktop', 'io.github.flattool.Warehouse.desktop', 'it.mijorus.gearlever.desktop', 'com.mattjakeman.ExtensionManager.desktop', 'org.gnome.tweaks.desktop', 'com.github.GradienceTeam.Gradience', 'io.github.fastrizwaan.WineZGUI.desktop', 'setroubleshoot.desktop', 'org.rncbc.qsynth.desktop', 'de.leopoldluley.Clapgrep.desktop', 'org.virt_manager.virt-manager.desktop', 'io.github.flattool.Ignition.desktop', 'firewall-config.desktop', 'org.freedesktop.MalcontentControl.desktop', 'page.tesk.Refine.desktop', 'bbrew.desktop', 'org.gnome.Firmware.desktop']
categories=['X-GNOME-Utilities']
name='X-GNOME-Utilities.directory'
translate=true

[org/gnome/desktop/app-folders/folders/Containers]
apps=['io.github.dvlv.boxbuddyrs.desktop', 'com.ranfdev.DistroShelf.desktop', 'io.podman_desktop.PodmanDesktop.desktop', 'com.github.marhkb.Pods.desktop']
categories=['Distrobox']
name='Containers'
translate=false

[org/gnome/desktop/app-folders/folders/YaST]
categories=['X-SuSE-YaST']
name='suse-yast.directory'
translate=true

[org/gnome/desktop/app-folders/folders/Wine]
apps=['winetricks.desktop']
categories=['X-Wine', 'wine-wine']
name='Wine'
translate=false

[org/gnome/desktop/app-folders/folders/Games]
excluded-apps=['steam.desktop', 'io.github.benjamimgois.goverlay.desktop', 'com.vysp3r.ProtonPlus.desktop', 'io.github.fastrizwaan.WineZGUI.desktop']
categories=['Game']
name='Games'
translate=false
EOF

dconf update 2>/dev/null || true

# Nettoyage de la sauvegarde dconf de Bazzite
rm -rf /usr/share/ublue-os/dconfs/desktop-silverblue/* 2>/dev/null || true

echo "4. Nettoyage de l'autostart et des alias de shell..."
# Suppression de l'autostart pour bazzite-portal / yafti (qui a été retiré)
rm -f /etc/skel/.config/autostart/bazzite-portal.desktop

# Suppression des alias forcés de Fastfetch pour bash et fish
rm -f /etc/profile.d/bazzite-neofetch.sh
rm -f /usr/share/fish/vendor_conf.d/bazzite-neofetch.fish

# Configuration de Fish comme shell par défaut pour les futurs utilisateurs
sed -i 's|SHELL=/bin/bash|SHELL=/usr/bin/fish|' /etc/default/useradd 2>/dev/null || true

echo "5. Suppression des fonds d'écran et branding Bazzite/Steam Deck..."
rm -rf /usr/share/wallpapers/*
rm -rf /usr/share/backgrounds/bazzite*
rm -rf /usr/share/backgrounds/convergence*
rm -rf /usr/share/backgrounds/steamdeck*
rm -rf /usr/share/backgrounds/giants*
rm -rf /usr/share/backgrounds/ublue*
rm -rf /usr/share/gnome-background-properties/*

# Déclaration du wallpaper Bazzora dans les paramètres d'arrière-plan de GNOME
if [ -f "/usr/share/backgrounds/bazzora/background.png" ]; then
    echo "Configuration du fond d'écran Bazzora..."
    ln -sf /usr/share/backgrounds/bazzora/background.png /usr/share/backgrounds/default.png
    ln -sf /usr/share/backgrounds/bazzora/background.png /usr/share/backgrounds/default-dark.png

    cat << 'EOF' > /usr/share/gnome-background-properties/bazzora.xml
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
    <wallpaper deleted="false">
        <name>Bazzora</name>
        <filename>/usr/share/backgrounds/bazzora/background.png</filename>
        <filename-dark>/usr/share/backgrounds/bazzora/background.png</filename-dark>
        <options>zoom</options>
        <shade_type>solid</shade_type>
        <pcolor>#202646</pcolor>
        <scolor>#36438E</scolor>
    </wallpaper>
</wallpapers>
EOF
fi

echo "6. Neutralisation sécurisée des recettes ujust devenues obsolètes..."
# On vide les fichiers sans les supprimer pour préserver les déclarations 'import' de /usr/share/ublue-os/justfile
echo "# Debloated by Bazzora" > /usr/share/ublue-os/just/82-bazzite-waydroid.just
echo "# Debloated by Bazzora" > /usr/share/ublue-os/just/82-bazzite-cockpit.just
echo "# Debloated by Bazzora" > /usr/share/ublue-os/just/82-bazzite-beesd.just
echo "# Debloated by Bazzora" > /usr/share/ublue-os/just/90-bazzite-de.just

echo "7. Suppression des raccourcis d'applications obsolètes ou indésirables..."
# Raccourcis résiduels Waydroid (Force Restart, Market, etc.)
rm -f /usr/share/applications/*waydroid*.desktop /usr/share/applications/Waydroid*.desktop

# Liens web Bazzite (Documentation, Discourse, Landing)
rm -f /usr/share/applications/bazzite-documentation.desktop
rm -f /usr/share/applications/bazzite-landing.desktop
rm -f /usr/share/applications/discourse.desktop

# Aide GNOME (Yelp)
rm -f /usr/share/applications/org.gnome.Yelp.desktop
rm -f /usr/share/applications/*yelp*.desktop

# Outils debloatés (Btrfs Assistant, Orca autostart)
rm -f /usr/share/applications/btrfs-assistant.desktop
rm -f /usr/share/applications/orca.desktop
rm -f /etc/xdg/autostart/orca-autostart.desktop

# Nettoyage de l'updater graphique Bazzite
rm -f /usr/share/applications/io.github.rfrench3.bazzite-updater.desktop

echo "=== Debloat Bazzora terminé avec succès ==="
