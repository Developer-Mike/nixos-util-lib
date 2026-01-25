{
  description = "NixOS Utility Library by mika.dev";

  inputs = { };

  outputs = { ... }: {
    mk-system = import ./lib/mk-system.nix;
  };
}
