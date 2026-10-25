<div align="center">

# Bazzora 🚀

**Système d'exploitation immuable, atomique et debloaté optimisé pour le Gaming PC de bureau Full AMD.**

[🇬🇧 English](README.md) • [🇫🇷 Français](README.fr.md)

[![English](https://img.shields.io/badge/🇬🇧_Switch_to_English-Read_README-blue?style=for-the-badge)](README.md)

<br/>

[![Build BlueBuild](https://github.com/0xREAVEN/bazzora/actions/workflows/build.yml/badge.svg)](https://github.com/0xREAVEN/bazzora/actions/workflows/build.yml)
![Image de base](https://img.shields.io/badge/Base-Bazzite--GNOME-purple?logo=linux)
![Cible matérielle](https://img.shields.io/badge/Cible-Full%20AMD%20(CPU%20%2B%20GPU)-ed1c24?logo=amd)
![Licence](https://img.shields.io/badge/Licence-Apache%202.0-blue.svg)
![Framework](https://img.shields.io/badge/Conçu%20avec-BlueBuild-cyan)

</div>

---

**Bazzora** est une image de système d'exploitation OCI personnalisée, immuable et prête pour la production, basée sur **Fedora Atomic / Bazzite-GNOME**, spécialement conçue pour les tours de bureau gaming **Full AMD** (processeurs AMD Ryzen + cartes graphiques AMD Radeon).

Elle fait le pont entre les **optimisations gaming de pointe de Valve et Bazzite** (noyau gaming fsync, pilotes Mesa ACO, proton-ge, FSR 4) et la **sobriété et la pureté de Fedora Silverblue Vanilla** — en purgeant intégralement les démons pour consoles portables, les agents d'hyperviseurs, les sous-systèmes Android et le bloatware applicatif.

---

## ⚖️ Pourquoi Bazzora ? (Comparatif)

| Fonctionnalité | Fedora Silverblue | Bazzite standard | **Bazzora** |
| :--- | :---: | :---: | :---: |
| **Noyau Gaming (`kernel-fsync` / CachyOS)** | ❌ (Générique standard) | ✅ | ✅ **Oui** |
| **Pilotes Mesa Valve (RADV ACO / 32 & 64-bit)** | ❌ (Mesa Fedora stock) | ✅ | ✅ **Oui** |
| **Cache Shaders Mesa XXL (50 Go anti-stutter)** | ❌ (1 Go par défaut) | ❌ (1 Go par défaut) | ✅ **Oui (50 Go)** |
| **Proton Wayland & HDR Natif (Mutter direct)** | ❌ | ⚠️ (Gamescope seul) | ✅ **Oui (`ujust`)** |
| **Accélération Proton NTSYNC dans le noyau** | ❌ | ⚠️ (Manuel) | ✅ **Actif par défaut** |
| **Overdrive GPU AMD & LACT (Undervolt/Ventilation)** | ❌ | ⚠️ (Flatpak, sudo requis) | ✅ **RPM natif + démon `lactd`** |
| **Utilitaire de partitionnement de disque** | ❌ (Disques GNOME seul) | ❌ (Disques GNOME seul) | ✅ **GParted (RPM natif)** |
| **Audio ultra-faible latence (PipeWire quantum 256)** | ❌ (1024 par défaut) | ❌ (1024 par défaut) | ✅ **Oui (< 5,8 ms)** |
| **Profil Sysctl CachyOS / SteamOS (ZRAM, BBR)** | ❌ | ⚠️ (Partiel) | ✅ **Profil Gaming complet** |
| **Mutter Low-Latency (Sans blocage timeout, VRR)** | ❌ | ❌ | ✅ **Oui (`check-alive=0`)** |
| **Bureau épuré Vanilla (Zéro extension bloatware)** | ✅ | ❌ (Effets Compiz / Docks) | ✅ **GNOME pur** |
| **Esthétique par défaut (Bibata Ice & Papirus-Dark)** | ❌ (Adwaita) | ❌ (Adwaita) | ✅ **Bibata Modern Ice + Papirus** |
| **Sous-système Android / Waydroid** | ❌ | ⚠️ (Inclus par défaut) | 🚫 **Entièrement purgé** |
| **Démons consoles portables (Steam Deck / Ally)** | ❌ | ⚠️ (Inclus par défaut) | 🚫 **Entièrement purgé** |
| **Administration serveur web (Cockpit)** | ❌ | ⚠️ (Inclus par défaut) | 🚫 **Entièrement purgé** |

---

## ⚡ Points Forts & Optimisations

### 🎮 Stack Gaming Haute Performance Full AMD
* **Vulkan RADV avec compilateur ACO Valve** : Compilation ultra-rapide des shaders éliminant les baisses d'images par seconde.
* **Cache Shader Mesa XXL (50 Go)** : Configuré via [10-amd-gaming.conf](files/system/etc/environment.d/10-amd-gaming.conf) (`MESA_SHADER_CACHE_MAX_SIZE=50G`) pour éliminer définitivement les micro-saccades de compilation de shaders.
* **Synchronisation Proton NTSYNC** : `PROTON_USE_NTSYNC=1` activé d'office pour une réduction drastique de l'overhead de synchronisation Windows NT.
* **AMD GPU Services (AGS) & Prêt pour le FSR 4** : `PROTON_ENABLE_AMD_AGS=1` actif pour supporter nativement les fonctionnalités FidelityFX, avec mise à l'échelle globale forcée vers FSR 4 via `ujust toggle-fsr4`.
* **Proton Wayland & HDR Natif** : La commande `ujust toggle-proton-hdr` active le rendu direct Wayland et le pass-through HDR vers Mutter sans la latence ni les bandes de couleurs (banding) induites par Gamescope imbriqué.
* **LACT en RPM natif avec démon root `lactd` automatique** : L'outil de contrôle AMD (overclocking, undervolt, courbes de ventilation sur-mesure) est intégré nativement via son COPR officiel. Le service système `lactd.service` démarre au boot, permettant un contrôle matériel immédiat sans mot de passe root.
* **Déblocage Overdrive AMD en un clic** : Commande `ujust toggle-amdgpu-overdrive` pour inscrire `amdgpu.ppfeaturemask=0xffffffff` au niveau du noyau.

### ⚙️ Ajustements Noyau & Système (Inspirés de CachyOS & SteamOS)
* **Profil Mémoire et Swappiness Gaming** ([99-bazzora-gaming.conf](files/system/etc/sysctl.d/99-bazzora-gaming.conf)) :
  * `vm.max_map_count = 2147483642` : Prévient les plantages mémoire sur les jeux gourmands (Star Citizen, Hogwarts Legacy, DayZ, Skyrim moddé).
  * `vm.swappiness = 100` avec compression ZRAM zstd pour une réactivité maximale sous charge.
  * Limitation de l'écriture en arrière-plan (256 Mo dirty / 64 Mo background) pour éradiquer les blocages d'I/O disque pendant le jeu.
  * Contrôle de congestion réseau `bbr` + `fq` pour réduire le jitter et stabiliser le ping en multijoueur.
* **Gestion des Pages Mémoire Transparentes (THP)** ([bazzora-thp.conf](files/system/etc/tmpfiles.d/bazzora-thp.conf)) :
  * Configuré en `defer+madvise` pour éliminer les saccades lors des allocations mémoire massives dans les jeux.
* **Audio Ultra-Basse Latence** ([10-bazzora-gaming.conf](files/system/etc/pipewire/pipewire.conf.d/10-bazzora-gaming.conf)) :
  * PipeWire configuré avec `min-quantum = 256` pour une latence inférieure à 5,8 ms sans grésillements ni perte de paquets audio.
* **Blacklist du Watchdog Matériel** ([bazzora-blacklist.conf](files/system/etc/modprobe.d/bazzora-blacklist.conf)) :
  * Module `sp5100_tco` neutralisé pour éviter les blocages intempestifs et timeouts sur cartes mères Ryzen.

### 🖥️ Bureau GNOME Épuré & Esthétique Moderne
* **Optimisations Mutter Gaming** :
  * `check-alive-timeout = 0` : Désactive complètement la pop-up intempestive *"L'application ne répond pas"* pendant les longs écrans de chargement de jeux.
  * Fréquence de rafraîchissement variable (VRR / FreeSync) et mise à l'échelle native XWayland actives par défaut.
  * Profil d'accélération souris plat (`accel-profile='flat'`) pour une visée brute 1:1 sans lissage en compétition.
* **Personnalisation Visuelle Bazzora** :
  * **Curseur de souris** : **Bibata Modern Ice** installé et configuré au niveau universel (`/usr/share/icons/default/index.theme`, GNOME, GTK 3 & GTK 4, Flatpaks, Wine/Proton, Steam).
  * **Thème d'icônes** : **Papirus-Dark** par défaut pour un contraste net des icônes monochromes de la barre supérieure sur fond sombre, combiné à l'intégralité des icônes applicatives Papirus.
  * **Thème GTK** : Mode sombre par défaut (`adw-gtk3-dark` + `color-scheme='prefer-dark'`).
* **Productivité & Outils Natifs** :
  * Utilitaire de partitionnement complet **GParted** intégré nativement.
  * **ExtensionManager** préinstallé en Flatpak pour choisir librement vos extensions sans dépendances système forcées.
  * Raccourcis pratiques : `Ctrl+Alt+T` (Terminal Ptyxis) et `Ctrl+Maj+Échap` (Mission Center).
  * Lanceur d'administration épuré : Remplacement du bazzite-updater KDE par le raccourci `ujust bazzora-update` à icône jaune.

### 🧹 Debloat Chirurgical (Épure maximale pour Tour de Bureau)
* **Android / Waydroid** : Intégralement purgé avec les bibliothèques de communication inter-processus (`waydroid`, `libgbinder`, `python3-gbinder`).
* **Services Serveur Cockpit** : Désinstallation des paquets Cockpit et masquage de `cockpit.socket` / `cockpit.service`.
* **Consoles Portables & Laptops** : Aucun démon de console portable (`hhd`, `inputplumber` absents de la base desktop), suppression des utilitaires pour portables Framework (`fw-fanctrl`) et outils mobiles APU (`ryzenadj`).
* **Démons Lourds** : Retrait des gestionnaires de snapshots en arrière-plan (`bees`, `snapper`, `btrfs-assistant`) pour libérer immédiatement CPU et mémoire vive.
* **Périphériques Non Pertinents** : Suppression des firmwares et pilotes non-AMD (firmwares Intel/Nvidia et pilotes multimédias), des agents de virtualisation (QEMU, VMware, VirtualBox, Hyper-V, Spice) et des modules akmod de volants de simulation.

### 🐚 Environnement Shell & Terminal
* **Shell Bash, bash-completion & Prompt Starship** : Prêts à l'emploi avec prise en charge des polices Nerd Fonts (`FiraCode`, `JetBrainsMono`, `Hack`).
* **Fastfetch** : Configuration élégante présentant l'état complet du processeur Ryzen et de la carte Radeon.
* **Initialisation Automatisée** ([bazzora-firstrun.sh](files/system/etc/profile.d/bazzora-firstrun.sh)) : Applique les configurations Bazzora et remet le profil Ptyxis sur le shell de connexion (Bash).

---

## 🛠️ Boîte à Outils `ujust` (Commandes Pratiques)

Bazzora met à votre disposition des commandes interactives de maintenance :

```bash
# Débloquer l'overdrive AMD (fréquences, undervolt, courbes de ventilation LACT)
ujust toggle-amdgpu-overdrive

# Activer/Désactiver Proton Wayland & HDR Natif (ou inspecter les Nits EDID de l'écran)
ujust toggle-proton-hdr

# Forcer l'upgrade global FSR 4 sur les jeux compatibles (RDNA 3/4)
ujust toggle-fsr4

# Mettre à jour l'ensemble du système (OSTree, Flatpaks, conteneurs et brew en parallèle)
ujust bazzora-update

# Gérer l'installation automatique des Flatpaks au démarrage (pour stopper les notifications)
ujust toggle-flatpak-setup

# Nettoyer les runtimes Flatpak inutilisés, les caches Homebrew et métadonnées rpm-ostree
ujust clean-bazzora

# Restaurer les configurations système (/etc/skel vers $HOME)
ujust restore-skel

# Configurer le pare-feu pour la liaison smartphone GSConnect
ujust setup-gsconnect

# Installer ou gérer Visual Studio Code via Homebrew
ujust manage-vscode install
```

---

## 🚀 Installation & Déploiement

### Option A — Installation propre via l'ISO Bazzora (Clé USB)
*Idéal pour une installation neuve et optimale sur disque dédié :*

1. **Téléchargez** les parties de l'ISO (`bazzora-latest.iso.part*`) et le fichier `.CHECKSUM` depuis la section [Releases](https://github.com/0xREAVEN/bazzora/releases) de ce dépôt.
2. **Reconstituez** l'image ISO en une seule commande dans votre dossier de téléchargement :
   * **Linux / macOS :** `cat bazzora-latest.iso.part* > bazzora-latest.iso`
   * **Windows :** `cmd /c copy /b bazzora-latest.iso.part* bazzora-latest.iso`
3. **Flashez** `bazzora-latest.iso` sur une clé USB avec [Ventoy](https://www.ventoy.net/) (copiez simplement le fichier `.iso` sur la clé) ou avec [BalenaEtcher](https://etcher.balena.io/).
4. **Démarrez** votre machine sur la clé USB et suivez l'assistant d'installation graphique.

---

### Option B — Migration par Rebase (depuis Bazzite ou Fedora Silverblue)
*Pour convertir une installation atomique existante sans formater votre disque :*

#### 1. Rebase vers l'image non vérifiée initiale
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/0xreaven/bazzora:latest
```

#### 2. Redémarrer
```bash
systemctl reboot
```

#### 3. Déployer l'environnement utilisateur
> [!NOTE]
> Sur une installation neuve (ISO), votre compte est configuré automatiquement.
> Après un rebase, exécutez cette commande une seule fois pour appliquer les paramètres Bazzora et le profil Ptyxis :

```bash
ujust restore-skel
```
*(Choisissez `M` pour copier sans écraser vos fichiers personnels existants).*

#### 4. Rebase vers le flux sécurisé signé (Vérification Cosign)
```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/0xreaven/bazzora:latest
```

#### 5. Redémarrage final
```bash
systemctl reboot
```

---

## 🛡️ Sécurité Atomique & Retour Arrière (Rollback)

### Retour arrière instantané
Si une mise à jour distante pose problème, revenez immédiatement à l'état précédent :

* **Depuis le bureau :**
  ```bash
  rpm-ostree rollback
  systemctl reboot
  ```
* **Depuis le menu de démarrage GRUB :** Sélectionnez la ligne correspondant au déploiement antérieur pour démarrer sur votre ancien système intact.

### Vérification de la signature Cosign
Vérifiez l'authenticité et l'intégrité de l'image grâce à la clé publique :
```bash
cosign verify --key cosign.pub ghcr.io/0xreaven/bazzora
```

---

## 📜 Licence & Remerciements

Distribué sous licence **Apache 2.0**. Consultez [LICENSE](LICENSE) pour plus d'informations.

Remerciements chaleureux aux projets libres qui rendent Bazzora possible :
* [Fedora Silverblue](https://fedoraproject.org/silverblue/) & [Universal Blue](https://universal-blue.org/)
* [Bazzite](https://bazzite.gg/) pour le noyau gaming et la stack Mesa ACO
* [BlueBuild](https://blue-build.org/) pour le moteur de construction déclaratif d'images OCI
* [CachyOS](https://cachyos.org/) pour les ordonnanceurs noyau et les recommandations sysctl gaming
* [LACT](https://github.com/ilya-zlobintsev/LACT) pour la suite de gestion matérielle AMDGPU
* [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor) & [L'équipe Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) pour les thèmes graphiques
