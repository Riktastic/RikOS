# Media Suite
#
# This suite provides a comprehensive set of tools for multimedia creation, editing, and playback.
#
# Packages are grouped and ordered as follows:
#   1. Video (players, converters, editors)
#   2. Audio (editors, players, tag editors)
#   3. Image/Photo (editors, RAW/photo tools, vector graphics)
#   4. 3D/Creative (3D modeling, home design)
#   5. Disc Burning (CD/DVD/Blu-ray burning)
#   6. Other (streaming/recording, miscellaneous)
#
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  # --- Video ---
  vlc                 # Video player
  ffmpeg              # Media conversion
  handbrake           # Video transcoder
  kdePackages.kdenlive # Video editor
#  davinci-resolve     # Video editor (non-free, if available), take a lot of ram to build.

  # --- Audio ---
  audacity            # Audio editor
  kdePackages.elisa   # Music player
  picard              # Audio tag editor

  # --- Image/Photo ---
  gimp                # Image editor
  darktable           # RAW photo editor
  digikam             # Photo tag editor
  inkscape            # Vector graphics editor
  imagemagick         # Image conversion tools

  # --- 3D/Creative ---
  blender             # 3D editor
  sweethome3d.application # Home designer

  # --- Disc Burning ---
  kdePackages.k3b                 # CD/DVD/Blu-ray burning

  # --- Other ---
  obs-studio          # Video recording/streaming
];
}
