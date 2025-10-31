{
  description = "NixOS Utility Library by mika.dev";

  inputs = { };

  outputs = { ... } @ inputs: {
    mk-system = import ./lib/mk-system.nix;
  };
}
