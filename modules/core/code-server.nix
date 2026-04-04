{ username, ... }:
{
  services.code-server = {
    enable = true;
    user = username;
    disableGettingStartedOverride = true;
    extensionsDir = "/home/${username}/documents/vscode-dev/ext";
  };
}
