# Forwardable Kerberos tickets, needed so credentials can be delegated
# over GSSAPI SSH
{ ... }:

{
  security.krb5 = {
    enable = true;
    settings.libdefaults.forwardable = true;
  };

  # Only used for kinit/GSSAPI ssh; keep krb5 out of PAM so a wrong
  # password is a normal retry instead of a pam_ccreds "service module" error.
  security.pam.krb5.enable = false;
}
