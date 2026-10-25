#!/usr/bin/env bash
# =============================================================================
# Tests de fumée de l'image Bazzora (exécutés en CI avant toute publication)
#
# Usage : test-image.sh <image-à-tester> <image-de-base>
#   ex. : test-image.sh ghcr.io/0xreaven/bazzora@sha256:... ghcr.io/ublue-os/bazzite-gnome:latest
#
# Chaque test affiche ✅ / ❌. Le script se termine en erreur si au moins un test
# échoue : le job de promotion vers « latest » n'est alors jamais exécuté.
#
# Les vérifications sensibles aux défauts de Bazzite elle-même (bootc lint,
# schémas glib stricts) sont comparées à l'image de base : un défaut déjà présent
# en amont n'est qu'un avertissement, seule une régression introduite par
# Bazzora fait échouer la CI.
# =============================================================================
set -uo pipefail

IMAGE="${1:?image à tester manquante}"
BASE="${2:?image de base manquante}"
RECIPE="${RECIPE:-recipes/recipe.yml}"
ECHECS=0

ok()      { echo "✅ $*"; }
ko()      { echo "❌ $*"; ECHECS=$((ECHECS + 1)); }
attention() { echo "⚠️  $*"; }
section() { echo; echo "::group::$*"; }
fin()     { echo "::endgroup::"; }

# Exécute une commande dans l'image testée (réseau coupé : l'image doit être autonome)
dans_image() { podman run --rm --network=none "$IMAGE" "$@"; }
dans_base()  { podman run --rm --network=none "$BASE" "$@"; }

# Lance une vérification ; si elle échoue, la rejoue sur la base pour distinguer
# une régression Bazzora d'un défaut hérité de Bazzite.
compare_base() {
    local nom=$1; shift
    if dans_image "$@" >/tmp/sortie.log 2>&1; then
        ok "$nom"
        return
    fi
    if [ "$BASE_PULLED" != 1 ]; then
        podman pull -q "$BASE" >/dev/null && BASE_PULLED=1
    fi
    if dans_base "$@" >/dev/null 2>&1; then
        ko "$nom (régression par rapport à la base)"
        sed 's/^/    /' /tmp/sortie.log | tail -40
    else
        attention "$nom échoue aussi sur la base Bazzite : défaut amont, non bloquant"
    fi
}
BASE_PULLED=0

# -----------------------------------------------------------------------------
section "1. Conformité bootc"
compare_base "bootc container lint" bootc container lint
fin

# -----------------------------------------------------------------------------
section "2. Commandes ujust"
if dans_image ujust --summary >/tmp/ujust.txt 2>&1; then
    ok "le justfile ujust complet se charge (aucune recette en double)"
    for recette in bazzora-update restore-skel setup-gsconnect manage-vscode \
                   toggle-amdgpu-overdrive toggle-fsr4 toggle-proton-hdr \
                   toggle-flatpak-setup clean-bazzora setup-brew; do
        if tr ' ' '\n' </tmp/ujust.txt | grep -qx "$recette"; then
            ok "recette ujust présente : $recette"
        else
            ko "recette ujust absente : $recette"
        fi
    done
else
    ko "ujust ne se charge pas"
    sed 's/^/    /' /tmp/ujust.txt | tail -20
fi
fin

# -----------------------------------------------------------------------------
section "3. Paquets (debloat et ajouts)"
mapfile -t RETIRES < <(yq -r '.modules[] | select(.type == "rpm-ostree") | .remove[]' "$RECIPE")
mapfile -t AJOUTES < <(yq -r '.modules[] | select(.type == "rpm-ostree") | .install[]' "$RECIPE")

PRESENTS=$(dans_image rpm -q "${RETIRES[@]}" 2>&1 | grep -v "is not installed" || true)
if [ -z "$PRESENTS" ]; then
    ok "les ${#RETIRES[@]} paquets de « remove: » sont absents"
else
    ko "paquets censés être retirés mais présents :"
    sed 's/^/    /' <<<"$PRESENTS"
fi

MANQUANTS=$(dans_image rpm -q "${AJOUTES[@]}" 2>&1 | grep "is not installed" || true)
if [ -z "$MANQUANTS" ]; then
    ok "les ${#AJOUTES[@]} paquets de « install: » sont présents"
else
    ko "paquets ajoutés manquants :"
    sed 's/^/    /' <<<"$MANQUANTS"
fi

# Paquets interdits par la politique Full AMD (qu'ils viennent de la base ou non)
INTERDITS=$(dans_image bash -c 'rpm -qa | grep -Ei "^(waydroid|cockpit|hhd|inputplumber|nvidia|ryzenadj|fw-|libcec|xwiimote)" || true')
if [ -z "$INTERDITS" ]; then
    ok "aucun paquet Waydroid / Cockpit / handheld / Nvidia / laptop"
else
    ko "paquets interdits détectés :"
    sed 's/^/    /' <<<"$INTERDITS"
fi
fin

# -----------------------------------------------------------------------------
section "4. Services systemd"
etat() { dans_image systemctl is-enabled "$1" 2>/dev/null || true; }
[ "$(etat lactd.service)" = "enabled" ] && ok "lactd.service activé" || ko "lactd.service non activé ($(etat lactd.service))"
for unite in cockpit.socket cockpit.service; do
    [ "$(etat "$unite")" = "masked" ] && ok "$unite masqué" || ko "$unite non masqué ($(etat "$unite"))"
done
fin

# -----------------------------------------------------------------------------
section "5. Fichiers de configuration"
for fichier in \
    /etc/environment.d/10-amd-gaming.conf \
    /etc/sysctl.d/99-bazzora-gaming.conf \
    /etc/modules-load.d/bazzora-bbr.conf \
    /etc/tmpfiles.d/bazzora-flatpak.conf \
    /etc/tmpfiles.d/bazzora-thp.conf \
    /etc/profile.d/bazzora-firstrun.sh \
    /etc/profile.d/bazzora-starship.sh \
    /etc/fastfetch/config.jsonc \
    /usr/share/bazzora/flatpak/overrides-global \
    /usr/share/backgrounds/bazzora/background.png \
    /usr/share/icons/Bibata-Modern-Ice/index.theme \
    /usr/share/icons/default/index.theme \
    /usr/libexec/bazzora/pin-deployment; do
    if dans_image test -s "$fichier"; then ok "$fichier"; else ko "$fichier manquant ou vide"; fi
done

for variable in MESA_SHADER_CACHE_MAX_SIZE=50G PROTON_ENABLE_AMD_AGS=1; do
    if dans_image grep -qx "$variable" /etc/environment.d/10-amd-gaming.conf; then
        ok "variable $variable"
    else
        ko "variable $variable absente"
    fi
done

if dans_image test -x /usr/libexec/bazzora/pin-deployment; then
    ok "pin-deployment exécutable"
else
    ko "pin-deployment non exécutable"
fi
fin

# -----------------------------------------------------------------------------
section "6. Syntaxe des scripts et configurations"
if dans_image bash -n /etc/profile.d/bazzora-firstrun.sh /etc/profile.d/bazzora-starship.sh \
    && dans_image bash -n /usr/libexec/bazzora/pin-deployment; then
    ok "scripts shell valides"
else
    ko "erreur de syntaxe dans un script shell"
fi

if dans_image systemd-tmpfiles --dry-run --create \
        /etc/tmpfiles.d/bazzora-flatpak.conf /etc/tmpfiles.d/bazzora-thp.conf >/tmp/tmpfiles.log 2>&1; then
    ok "règles tmpfiles.d valides"
else
    ko "règles tmpfiles.d invalides"
    sed 's/^/    /' /tmp/tmpfiles.log | tail -20
fi

if dans_image bash -c 'd=$(mktemp -d) && dconf compile "$d/db" /etc/dconf/db/distro.d'; then
    ok "base dconf distro.d compilable"
else
    ko "base dconf distro.d invalide"
fi

compare_base "schémas GSettings stricts (glib-compile-schemas --strict)" \
    glib-compile-schemas --strict --dry-run /usr/share/glib-2.0/schemas

if dans_image python3 -c 'import json; json.load(open("/etc/fastfetch/config.jsonc"))' 2>/dev/null; then
    ok "configuration Fastfetch valide"
else
    ko "configuration Fastfetch invalide"
fi
fin

# -----------------------------------------------------------------------------
echo
if [ "$ECHECS" -eq 0 ]; then
    echo "🎉 Tous les tests sont passés : l'image peut être publiée."
else
    echo "🛑 $ECHECS test(s) en échec : l'image ne sera PAS publiée."
    exit 1
fi
