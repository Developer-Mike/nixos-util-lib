# mk-home function for creating Home Manager configurations
{ home-manager, version, user-paths, specialArgs }:

{ pkgs, ... }:
let
  extraSpecialArgs = specialArgs // {
    inherit pkgs;
  };
in
{
  imports = [
    home-manager.nixosModules.home-manager {
      home-manager = {
        inherit extraSpecialArgs;

        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";

        # Loop through users and create ${user.username}: ${user.home-manager-user} mapping
        users = builtins.listToAttrs (map (user-path:
          let user = import user-path extraSpecialArgs;
          in {
            name = user.username;
            value = user.home-manager-user // {
              _module.args.user-secrets = user.secrets;

              home = {
                username = user.username;
                homeDirectory = "/home/${user.username}";
                stateVersion = version;
              };
            };
          }
        ) user-paths);
      };
    }
  ];
}
