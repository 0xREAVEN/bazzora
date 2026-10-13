# Bazzora 🚀

[![BlueBuild Build](https://github.com/0xREAVEN/bazzora/actions/workflows/build.yml/badge.svg)](https://github.com/0xREAVEN/bazzora/actions/workflows/build.yml)
![Base Image](https://img.shields.io/badge/Base-Bazzite--GNOME-purple?logo=linux)
![Hardware Target](https://img.shields.io/badge/Target-Full%20AMD%20(CPU%20%2B%20GPU)-ed1c24?logo=amd)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![Framework](https://img.shields.io/badge/Built%20with-BlueBuild-cyan)

**Bazzora** est une image de système d'exploitation OCI personnalisée, immuable et prête pour la production, basée sur **Fedora Atomic / Bazzite-GNOME**.

Elle combine le **noyau optimisé pour le jeu et les pilotes Mesa de Valve** issus de Bazzite avec la **sobriété et la pureté de Fedora Silverblue Vanilla**, le tout taillé sur mesure pour les machines de bureau **Full AMD** (processeurs AMD Ryzen + cartes graphiques AMD Radeon).

---

## ⚖️ Pourquoi Bazzora ? (Comparatif)

| Fonctionnalité | Fedora Silverblue | Bazzite standard | **Bazzora** |
| :--- | :---: | :---: | :---: |
| **Noyau Gaming (`kernel-fsync` / CachyOS)** | ❌ (Noyau générique) | ✅ | ✅ **Oui** |
| **Pilotes Mesa Valve (RADV ACO / 32-bit & 64-bit)** | ❌ (Mesa Fedora standard) | ✅ | ✅ **Oui** |
| **Environnement GNOME épuré & fluide** | ✅ (Vanilla) | ❌ (Surchargé d'effets visuels) | ✅ **Vanilla épuré** |
| **Cache Shaders Mesa XXL (50 Go anti-stuttering)** | ❌ | ❌ | ✅ **Oui** |
| **Support Proton AGS & FSR 4 en un clic** | ❌ | ⚠️ (Partiel) | ✅ **Oui (`ujust`)** |
| **Déblocage Overdrive AMD GPU (LACT / OC)** | ❌ (Manuel) | ❌ (Manuel) | ✅ **Oui (`ujust`)** |
| **Émulation Android & Waydroid** | ❌ | ⚠️ (Inclus par défaut) | 🚫 **Purgé** |
| **Démons pour consoles portables (Steam Deck / Ally)** | ❌ | ⚠️ (Inclus par défaut) | 🚫 **Purgé** |
| **Serveur web d'administration (Cockpit)** | ❌ | ⚠️ (Inclus par défaut) | 🚫 **Purgé** |

---

## ⚡ Points Forts & Optimisations

### 🎮 Stack Gaming Full AMD
* **Pilote Vulkan RADV (Mesa ACO)** : Pilote graphique optimisé par Valve avec ordonnancement shader ACO.
* **Cache Shader XXL (50 Go)** : [10-amd-gaming.conf](files/system/etc/environment.d/10-amd-gaming.conf) configure `MESA_SHADER_CACHE_MAX_SIZE=50G` pour éliminer les micro-saccades (stuttering) dues à la recompilation fréquente des shaders.
* **Support AMD GPU Services (AGS)** : Activé sous Proton (`PROTON_ENABLE_AMD_AGS=1`) pour exploiter nativement le FidelityFX et le FSR dans les titres compatibles.
* **Overdrive GPU en un clic** : Commande `ujust toggle-amdgpu-overdrive` pour activer `amdgpu.ppfeaturemask=0xffffffff` et libérer les fréquences, tensions (undervolt) et courbes de ventilation personnalisées dans **LACT**.

### 🖥️ Bureau GNOME Vanilla & Performance
* **Zéro extension bloatware** : Purge intégrale des extensions préinstallées (*compiz-windows-effect*, *magic-lamp*, *logomenu*, *hotedge*, etc.).
* **Schémas dconf & glib propres** : Recompilation propre des schémas dconf sans résidus orphelins.
* **Gestionnaire d'extensions dédié** : **ExtensionManager** est préinstallé en Flatpak pour vous laisser le choix exclusif de vos extensions utilisateur.
* **Raccourcis productivité** : `Ctrl+Alt+T` pour ouvrir le terminal Ptyxis et `Ctrl+Shift+Esc` pour lancer Mission Center.

### 🧹 Debloat Chirurgical
* **Android / Waydroid** : Suppression complète de Waydroid et des bibliothèques Binder (`libgbinder`, `python3-gbinder`).
* **Services Serveur Cockpit** : Désinstallation des 6 paquets Cockpit et arrêt des sockets réseau d'administration web inutiles.
* **Consoles portables & Laptops** : Suppression des démons handhelds (`hhd`, `inputplumber`), outils Framework (`fw-ectool`, `fw-fanctrl`) et outils mobiles APU (`ryzenadj`).
* **Périphériques superflus** : Suppression des pilotes Wiimote Nintendo (`xwiimote-ng`) et du protocole TV HDMI-CEC (`libcec`, `linux-cec`).

### 🐚 Terminal & Environnement Shell
* **Fish Shell préconfiguré** : Chargement automatique de Starship, historique optimisé et désactivation du message d'accueil d'origine.
* **Prompt Starship complet** : Thème personnalisé avec symboles Nerd Fonts (`FiraCode`, `JetBrainsMono`, `Hack`).
* **Fastfetch** : Configuration élégante affichant les détails matériels complets (CPU Ryzen, GPU Radeon, pilotes).

---

## 🛠️ Boîte à Outils `ujust` (Commandes Pratiques)

Bazzora inclut des commandes interactives prêtes à l'emploi :

```bash
# Débloquer l'overdrive AMD (fréquences, undervolt, ventilation LACT)
ujust toggle-amdgpu-overdrive

# Forcer l'upgrade FSR 4 sur les jeux compatibles (RDNA 3/4)
ujust toggle-fsr4

# Mettre à jour tout le système (OSTree, Flatpaks, conteneurs et brew en parallèle)
ujust update

# Restaurer les configurations utilisateur (/etc/skel vers $HOME)
ujust restore-skel

# Configurer le pare-feu pour la liaison smartphone GSConnect
ujust setup-gsconnect

# Installer ou gérer Visual Studio Code via Homebrew
ujust manage-vscode install
```

---

## 🚀 Installation & Rebase

### Option A — Installation directe via l'ISO Bazzora (Clé USB)
Vous pouvez générer votre propre fichier ISO d'installation amorçable directement depuis GitHub :
1. Sur votre dépôt GitHub, allez dans l'onglet **Actions**.
2. Dans la colonne de gauche, cliquez sur le workflow **Build Installer ISO**.
3. Cliquez sur le bouton **Run workflow** pour lancer la création de l'ISO.
4. Une fois le workflow terminé, téléchargez l'image ISO (`bazzora-latest.iso`) dans les artefacts générés.
5. Flashez l'ISO sur une clé USB (avec [Ventoy](https://www.ventoy.net/) ou [BalenaEtcher](https://etcher.balena.io/)) et installez Bazzora directement sur votre machine !

---

### Option B — Migration par Rebase (depuis Bazzite / Silverblue existante)
Pour migrer une installation existante vers Bazzora :

#### 1. Rebase vers l'image non signée initiale
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/0xreaven/bazzora:latest
```

### 2. Redémarrer
```bash
systemctl reboot
```

### 3. Première initialisation de votre environnement (Post-Rebase)
> [!NOTE]
> Sur une **nouvelle installation propre (ISO)**, votre compte est automatiquement créé avec Fish, Starship et Fastfetch par défaut.
> Si vous venez d'effectuer une migration par **rebase**, le système ne modifie pas votre dossier personnel existant. Exécutez simplement cette commande pour déployer vos configurations Bazzora et configurer le terminal Ptyxis :

```bash
ujust restore-skel
```
*(Choisissez `M` pour copier sans écraser ou `E` pour réinitialiser. Vos configurations Fish, Starship, Fastfetch et le profil Ptyxis sont immédiatement appliqués !)*

### 4. Rebase vers l'image signée (avec vérification Cosign)
```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/0xreaven/bazzora:latest
```

### 5. Redémarrage final
```bash
systemctl reboot
```

---

## 🛡️ Sécurité & Retour Arrière (Rollback)

### Retour arrière instantané
L'avantage de l'immuabilité rpm-ostree est que vous pouvez revenir à votre déploiement précédent à tout moment :

* **Depuis le système actif :**
  ```bash
  rpm-ostree rollback
  systemctl reboot
  ```
* **Depuis le menu de démarrage GRUB :** Sélectionnez simplement la deuxième entrée pour démarrer sur votre ancien état système.

### Vérification de la signature d'image Cosign
Vous pouvez vérifier l'authenticité et l'intégrité de l'image avec la clé publique fournie :
```bash
cosign verify --key cosign.pub ghcr.io/0xreaven/bazzora
```

---

## 📜 Licence & Remerciements

Distribué sous licence **Apache 2.0**. Voir [LICENSE](LICENSE) pour plus de détails.

Remerciements aux projets qui rendent cette image possible :
* [Fedora Silverblue](https://fedoraproject.org/silverblue/) & [Universal Blue](https://universal-blue.org/)
* [Bazzite](https://bazzite.gg/) pour le noyau gaming et la stack Mesa
* [BlueBuild](https://blue-build.org/) pour le moteur de construction déclaratif
* [CachyOS](https://cachyos.org/) pour les patches noyau et ordonnanceurs
