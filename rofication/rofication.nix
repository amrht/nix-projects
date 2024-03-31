{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "rofication-build";
  src = ./rofication.tar.gz;

  buildInputs = [
    pkgs.python310
    pkgs.python310Packages.setuptools
    pkgs.python310Packages.dbus-python
    pkgs.python310Packages.pygobject3
  ];

  buildPhase = ''
    python setup.py build
  '';

  installPhase = ''
    mkdir -p $out/rofication
    cp -r build/* $out/rofication
    export PYTHONPATH=$out/rofication:$PYTHONPATH
  '';
}
