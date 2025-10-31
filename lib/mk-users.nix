# mk-users function for creating system users
{ pkgs, user-paths, ... } @ args:

{
  # Loop through users and create ${user.username}: ${user.system-user} mapping
  users.users = builtins.listToAttrs (map (user-path:
    let user = import user-path args;
    in {
      name = user.username;
      value = user.system-user;
    }
  ) user-paths);
}
