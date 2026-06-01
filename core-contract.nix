{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
  ];

  # Declaration of interface parameters for the contract with the host
  options.qemu-vm = {
    sharedDir = mkOption {
      type = types.str;
      description = "Absolute path to the shared project directory on the host";
    };
    hostUid = mkOption {
      type = types.int;
      description = "UID of the user on the host for correct RW permissions";
    };
    sshPort = mkOption {
      type = types.int;
      default = 2222;
      description = "Port on the host forwarded to port 22 of the guest";
    };
    sshPublicKey = mkOption {
      type = types.str;
      description = "Contents of the public SSH key for authorization";
    };
  };

  config = {
    # Tmux is an integral part of the contract for the connection facade (sbox-connect) to work
    environment.systemPackages = with pkgs; [
      tmux
    ];

    # Dynamic SSH port forwarding
    virtualisation.forwardPorts = [
      { from = "host"; host.port = config.qemu-vm.sshPort; guest.port = 22; }
    ];

    # Enable SSH server
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    # Allow passwordless sudo for administrators
    security.sudo.wheelNeedsPassword = false;

    # Add SSH key for root
    users.users.root.openssh.authorizedKeys.keys = [
      config.qemu-vm.sshPublicKey
    ];

    # Create a normal user with host UID for conflict-free work with the shared folder
    users.users.user = {
      isNormalUser = true;
      uid = config.qemu-vm.hostUid;
      extraGroups = [ "wheel" "audio" "video" ];
      initialPassword = "";
      openssh.authorizedKeys.keys = [
        config.qemu-vm.sshPublicKey
      ];
    };

    # Autologin to ttyS0 as user 'user'
    services.getty.autologinUser = "user";

    # Map the dedicated secure host folder into the virtual machine
    virtualisation.sharedDirectories = {
      shared_workingtree = {
        source = config.qemu-vm.sharedDir;
        target = "/mnt/shared";
      };
    };

    # Declarative and idiomatic forced mounting of the shared project folder in Read-Only mode
    virtualisation.fileSystems."/mnt/shared" = mkForce {
      device = "shared_workingtree";
      fsType = "9p";
      options = [ "trans=virtio" "version=9p2000.L" "ro" ];
    };

    # Disable NetworkManager online wait during boot for faster startup
    systemd.services.NetworkManager-wait-online.enable = false;

    # Configure NIX_PATH inside the VM
    nix.nixPath = [ "nixpkgs=${pkgs.path}" ];
  };
}
