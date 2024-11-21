#!/usr/bin/env bash 

cd ./pkgs/by-name
shopt -s nullglob

for dir in ./*/
do
    cd ${dir}
    nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
    cd ..
done
