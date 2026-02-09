{ pkgs, ... } @ args:

{
  username = "username";
  config = import ../config/user.nix args;

  system-user = {
    shell = pkgs.zsh;

    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];

    initialPassword = "1234";
  };

  home-manager-user = {
    imports = [

    ];
  };
}
