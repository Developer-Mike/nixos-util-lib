# mk-users function for creating system users
{ specialArgs }:

{ user-paths }:

{ pkgs, ... }:

{
  # Loop through users and create ${user.username}: ${user.system-user} mapping
  users.users = builtins.listToAttrs (map (user-path:
    let
      user = import user-path (specialArgs // { inherit pkgs; });
    in
    {
      name = user.username;
      value = user.system-user;
    }
  ) user-paths);
}
