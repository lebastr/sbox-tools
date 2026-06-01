{ pkgs, ... }:
{
  # This is a slave configuration file of the virtual machine for the restic-audit project.
  # All basic parameters (SSH keys, UID, mount point, tmux) are configured automatically.

  # Specific packages for building, testing, and working with restic-audit inside the VM
  environment.systemPackages = with pkgs; [
    restic
    rclone
  ];

  # Disk and persistent storage configurations for Nix Store
  virtualisation.diskSize = 10240;            # Increase disk size to 10 GB
  virtualisation.writableStoreUseTmpfs = false; # Write overlay nix-store to the qcow2 disk, not to RAM
}
