# Module to connect to EPITA's AFS

{ pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "ssh.cri.epita.fr" = {
        extraOptions = {
          GSSAPIAuthentication = "yes";
          GSSAPIDelegateCredentials = "yes";
          PreferredAuthentications = "gssapi-with-mic";
        };
      };
    };
  };

  home.packages = with pkgs; [
    krb5
    sshfs-fuse
    openssh_gssapi
  ];
}
