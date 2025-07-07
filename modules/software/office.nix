# Office Suite
#
# This suite provides essential office, productivity, and document tools.
#
# Packages are grouped and ordered as follows:
#   1. Office Suite (main office applications)
#   2. Spell Checking (dictionaries and spell check tools)
#   3. PDF/eBook (PDF and eBook readers)
#   4. Note-taking (note and markdown tools)
#
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  # --- Office Suite ---
  libreoffice-qt6                     # LibreOffice, office suite

  hunspell                # Spell checker
  hunspellDicts.nl_nl     # Dutch hunspell dictionary
  hunspellDicts.en_US     # English (US) hunspell dictionary

  # --- Screenshot ---
  kdePackages.spectacle   # Screenshot tool

  # --- PDF and eBook Management ---
  evince                  # PDF reader (GTK)
  kdePackages.okular      # PDF/eBook reader (KDE)

  # --- Note-taking ---
  obsidian                # Markdown note-taking
];
}
