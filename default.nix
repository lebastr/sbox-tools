{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "sbox-tools";
  src = ./.;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  # Do not unpack external archives, work directly with files in src
  dontUnpack = false;

  installPhase = ''
    mkdir -p $out/bin

    # 1. Copy files to a flat bin/ folder
    cp sbox-run $out/bin/sbox-run
    cp sbox-connect $out/bin/sbox-connect
    cp sbox-root $out/bin/sbox-root
    cp core-contract.nix $out/bin/core-contract.nix
    cp default-config.nix $out/bin/default-config.nix
    cp empty-vm.nix $out/bin/empty-vm.nix

    chmod +x $out/bin/sbox-run
    chmod +x $out/bin/sbox-connect

    # 2. Wrap executable files, hardcoding VM_DIR to /nix/store
    #    and injecting necessary system utilities
    wrapProgram $out/bin/sbox-run \
      --set VM_DIR "$out/bin" \
      --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.openssh
        pkgs.git
        pkgs.nix
        pkgs.coreutils
        pkgs.iproute2
      ]}

    wrapProgram $out/bin/sbox-connect \
      --set VM_DIR "$out/bin" \
      --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.openssh
        pkgs.git
        pkgs.coreutils
      ]}
  '';
}
