{pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "ilia-build";
  src = ./ilia.tar.gz;
  
  nativeBuildInputs = [ pkgs.makeWrapper ];
  
  buildInputs = [
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
    pkgs.cairo
    pkgs.gtk3
    pkgs.gdk-pixbuf
    pkgs.glib
    pkgs.tracker
    pkgs.libgee
    pkgs.vala
    pkgs.json-glib
    pkgs.gobject-introspection
    pkgs.gtk-layer-shell
    pkgs.stdenv
  ];

  buildPhase = ''
    mkdir -p build-dir
    tar -xzf $src -C build-dir --strip-components=1
    mkdir -p build
    cd build
    meson --prefix=$out ../build-dir
    ninja
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp src/ilia $out/bin
    echo "Compiling Schemas"
    mkdir -p $out/share/glib-2.0/schemas  # Create directory for schema file
    cp -r ../build-dir/data/* $out/share/glib-2.0/schemas/
    glib-compile-schemas --targetdir=$out/share/glib-2.0/schemas ../build-dir/data/
    wrapProgram "$out/bin/ilia" --set XDG_DATA_DIRS "$out/share/gsettings-schemas/ilia-build"
  '';
}