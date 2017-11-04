#!/bin/bash

script_name=$(basename $0)

# wine_bin="/home/alex/.PlayOnLinux/wine/linux-amd64/2.13-staging/bin"
# wine_bin="/home/alex/.PlayOnLinux/wine/linux-amd64/2.19-staging/bin"
wine_bin="/home/alex/.PlayOnLinux/wine/linux-amd64/2.20/bin"
installer_msi="/home/alex/Downloads/EpicInstaller-6.6.0.msi"
directx="/home/alex/Downloads/directx_Jun2010_redist.exe"
prefix="/home/alex/.PlayOnLinux/wineprefix/Fortnite"

winecfg="$wine_bin/winecfg"
wine="$wine_bin/wine"

export WINEARCH=win64
export WINEPREFIX="$prefix"
export WINE="$wine"

print_step() { printf "%s %s\n\n" "---->" "$1"; }

sub_winecfg() {
  print_step "Running winecfg"
  $winecfg
}

sub_install() {
  print_step "Installing Launcher"
  $wine msiexec /i "$installer_msi" /q
}

sub_dependencies() {
  if [ ! -f winetricks ]; then
    print_step "Downloading latest winetricks"
    wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    chmod +x winetricks 
  fi

  print_step "Installing Dependencies"
  ./winetricks corefonts d3dcompiler_43 d3dx10 d3dx10_43 d3dx11_42 d3dx11_43 d3dx9 d3dx9_43 directx9 dotnet40 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 xact xinput 

  # wget http://se.archive.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_i386.deb
  # dpkg -i libpng12-0_1.2.54-1ubuntu1_i386.deb
  # rm libpng12-0_1.2.54-1ubuntu1_i386.deb

  # Install DirectX from microsoft: https://www.microsoft.com/en-us/download/details.aspx?id=8109
  # print_step "Installing directx"
  # $wine $directx
  # $wine $prefix/drive_c/temp/DXSETUP.exe
}

sub_launcher() {
  print_step "Running Launcher"
  $wine "$prefix/drive_c/Program Files (x86)/Epic Games/Launcher/Portal/Binaries/Win32/EpicGamesLauncher.exe" -OpenGL
#$wine "$prefix/drive_c/Program Files (x86)/Epic Games/Launcher/Portal/Binaries/Win32/EpicGamesLauncher.exe" -SkipBuildPatchPrereq -OpenGL 
}

sub_purge() {
  print_step "Purging Old Prefix"
  rm -rf $prefix
  mkdir $prefix
}

sub_fresh_install() {
  local purge=false
  if purge; then
    sub_purge
  fi

  sub_winecfg
  sub_dependencies
  sub_install
  sub_launcher
}

sub_fortnite() {
  print_step "Launching Fortnite"
  $wine "$prefix/drive_c/Program Files/Epic Games/Fortnite/FortniteGame/Binaries/Win64/FortniteClient-Win64-Shipping.exe" -epicapp=Fortnite -epicenv=Prod -EpicProtal -MCPRegion=NA
}

sub_help() {
    printf "
Usage:
  ./$script_name <subcommand> [options]

  Subcommands:
    winecfg
    install
    dependencies
    launcher
    fresh_install
    fortnite

  For help with each subcommand run:
  ./$script_name <subcommand> -h|--help\n\n"
}

subcommand=$1
case $subcommand in
  "" | "-h" | "--help")
    sub_help
    ;;
  *)
    # Drop the argument that is the name of the subcommand
    shift

    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
      sub_${subcommand}_help
    else
      sub_$subcommand $@
    fi

    # Report unknown subcommands
    if [ $? = 127 ]; then
      printf "Error: '$subcommand' is not a known subcommand.\n" >&2
      printf "  Run './$script_name --help' for a list of known subcommands.\n" >&2
      exit 1
    fi
    ;;
esac

print_step "Exiting..."
