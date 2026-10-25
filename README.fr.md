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

Elle fait le pont entre la **stack gaming héritée de Bazzite** (noyau gaming, Mesa RADV/ACO 32 et 64 bits, ZRAM, module NTSYNC, upgrade FSR 4) et la **sobriété et la pureté de Fedora Silverblue Vanilla** — en purgeant intégralement les démons pour consoles portables, les agents d'hyperviseurs, les sous-systèmes Android et le bloatware applicatif.

---

## ⚖️ Pourquoi Bazzora ? (Comparatif)

| Fonctionnalité | Fedora Silverblue | Bazzite standard | **Bazzora** |
| :--- | :---: | :---: | :---: |
| **Noyau Gaming (Bazzite / OGC)** | ❌ (Générique standard) | ✅ | ✅ **Hérité** |
| **Mesa RADV ACO (32 & 64-bit)** | ✅ (Mesa Fedora) | ✅ | ✅ **Hérité** |
| **Cache Shaders Mesa XXL (50 Go anti-stutter)** | ❌ (1 Go par défaut) | ❌ (1 Go par défaut) | ✅ **Oui (50 Go)** |
| **Proton Wayland & HDR Natif (Mutter direct)** | ❌ | ⚠️ (Gamescope seul) | ✅ **Oui (`ujust`)** |
| **Accélération Proton NTSYNC dans le noyau** | ❌ | ⚠️ (Module chargé, variable Proton manuelle) | ✅ **`PROTON_USE_NTSYNC=1` par défaut** |
| **Overdrive GPU AMD & LACT (Undervolt/Ventilation)** | ❌ | ⚠️ (Flatpak, sudo requis) | ✅ **RPM natif + démon `lactd`** |
| **Utilitaire de partitionnement de disque** | ❌ (Disques GNOME seul) | ❌ (Disques GNOME seul) | ✅ **GParted (RPM natif)** |
| **Audio anti-craquements (PipeWire min-quantum)** | ❌ (min 32) | ❌ (min 32) | ✅ **Min 256** |
| **Réglages sysctl gaming** | ❌ | ⚠️ (`max_map_count`, BBR, ZRAM zstd) | ✅ **+ swappiness, limites dirty, `fq`** |
| **Mutter VRR & mise à l'échelle native XWayland** | ❌ | ❌ | ✅ **Débloqués (VRR par écran)** |
| **Bureau épuré Vanilla (Zéro extension bloatware)** | ✅ | ❌ (Effets Compiz / Docks) | ✅ **GNOME pur** |
| **Esthétique par défaut (Bibata Ice & Papirus-Dark)** | ❌ (Adwaita) | ❌ (Adwaita) | ✅ **Bibata Modern Ice + Papirus** |
| **Sous-système Android / Waydroid** | ❌ | ⚠️ (Inclus par défaut) | 🚫 **Entièrement purgé** |
| **Extras consoles portables / Steam Deck** | ❌ | ⚠️ (Presets et outils Deck) | 🚫 **Purgés** |
| **Administration serveur web (Cockpit)** | ❌ | ⚠️ (Installé, inactif) | 🚫 **Purgé et masqué** |

---

## ⚡ Points Forts & Optimisations

### 🎮 Stack Gaming Haute Performance Full AMD
* **Vulkan RADV avec compilateur ACO** : Mesa 32 et 64 bits hérité de Bazzite.
* **Cache Shader Mesa XXL (50 Go)** : Configuré via [10-amd-gaming.conf](files/system/etc/environment.d/10-amd-gaming.conf) (`MESA_SHADER_CACHE_MAX_SIZE=50G`) pour conserver les shaders compilés au lieu de les évincer à la limite Mesa par défaut de 1 Go (jusqu'à 50 Go de disque dans `~/.cache`).
* **Synchronisation Proton NTSYNC** : `PROTON_USE_NTSYNC=1` activé d'office pour une réduction drastique de l'overhead de synchronisation Windows NT.
* **AMD GPU Services (AGS) & Prêt pour le FSR 4** : `PROTON_ENABLE_AMD_AGS=1` actif pour supporter nativement les fonctionnalités FidelityFX, avec l'upgrade FSR 4 global de Bazzite disponible via `ujust global-fsr4` (RDNA 4).
* **Proton Wayland & HDR Natif** : La commande `ujust toggle-proton-hdr` active le rendu direct Wayland et le pass-through HDR vers Mutter sans la latence ni les bandes de couleurs (banding) induites par Gamescope imbriqué.
* **LACT en RPM natif avec démon root `lactd` automatique** : L'outil de contrôle AMD (overclocking, undervolt, courbes de ventilation sur-mesure) est intégré nativement via son COPR officiel. Le service système `lactd.service` démarre au boot, permettant un contrôle matériel immédiat sans mot de passe root.
* **Déblocage Overdrive AMD en un clic** : `ujust toggle-amdgpu-overdrive` ajoute uniquement le bit overdrive (`0x4000`) au masque `amdgpu.ppfeaturemask` du pilote, selon la méthode utilisée par Bazzite sur les consoles portables.

### ⚙️ Ajustements Noyau & Système (Inspirés de CachyOS & SteamOS)
* **Hérité de Bazzite** (non redéfini) : `vm.max_map_count = 2147483642`, contrôle de congestion TCP `bbr`, ZRAM compressé en zstd, module `ntsync` chargé au démarrage.
* **Profil Mémoire et Swappiness Gaming** ([99-bazzora-gaming.conf](files/system/etc/sysctl.d/99-bazzora-gaming.conf)) :
  * `vm.swappiness = 100` (60 par défaut dans le noyau), adapté au swap ZRAM de Bazzite.
  * Limites d'écriture `dirty_bytes` (256 Mo dirty / 64 Mo background) pour écrire les données par plus petits lots, avec un intervalle d'écriture de 15 s. Conservées en mode d'énergie « performance » grâce à un profil tuned Bazzora ([throughput-performance-bazzora](files/system/usr/lib/tuned/profiles/throughput-performance-bazzora/tuned.conf)).
  * Ordonnancement réseau `fq` (Fedora utilise `fq_codel`). Le BBR fourni par Bazzite ne s'applique qu'au TCP, pas au trafic UDP utilisé par la plupart des jeux en ligne.
* **Défragmentation des Pages Mémoire Transparentes (THP)** ([bazzora-thp.conf](files/system/etc/tmpfiles.d/bazzora-thp.conf)) :
  * `defrag` en `defer+madvise` (les THP restent en mode `madvise` du noyau) et `khugepaged/max_ptes_none = 409`.
* **Audio anti-craquements** ([10-bazzora-gaming.conf](files/system/etc/pipewire/pipewire.conf.d/10-bazzora-gaming.conf)) :
  * PipeWire `min-quantum = 256` : les applications ne peuvent plus demander de tampon inférieur à 256 échantillons (≈ 5,3 ms à 48 kHz), ce qui limite les craquements sous forte charge CPU (compilation de shaders). Le quantum par défaut reste à 1024 : ce n'est pas une réduction de latence.
* **Watchdogs conservés** comme sur Bazzite (récupération après un blocage complet) ; `ujust configure-watchdog` permet de les désactiver.

### 🖥️ Bureau GNOME Épuré & Esthétique Moderne
* **Optimisations Mutter Gaming** :
  * Fonctionnalités expérimentales VRR (FreeSync), `scale-monitor-framebuffer` et `xwayland-native-scaling` débloquées. La VRR s'active ensuite écran par écran dans Paramètres › Écrans.
  * Le délai de 20 s de Bazzite avant la fenêtre *« L'application ne répond pas »* est conservé : les longs chargements sont tolérés et une application figée peut toujours être fermée.
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
* **Services Serveur Cockpit** : Désinstallation des paquets Cockpit (installés mais inactifs sur Bazzite) et masquage de `cockpit.socket` / `cockpit.service`.
* **Consoles Portables & Laptops** : Aucun démon de console portable (`hhd`, `inputplumber` absents de la base desktop), suppression des utilitaires pour portables Framework (`fw-fanctrl`) et outils mobiles APU (`ryzenadj`).
* **Outils de snapshots** : Retrait de `bees`, `snapper` et `btrfs-assistant`. Ils ne sont pas activés par défaut sur Bazzite : le gain porte sur l'espace disque et la surface d'attaque, pas sur la RAM ni le CPU en fonctionnement.
* **Périphériques Non Pertinents** : Suppression des firmwares GPU Intel/Nvidia et des pilotes multimédias Intel (Mesa n'est pas modifié), des agents de virtualisation (QEMU, VMware, VirtualBox, Hyper-V, Spice) et des pilotes de volants (Fanatec, Thrustmaster, Logitech `new-lg4ff`).
* **Également retirés — à vérifier avant d'installer** : accessibilité (lecteur d'écran Orca, braille `brltty`, synthèse vocale), pilotes Wi-Fi Broadcom (`broadcom-wl`, `b43`), DisplayLink (`evdi`), périphériques Razer (`openrazer`), Looking Glass (`kvmfr`), HDMI-CEC, lecteur d'empreintes, Lutris, Fish et Yelp. Liste complète dans [recipe.yml](recipes/recipe.yml).

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

# Forcer l'upgrade global FSR 4 sur les jeux compatibles (RDNA 4, recette Bazzite)
ujust global-fsr4

# Mettre à jour l'ensemble du système (OSTree, Flatpaks, conteneurs et brew en parallèle)
ujust bazzora-update

# Diagnostiquer le système et les réglages gaming (lecture seule)
ujust bazzora-doctor

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

> Les recettes Bazzite sans objet sur un PC fixe Full AMD (Steam Deck, Decky, Framework, Nvidia, Intel, CEC…) sont masquées de la liste.
> Elles restent appelables par leur nom. La liste est dans [`ujust-masked.list`](files/system/usr/share/bazzora/ujust-masked.list).

---

## 🚀 Installation & Déploiement

### Option A — Installation propre via l'ISO Bazzora (Clé USB)
*Idéal pour une installation neuve et optimale sur disque dédié :*

1. **Téléchargez** les parties de l'ISO (`bazzora-latest.iso.part*`) et le fichier `bazzora-latest.iso-CHECKSUM` depuis la section [Releases](https://github.com/0xREAVEN/bazzora/releases) de ce dépôt.
2. **Reconstituez** l'image ISO dans votre dossier de téléchargement, puis vérifiez son empreinte :
   * **Linux / macOS :** `cat bazzora-latest.iso.part* > bazzora-latest.iso && sha256sum -c bazzora-latest.iso-CHECKSUM`
   * **Windows :** `cmd /c copy /b bazzora-latest.iso.part* bazzora-latest.iso`, puis comparez `Get-FileHash bazzora-latest.iso -Algorithm SHA256` au fichier d'empreinte
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

### Version de secours épinglée
Avant chaque mise à jour, `ujust bazzora-update` **épingle le déploiement en cours** (celui qui fonctionne).
Il reste disponible au menu de démarrage même après plusieurs mises à jour ratées d'affilée.
Une seule épingle Bazzora existe à la fois, et vos épingles manuelles (`ostree admin pin`) ne sont jamais modifiées.

### Publication testée
Chaque build est d'abord publié sous le tag `candidate`, puis soumis à des tests de fumée automatiques, exécutés dans un conteneur (sans démarrage réel ni GPU) :
conformité `bootc`, chargement de `ujust`, paquets retirés ou ajoutés, services (LACT, Cockpit masqué),
configurations, schémas GSettings et signature Cosign. L'image ne devient `latest` que si **tous** les tests passent.
Sinon, vous restez sur la dernière version validée.

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
* [Bazzite](https://bazzite.gg/) pour le noyau gaming, la stack Mesa, le ZRAM et la base sysctl
* [BlueBuild](https://blue-build.org/) pour le moteur de construction déclaratif d'images OCI
* [CachyOS](https://cachyos.org/) pour les ordonnanceurs noyau et les recommandations sysctl gaming
* [LACT](https://github.com/ilya-zlobintsev/LACT) pour la suite de gestion matérielle AMDGPU
* [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor) & [L'équipe Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) pour les thèmes graphiques
