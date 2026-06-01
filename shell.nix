{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "sbox-tools-dev-shell";

  # Specify only system dependencies to ensure a pure environment
  buildInputs = [
    pkgs.openssh
    pkgs.git
    pkgs.coreutils
    pkgs.iproute2 # contains ss utility
  ];

  shellHook = ''
    # Natively fix VM_DIR to the local root
    export VM_DIR="${toString ./.}"

    # By default for developing the tools themselves, supply local vm.nix
    export SBOX_CONFIG_NIX="$VM_DIR/vm.nix"

    # Add local folder to the beginning of PATH, so that we run
    # exactly the local mutable files in real-time!
    export PATH="$VM_DIR:$PATH"

    echo ""
    echo "============================================================"
    echo "🛡️  sbox NixOS VM Tools - DEVELOPMENT SHELL ACTIVE"
    echo "============================================================"
    echo "🔧 Local scripts are linked directly from: $VM_DIR"
    echo "   Any changes in the code apply INSTANTLY!"
    echo "============================================================"
    echo "Usage:"
    echo "  sbox-run                  - Automatic build and background startup of the VM"
    echo "  sbox-connect              - Interactive login to the shared tmux VM session"
    echo "  sbox-connect --run 'cmd'  - Send command for execution in tmux"
    echo "  sbox-connect --read       - View current tmux text screen"
    echo "  sbox-connect --exec 'cmd' - Quiet execution of command in VM shell"
    echo "============================================================"
    echo ""
  '';
}
