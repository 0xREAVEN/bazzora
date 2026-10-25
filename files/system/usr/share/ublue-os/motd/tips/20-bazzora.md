*Une mise à jour pose problème ?* `ujust bazzora-update` épingle toujours la version précédente : choisissez-la au menu de démarrage, puis `rpm-ostree rollback`
*Envie d'undervolter ou de régler les ventilateurs de la Radeon ?* Activez l'overdrive avec `ujust toggle-amdgpu-overdrive`, puis ouvrez **LACT**
*Jeu compatible FSR 3.1 ?* `ujust toggle-fsr4` force l'upscaling FSR 4 sur les Radeon RDNA 4 sous Proton
*Écran HDR ?* `ujust toggle-proton-hdr` active Proton Wayland et le HDR natif sous GNOME
*Un doute après une mise à jour ?* `ujust bazzora-doctor` vérifie les réglages gaming (NTSYNC, BBR, LACT, VRR, cache de shaders…)
Le cache de shaders Mesa est porté à **50 Go** : moins de saccades dans les gros jeux, même après de nombreuses heures de jeu
*Besoin d'un logiciel absent de Flathub ?* Installez-le dans un conteneur Distrobox plutôt qu'avec rpm-ostree~[En savoir plus](https://docs.bazzite.gg/Installing_and_Managing_Software/Distrobox/)
*Relier votre téléphone ?* `ujust setup-gsconnect` ouvre les ports du pare-feu pour GSConnect
