{ pkgs, lib, ... }:
{
  # Default VM hardware resources (can be overridden in project's vm.nix)
  virtualisation.memorySize = lib.mkDefault 8192;
  virtualisation.cores = lib.mkDefault 4; # 4 cores by default for performance
  virtualisation.graphics = lib.mkDefault false; # Disable graphics by default for headless development

  # Basic rich set of developer tools
  environment.systemPackages = with pkgs; [
    openssh
    bpftrace
    cflow
    python3
    gcc
    lcov
    helix
    emacs
  ];

  # Default system state version
  system.stateVersion = lib.mkDefault "25.11";
}
