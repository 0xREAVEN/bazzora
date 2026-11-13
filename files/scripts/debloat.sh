#!/usr/bin/env bash
set -oue pipefail

echo "=== Début du nettoyage complet de Bazzite (Debloat Bazzora) ==="

echo "1. Nettoyage ciblé des extensions GNOME préinstallées..."
# On conserve uniquement AppIndicator (systray Steam/Heroic) et GSConnect.
# Les extensions de Bazzite (compiz, magic-lamp, logomenu, hotedge, blur-my-shell…) ne sont
# rattachées à aucun RPM : la suppression des fichiers est donc la seule méthode possible.
# Les extensions paquetées (user-theme) sont retirées proprement via le module dnf.
if [ -d /usr/share/gnome-shell/extensions ]; then
    find /usr/share/gnome-shell/extensions/ -mindepth 1 -maxdepth 1 -type d \
        ! -name "appindicatorsupport@rgcjonas.gmail.com" \
        ! -name "gsconnect@andyholmes.github.io" \
        -exec rm -rf {} +
fi

echo "2. Nettoyage et remplacement des schémas d'overrides glib..."
# Supprime les overrides Bazzite (dash, dossiers, extensions, thème)
rm -f /usr/share/glib-2.0/schemas/zz0-01-bazzite-desktop-silverblue-dash.gschema.override
rm -f /usr/share/glib-2.0/schemas/zz0-02-bazzite-desktop-silverblue-folders.gschema.override
rm -f /usr/share/glib-2.0/schemas/zz0-03-bazzite-desktop-silverblue-extensions.gschema.override
rm -f /usr/share/glib-2.0/schemas/zz0-04-bazzite-desktop-silverblue-theme.gschema.override

# Override du dock GNOME et activation par défaut du systray AppIndicator
cat << 'EOF' > /usr/share/glib-2.0/schemas/zz0-01-bazzora-dash.gschema.override
[org.gnome.shell]
favorite-apps=['org.mozilla.firefox.desktop', 'steam.desktop', 'org.gnome.Ptyxis.desktop', 'org.gnome.Nautilus.desktop']
enabled-extensions=['appindicatorsupport@rgcjonas.gmail.com']
EOF

# Override des dossiers d'applications GNOME (suppression du dossier Waydroid)
cat << 'EOF' > /usr/share/glib-2.0/schemas/zz0-02-bazzora-folders.gschema.override
[org.gnome.desktop.app-folders]
folder-children=['Games', 'GamingUtilities', 'Utilities', 'Containers', 'Wine']
EOF

# Installation du thème de curseur Bibata Modern Ice (version figée + empreinte vérifiée).
# Un téléchargement corrompu ou modifié fait échouer le build : l'image précédente reste en ligne.
# Pour mettre à jour : changer la version ET l'empreinte sha256 ensemble.
BIBATA_VERSION="v2.0.7"
BIBATA_SHA256="a68cae60c4dc706350e194ebc91c5fe48bc7bc9d59e119555834a2a7ee5078ef"
echo "Installation du curseur Bibata Modern Ice ${BIBATA_VERSION}..."
BIBATA_TMP="$(mktemp)"
curl -fsSL --retry 3 -o "$BIBATA_TMP" \
    "https://github.com/ful1e5/Bibata_Cursor/releases/download/${BIBATA_VERSION}/Bibata-Modern-Ice.tar.xz"
echo "${BIBATA_SHA256}  ${BIBATA_TMP}" | sha256sum -c -
tar -xJf "$BIBATA_TMP" -C /usr/share/icons/
rm -f "$BIBATA_TMP"
test -f /usr/share/icons/Bibata-Modern-Ice/index.theme
chmod -R u=rwX,go=rX /usr/share/icons/Bibata-Modern-Ice
# /usr/share/icons/default/index.theme est fourni par le module files (files/system)
# Les overrides Flatpak globaux sont déployés au démarrage via tmpfiles.d (voir bazzora-flatpak.conf)

# Création de l'override de thème et d'optimisations Mutter Gaming Bazzora
# check-alive-timeout n'est pas redéfini : la valeur de Bazzite (20 s, zz0-00-bazzite-desktop-silverblue-global)
# laisse le temps aux écrans de chargement tout en gardant la fenêtre « L'application ne répond pas ».
cat << 'EOF' > /usr/share/glib-2.0/schemas/zz0-04-bazzora-theme.gschema.override
[org.gnome.desktop.interface]
color-scheme='prefer-dark'
gtk-theme='adw-gtk3-dark'
icon-theme='Papirus-Dark'
cursor-theme='Bibata-Modern-Ice'
cursor-size=24
enable-hot-corners=false
document-font-name='Noto Sans 11'
font-name='Noto Sans 11'
monospace-font-name='Fira Code weight=450 10'

[org.gnome.mutter]
center-new-windows=true
# experimental-features n'est plus défini : GNOME 51 a supprimé cette clé (glib-compile-schemas --strict
# échoue sur une clé inconnue). Mise à l'échelle et VRR se règlent dans Paramètres › Écrans.

[org.gnome.desktop.peripherals.mouse]
accel-profile='flat'

[org.gnome.desktop.wm.preferences]
button-layout='appmenu:minimize,maximize,close'

[org.gnome.desktop.background]
color-shading-type='solid'
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/bazzora/background.jpg'
picture-uri-dark='file:///usr/share/backgrounds/bazzora/background.jpg'
primary-color='#202646'
secondary-color='#36438E'

[org.gnome.desktop.screensaver]
color-shading-type='solid'
picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/bazzora/background.jpg'
primary-color='#202646'
secondary-color='#36438E'
EOF

# Indexeur de fichiers GNOME (LocalSearch) : les préfixes Wine/Proton et les bibliothèques de jeux
# sont exclus. Ils contiennent des milliers d'exécutables Windows sans intérêt pour la recherche,
# réécrits en permanence par les lanceurs, et dont l'analyse a provoqué une fuite mémoire
# (localsearch 3.12). Les exclusions s'ajoutent aux valeurs par défaut de LocalSearch, lues dans
# l'image : une clé renommée en amont fait échouer le build au lieu d'être ignorée.
#   - ignored-directories-with-content : tout dossier contenant « system.reg » est un préfixe Wine ;
#   - ignored-directories : noms de dossiers (Steam, Proton, cache de shaders).
INDEXEUR=org.freedesktop.Tracker3.Miner.Files
# Ajoute des éléments à une liste GVariant de chaînes : "['a', 'b']" ou "@as []"
liste_etendue() {
    local cle=$1 defaut ajouts
    shift
    defaut=$(GSETTINGS_BACKEND=memory gsettings get "$INDEXEUR" "$cle")
    ajouts=$(printf "'%s', " "$@")
    ajouts=${ajouts%, }
    case "$defaut" in
        '@as []'|'[]') echo "[${ajouts}]" ;;
        '['*']') echo "${defaut%]}, ${ajouts}]" ;;
        *) echo "Valeur inattendue pour $cle : $defaut" >&2; return 1 ;;
    esac
}
EXCLUS_CONTENU=$(liste_etendue ignored-directories-with-content system.reg)
EXCLUS_NOMS=$(liste_etendue ignored-directories drive_c compatdata steamapps shadercache)
cat << EOF > /usr/share/glib-2.0/schemas/zz0-05-bazzora-indexeur.gschema.override
[${INDEXEUR}]
ignored-directories-with-content=${EXCLUS_CONTENU}
ignored-directories=${EXCLUS_NOMS}
EOF

# Recompilation des schémas glib
glib-compile-schemas /usr/share/glib-2.0/schemas/

echo "3. Nettoyage de la configuration dconf..."
# 00-bazzite-desktop-silverblue-global (raccourcis Ctrl+Alt+T et Mission Center) et son verrou sont
# conservés tels quels ; seuls les dossiers d'applications de Bazzite sont remplacés.
rm -f /etc/dconf/db/distro.d/01-bazzite-desktop-silverblue-folders

# Configuration des dossiers d'applications épurés dans dconf
cat << 'EOF' > /etc/dconf/db/distro.d/01-bazzora-folders
[org/gnome/desktop/app-folders/folders/GamingUtilities]
apps=['com.github.Matoking.protontricks.desktop', 'discover_overlay_configure.desktop', 'com.vysp3r.ProtonPlus.desktop', 'io.github.benjamimgois.goverlay.desktop', 'com.gerbilsoft.rom-properties.rp-config.desktop', 'input-remapper-gtk.desktop', 'steamos-nested-desktop.desktop', 'dev.lizardbyte.app.Sunshine.desktop', 'io.github.radiolamp.mangojuice.desktop']
name='Gaming Utilities'
translate=false

[org/gnome/desktop/app-folders/folders/Utilities]
apps=['system-update.desktop', 'tuned-gui.desktop', 'btop.desktop', 'com.github.tchx84.Flatseal.desktop', 'io.github.flattool.Warehouse.desktop', 'it.mijorus.gearlever.desktop', 'com.mattjakeman.ExtensionManager.desktop', 'org.gnome.tweaks.desktop', 'io.github.fastrizwaan.WineZGUI.desktop', 'setroubleshoot.desktop', 'org.rncbc.qsynth.desktop', 'de.leopoldluley.Clapgrep.desktop', 'org.virt_manager.virt-manager.desktop', 'io.github.flattool.Ignition.desktop', 'firewall-config.desktop', 'org.freedesktop.MalcontentControl.desktop', 'page.tesk.Refine.desktop', 'bbrew.desktop', 'org.gnome.Firmware.desktop', 'gparted.desktop', 'io.github.ilya_zlobintsev.LACT.desktop']
categories=['X-GNOME-Utilities']
name='X-GNOME-Utilities.directory'
translate=true

[org/gnome/desktop/app-folders/folders/Containers]
apps=['io.github.dvlv.boxbuddyrs.desktop', 'com.ranfdev.DistroShelf.desktop', 'io.podman_desktop.PodmanDesktop.desktop', 'com.github.marhkb.Pods.desktop']
categories=['Distrobox']
name='Containers'
translate=false

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
rm -f /etc/skel/.config/autostart/bazzite-portal.desktop
# Astuces de la bannière : celles de Bazzite citent Lutris et Waydroid (retirés) ; remplacées par 20-bazzora.md
rm -f /usr/share/ublue-os/motd/tips/20-bazzite.md

# Bash reste le shell par défaut des nouveaux utilisateurs (Fish est retiré de l'image)
sed -i 's|^SHELL=.*|SHELL=/bin/bash|' /etc/default/useradd 2>/dev/null || true

echo "5. Suppression des fonds d'écran et branding Bazzite/Steam Deck..."
rm -rf /usr/share/wallpapers/*
rm -rf /usr/share/backgrounds/bazzite*
rm -rf /usr/share/backgrounds/convergence*
rm -rf /usr/share/backgrounds/steamdeck*
rm -rf /usr/share/backgrounds/giants*
rm -rf /usr/share/backgrounds/penguins*
rm -rf /usr/share/backgrounds/ublue*
rm -rf /usr/share/gnome-background-properties/*

# Le fond d'écran Bazzora (fourni par le module files) est le seul proposé dans Paramètres › Apparence
test -f /usr/share/backgrounds/bazzora/background.jpg
cat << 'EOF' > /usr/share/gnome-background-properties/bazzora.xml
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
    <wallpaper deleted="false">
        <name>Bazzora</name>
        <filename>/usr/share/backgrounds/bazzora/background.jpg</filename>
        <filename-dark>/usr/share/backgrounds/bazzora/background.jpg</filename-dark>
        <options>zoom</options>
        <shade_type>solid</shade_type>
        <pcolor>#202646</pcolor>
        <scolor>#36438E</scolor>
    </wallpaper>
</wallpapers>
EOF

echo "6. Neutralisation sécurisée des recettes ujust devenues obsolètes..."
echo "# Debloated by Bazzora" > /usr/share/ublue-os/just/82-bazzite-waydroid.just
# Cockpit : paquets conservés mais services masqués (recipe.yml), la recette de Bazzite ne doit pas les réactiver
echo "# Debloated by Bazzora" > /usr/share/ublue-os/just/82-bazzite-cockpit.just
echo "# Debloated by Bazzora" > /usr/share/ublue-os/just/90-bazzite-de.just

echo "6b. Masquage des recettes ujust sans objet sur un PC fixe Full AMD..."
# Ajoute l'attribut just [private] devant chaque recette listée : elle disparaît de la
# liste ujust mais reste appelable. Une recette introuvable (renommée par Bazzite) est
# simplement signalée ; le build échoue seulement si le justfile devient invalide.
MASQUES=/usr/share/bazzora/ujust-masked.list
while IFS= read -r recette; do
    case "$recette" in ''|'#'*) continue ;; esac
    fichier=$(grep -rlE --include='*.just' "^${recette}( |:)" /usr/share/ublue-os/ | head -n1 || true)
    if [ -z "$fichier" ]; then
        echo "   (introuvable, ignorée) $recette"
        continue
    fi
    # Évite un double [private] si la recette l'est déjà
    if grep -B1 -E "^${recette}( |:)" "$fichier" | head -n1 | grep -qx '\[private\]'; then
        continue
    fi
    sed -i -E "s/^(${recette}( |:))/[private]\n\1/" "$fichier"
    echo "   masquée : $recette"
done < "$MASQUES"
# Le justfile complet doit toujours se charger
ujust --summary > /dev/null

echo "6c. Identité de l'image (bannière d'accueil, recettes ujust)..."
# image-info.json est lu par la bannière et certaines recettes Bazzite :
# il doit décrire Bazzora et non l'image de base.
# Effet sur bazzite-hardware-setup : le changement de nom le relance une fois au premier démarrage
# (il mémorise le nom dans /etc/bazzite/image_name), sans conséquence. Ses tests sur le nom ne
# visent que « deck » et « dx » : « bazzora » est traité comme une image bureau, comme bazzite-gnome.
IMAGE_INFO=/usr/share/ublue-os/image-info.json
if [ -f "$IMAGE_INFO" ]; then
    jq '. + {
        "image-name": "bazzora",
        "image-vendor": "0xreaven",
        "image-ref": "ostree-image-signed:docker://ghcr.io/0xreaven/bazzora",
        "image-tag": "latest",
        "image-branch": "latest"
    }' "$IMAGE_INFO" > "${IMAGE_INFO}.tmp"
    mv "${IMAGE_INFO}.tmp" "$IMAGE_INFO"
    chmod 644 "$IMAGE_INFO"
fi

echo "6d. Profil d'énergie « performance » : profil tuned Bazzora..."
# Le profil Bazzite hérite de dirty_bytes = 40 % de la RAM, qui écraserait les limites
# d'écriture de 99-bazzora-gaming.conf : on lui substitue throughput-performance-bazzora.
PPD=/etc/tuned/ppd.conf
sed -i 's/^performance=throughput-performance-bazzite$/performance=throughput-performance-bazzora/' "$PPD"
grep -qx 'performance=throughput-performance-bazzora' "$PPD"
test -f /usr/lib/tuned/profiles/throughput-performance-bazzite/tuned.conf

echo "7. Suppression des raccourcis d'applications obsolètes ou indésirables..."
rm -f /usr/share/applications/*waydroid*.desktop /usr/share/applications/Waydroid*.desktop
rm -f /usr/share/applications/bazzite-documentation.desktop
rm -f /usr/share/applications/discourse.desktop

echo "=== Debloat Bazzora terminé avec succès ==="
