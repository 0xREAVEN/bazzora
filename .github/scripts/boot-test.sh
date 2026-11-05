#!/usr/bin/env bash
# =============================================================================
# Test de démarrage de Bazzora dans une machine virtuelle (QEMU/KVM)
#
# Usage : boot-test.sh <disque.raw> [journal-série]
#
# Démarre le disque installé par « bootc install to-disk » et surveille la
# console série (console=ttyS0) :
#   ✅ invite de connexion (serial-getty)        → démarrage réussi
#   ❌ panique du noyau, mode d'urgence, arrêt
#      inattendu de la VM, boucle de redémarrage
#      ou délai dépassé                          → échec
# Au premier démarrage, bazzite-hardware-setup applique ses arguments noyau puis
# redémarre une fois : jusqu'à MAX_REDEMARRAGES redémarrages sont donc admis.
# Les unités systemd en échec sont listées en avertissement.
# =============================================================================
set -uo pipefail

DISQUE="${1:?disque à démarrer manquant}"
JOURNAL="${2:-serial.log}"
DELAI="${BOOT_TIMEOUT:-900}"
MAX_REDEMARRAGES="${MAX_REBOOTS:-2}"

: > "$JOURNAL"
sudo qemu-system-x86_64 \
    -enable-kvm -cpu host -machine q35 -smp 4 -m 6144 \
    -drive file="$DISQUE",format=raw,if=virtio \
    -nic user,model=virtio-net-pci \
    -display none -serial file:"$JOURNAL" &
QEMU=$!
trap 'sudo kill "$QEMU" 2>/dev/null || true' EXIT

DEBUT=$(date +%s)
RESULTAT=""
while :; do
    if grep -qaE "(^|[[:space:]])login:[[:space:]]*$" "$JOURNAL"; then
        RESULTAT=ok; break
    fi
    if grep -qaE "Kernel panic|emergency mode|Give root password|dracut-emergency|Failed to mount /sysroot" "$JOURNAL"; then
        RESULTAT=echec; break
    fi
    if (( $(grep -ac "reboot: Restarting system" "$JOURNAL") > MAX_REDEMARRAGES )); then
        RESULTAT=boucle; break
    fi
    if ! sudo kill -0 "$QEMU" 2>/dev/null; then
        RESULTAT=arret; break
    fi
    if (( $(date +%s) - DEBUT > DELAI )); then
        RESULTAT=delai; break
    fi
    sleep 5
done
DUREE=$(( $(date +%s) - DEBUT ))
REDEMARRAGES=$(grep -ac "reboot: Restarting system" "$JOURNAL" || true)

# Unités en échec pendant le démarrage : signalées sans bloquer
tr -d '\r' < "$JOURNAL" | grep -aoE "Failed to start .*" | sort -u | while IFS= read -r ligne; do
    echo "::warning::Démarrage VM : ${ligne}"
done

case "$RESULTAT" in
    ok)
        echo "✅ Invite de connexion atteinte en ${DUREE} s (${REDEMARRAGES} redémarrage(s) en route)"
        ;;
    echec)
        echo "::error::Échec du démarrage (panique, mode d'urgence ou racine introuvable) après ${DUREE} s"
        ;;
    boucle)
        echo "::error::Boucle de redémarrage : plus de ${MAX_REDEMARRAGES} redémarrages en ${DUREE} s"
        ;;
    arret)
        echo "::error::La machine virtuelle s'est arrêtée avant l'invite de connexion (${DUREE} s)"
        ;;
    delai)
        echo "::error::Pas d'invite de connexion après ${DELAI} s"
        ;;
esac

if [ "$RESULTAT" != ok ]; then
    echo "--- 80 dernières lignes de la console série ---"
    tail -n 80 "$JOURNAL" | tr -d '\r'
    exit 1
fi
