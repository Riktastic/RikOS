{
  # Colmena meta section: set default Nixpkgs and SSH user if needed
  meta = {
    nixpkgs = import <nixpkgs> { };
    # sshUser = "root"; # Uncomment and set if you use a non-root SSH user
  };

  # Define your hosts here. Each host imports its device config.
  hercules = { ... }: {
    imports = [ ./devices/hercules.nix ];
    # Optionally, set a custom SSH address:
    # deployment.targetHost = "hercules.example.com";
  };

  lira = { ... }: {
    imports = [ ./devices/lira.nix ];
  };

  # Add more hosts as needed:
  # myserver = { ... }: {
  #   imports = [ ./devices/myserver.nix ];
  # };
} 