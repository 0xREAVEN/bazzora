<div align="center">

# Bazzora

**Mon image Bazzite-GNOME personnelle, pour un PC fixe Full AMD (Ryzen 7 9800X3D + Radeon).**

[![BlueBuild Build](https://github.com/0xREAVEN/bazzora/actions/workflows/build.yml/badge.svg)](https://github.com/0xREAVEN/bazzora/actions/workflows/build.yml)
![Base](https://img.shields.io/badge/Base-Bazzite--GNOME-purple?logo=linux)
![Licence](https://img.shields.io/badge/Licence-Apache%202.0-blue.svg)
![BlueBuild](https://img.shields.io/badge/Conçu%20avec-BlueBuild-cyan)

</div>

---

Bazzora est une image OCI immuable construite avec [BlueBuild](https://blue-build.org/) au-dessus de
[`bazzite-gnome`](https://bazzite.gg/). C'est un projet personnel : il adapte Bazzite à **ma** machine
et à mes habitudes, sans prétendre être une distribution plus rapide que Bazzite.

Le principe : garder tout ce que Bazzite fait bien, ajouter quelques outils et réglages, et ne retirer
que ce qui tourne, se charge au démarrage ou s'affiche à l'écran sans servir sur cette machine.

Aucun gain de performance n'est revendiqué : les réglages ci-dessous n'ont pas été mesurés.

---

## Hérité de Bazzite (non modifié)

* Noyau gaming de Bazzite (OGC), Mesa RADV/ACO en 32 et 64 bits, Steam, Gamescope.
* `vm.max_map_count = 2147483642`, contrôle de congestion TCP `bbr`, ZRAM compressé en zstd.
* Module `ntsync` chargé au démarrage (Proton-GE active NTSYNC de lui-même), profils d'énergie tuned (`balanced` / `performance`).
* Watchdogs actifs (récupération après un blocage complet) : `ujust configure-watchdog` pour les désactiver.
* Délai de 20 s avant la fenêtre *« L'application ne répond pas »*.
* Upgrade FSR 4 global pour les Radeon RDNA 4 : `ujust global-fsr4`.

## Ajouts

* **Paquets RPM** : [LACT](https://github.com/ilya-zlobintsev/LACT) (COPR `ilyaz/LACT`) avec le démon `lactd` activé au démarrage,
  Starship (COPR `atim/starship`), GParted, Papirus, gnome-initial-setup.
* **Curseur Bibata Modern Ice** (version figée, empreinte SHA-256 vérifiée au build), thème sombre `adw-gtk3-dark`, icônes Papirus-Dark,
  polices Nerd Fonts (FiraCode, JetBrainsMono, Hack).
* **Flatpaks installés au premier démarrage** : applications GNOME de base, Firefox, Mission Center, Flatseal, Warehouse,
  Gear Lever, Extension Manager, Refine, Heroic, Faugus Launcher, ProtonPlus, GOverlay (liste dans [recipe.yml](recipes/recipe.yml)).
* **Bureau GNOME épuré** : seules les extensions AppIndicator (active) et GSConnect sont conservées ; raccourcis
  `Ctrl+Alt+T` (Ptyxis) et `Ctrl+Maj+Échap` (Mission Center).
* **Bash + Starship** à la place de Fish, avec une initialisation au premier terminal
  ([bazzora-firstrun.sh](files/system/etc/profile.d/bazzora-firstrun.sh)).

## Réglages

| Réglage | Valeur | Ce que ça fait | Fichier |
| :--- | :--- | :--- | :--- |
| Cache de shaders Mesa | `MESA_SHADER_CACHE_MAX_SIZE=50G` | Garde les shaders compilés au-delà de la limite Mesa par défaut (1 Go). Peut occuper jusqu'à 50 Go dans `~/.cache`. | [10-amd-gaming.conf](files/system/etc/environment.d/10-amd-gaming.conf) |
| Swap | `vm.swappiness = 100` | Utilise davantage le swap ZRAM de Bazzite (60 par défaut dans le noyau). | [99-bazzora-gaming.conf](files/system/etc/sysctl.d/99-bazzora-gaming.conf) |
| Écritures disque | `dirty_bytes` 256 Mo / 64 Mo, écriture toutes les 15 s | Écrit les données par plus petits lots. Également appliqué en mode « performance » via un profil tuned dédié. | idem + [throughput-performance-bazzora](files/system/usr/lib/tuned/profiles/throughput-performance-bazzora/tuned.conf) |
| Réseau | `net.core.default_qdisc = fq` | Pacing des paquets (Fedora utilise `fq_codel`). Complète le BBR de Bazzite, qui ne concerne que le TCP. | [99-bazzora-gaming.conf](files/system/etc/sysctl.d/99-bazzora-gaming.conf) |
| THP | `defrag = defer+madvise`, `max_ptes_none = 409` | Change la politique de défragmentation des huge pages (elles restent en mode `madvise`). | [bazzora-thp.conf](files/system/etc/tmpfiles.d/bazzora-thp.conf) |
| Audio | PipeWire `min-quantum = 256` | Plancher anti-craquements : aucune application ne descend sous 256 échantillons (≈ 5,3 ms à 48 kHz). Le quantum par défaut reste 1024 ; ce n'est pas une baisse de latence. | [10-bazzora-gaming.conf](files/system/etc/pipewire/pipewire.conf.d/10-bazzora-gaming.conf) |
| Souris | `accel-profile = 'flat'` | Pas d'accélération du pointeur. | idem |

## Retraits

Liste complète et commentée dans [recipe.yml](recipes/recipe.yml) : 88 paquets, environ 880 Mo sur une image de 8,1 Go (Fedora 45).

* **Retirés parce qu'ils tournent ou se chargent au démarrage** : Waydroid, agents de machines virtuelles
  (QEMU, Spice, VMware, VirtualBox, Hyper-V), `intel-lpmd`, modules System76, adaptateur GameCube (`gcadapter_oc`), Looking Glass (`kvmfr`).
* **Retirés parce qu'ils s'affichent** : Lutris, Yelp, Web App Manager, l'interface de cardwire, l'ancien
  bazzite-updater, les presets et la recherche Steam Deck (Yafti), l'extension User Themes, Fish.
* **Retirés pour la place disque** : firmwares et bibliothèques Intel/Nvidia (≈ 365 Mo).
* **Bibliothèques orphelines** : celles qui ne servaient qu'à un composant retiré, soit LLVM 22 pour l'OpenCL Intel
  (≈ 260 Mo), les KDE Frameworks de l'ancien bazzite-updater (≈ 75 Mo) et la pile LXC de Waydroid. Les bibliothèques
  et outils génériques restent (rsync, wget2, dnsmasq, D-Bus, Qt, icônes Breeze). Le nettoyage automatique de dnf
  (`auto-remove`) reste désactivé : il emporterait aussi des paquets utilisés sans dépendance déclarée, comme `dbus-broker`.
* **Retirés car inutiles ici** : accessibilité (Orca, braille, synthèse vocale), OpenRazer.
* **Volontairement conservés** : pilotes de volants (Fanatec, Thrustmaster, Logitech), Wi-Fi Broadcom,
  DisplayLink, `ds-inhibit` (manettes PlayStation), cardwire (gestion de l'iGPU du 9800X3D), snapper, bees et
  btrfs-assistant (inactifs tant que `ujust configure-snapshots` / `configure-beesd` ne les activent pas),
  outils Framework, CEC, lecteur d'empreintes. Cockpit est installé mais ses services sont masqués.

Les recettes ujust de Bazzite sans objet ici (Steam Deck, Decky, Framework, Nvidia, Intel, CEC…) sont masquées
de la liste mais restent appelables par leur nom : voir [ujust-masked.list](files/system/usr/share/bazzora/ujust-masked.list).

---

## Commandes `ujust`

```bash
ujust bazzora-update            # Mise à jour système, Flatpaks, Homebrew, Distrobox (épingle d'abord le déploiement actuel)
ujust bazzora-doctor            # Diagnostic en lecture seule : image, GPU, réglages, services
ujust toggle-amdgpu-overdrive   # Ajoute le bit overdrive (0x4000) au masque amdgpu, comme Bazzite, pour LACT
ujust toggle-proton-hdr         # Proton Wayland + HDR pour tous les jeux, ou lecture des métadonnées HDR de l'écran
ujust global-fsr4               # (Bazzite) Upgrade FSR 4 global sur RDNA 4
ujust configure-snapshots       # (Bazzite) Snapshots snapper de /var/home
ujust toggle-flatpak-setup      # Active ou coupe l'installation automatique des Flatpaks au démarrage
ujust clean-bazzora             # Nettoie Flatpaks inutilisés, cache Homebrew et métadonnées rpm-ostree
ujust restore-skel              # Copie les configurations de /etc/skel dans $HOME
ujust setup-gsconnect           # Ouvre ou ferme les ports du pare-feu pour GSConnect
ujust setup-brew                # Installe bbrew (interface Homebrew)
ujust manage-vscode install     # Installe ou retire VS Code via Homebrew
```

---

## Installation

### ISO
1. Télécharger depuis les [Releases](https://github.com/0xREAVEN/bazzora/releases) les parties `bazzora-latest.iso.part*`,
   la somme de contrôle `bazzora-latest.iso-CHECKSUM` et sa signature `bazzora-latest.iso-CHECKSUM.sigstore.json`.
2. Reconstituer et vérifier (Linux) :
   ```bash
   cat bazzora-latest.iso.part* > bazzora-latest.iso
   # Authenticité : la somme de contrôle est signée avec la clé du dépôt
   cosign verify-blob --key cosign.pub --bundle bazzora-latest.iso-CHECKSUM.sigstore.json bazzora-latest.iso-CHECKSUM
   # Intégrité : l'ISO correspond à la somme de contrôle signée
   sha256sum -c bazzora-latest.iso-CHECKSUM
   ```
   Sous Windows : `cmd /c copy /b bazzora-latest.iso.part* bazzora-latest.iso`, puis comparer `Get-FileHash bazzora-latest.iso -Algorithm SHA256`
   au fichier `-CHECKSUM` (la vérification de la signature demande `cosign`).
3. Copier l'ISO sur une clé [Ventoy](https://www.ventoy.net/) ou la flasher avec [BalenaEtcher](https://etcher.balena.io/), puis démarrer dessus.

### Rebase depuis Bazzite ou Silverblue
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/0xreaven/bazzora:latest
systemctl reboot
ujust restore-skel        # « M » : copie les fichiers manquants sans écraser les vôtres
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/0xreaven/bazzora:latest
systemctl reboot
```

---

## Retour arrière et sécurité

* **Version Fedora maîtrisée** : la recette suit `bazzite-gnome:stable-45`, qui reçoit chaque jour les mises à jour de Bazzite
  sans changer de version majeure. Le passage à Fedora 46 se fait en changeant `image-version` dans une PR testée ;
  la CI et l'ISO lisent cette valeur.
* **Mises à jour découpées** : l'image est reconstruite en couches stables (`build-chunked-oci`), si bien qu'une mise à jour
  ne télécharge que les couches modifiées. La première mise à jour après ce changement télécharge l'image entière une fois.
* **Retour arrière** : `rpm-ostree rollback && systemctl reboot`, ou choisir le déploiement précédent dans le menu de démarrage.
* **Version de secours épinglée** : avant chaque mise à jour, `ujust bazzora-update` épingle le déploiement en cours.
  Une seule épingle Bazzora existe à la fois ; les épingles manuelles (`ostree admin pin`) ne sont jamais touchées.
* **Publication testée** : chaque build est publié sous le tag `candidate`, puis passe des tests de fumée dans un conteneur
  (sans démarrage réel ni GPU) : conformité `bootc`, chargement de `ujust`, paquets retirés et conservés, services
  (LACT, Cockpit masqué), fichiers de configuration, schémas GSettings, signature Cosign. Il ne devient `latest`
  que si tous les tests passent ([build.yml](.github/workflows/build.yml), [test-image.sh](.github/scripts/test-image.sh)).
* **Signature** : `cosign verify --key cosign.pub ghcr.io/0xreaven/bazzora` pour l'image ; la somme de contrôle de l'ISO
  est signée avec la même clé (voir Installation).
* **Chaîne de build** : les actions GitHub sont épinglées par empreinte (SHA) et mises à jour par Dependabot ; un workflow
  hebdomadaire ([cleanup.yml](.github/workflows/cleanup.yml)) supprime les anciennes images candidates du registre.

---

## Licence et remerciements

Licence **Apache 2.0** (voir [LICENSE](LICENSE)).

Merci à [Bazzite](https://bazzite.gg/) et [Universal Blue](https://universal-blue.org/), sur qui tout repose,
à [BlueBuild](https://blue-build.org/), [Fedora Silverblue](https://fedoraproject.org/silverblue/),
[LACT](https://github.com/ilya-zlobintsev/LACT), [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor)
et [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme).
