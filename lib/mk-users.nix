# mk-users function for creating system users
{ specialArgs }:

{ lib, pkgs, user-paths, ... }:

let
  users = map (user-path:
    import user-path (specialArgs // { inherit pkgs; })
  ) user-paths;
in
{
  users.users = lib.mkMerge (map (user: {
    ${user.username} = user.system-user;
  }) users);

  imports = lib.flatten (map (user: user.system-modules or [ ]) users);
}