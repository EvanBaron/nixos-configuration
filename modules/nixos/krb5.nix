# Forwardable Kerberos tickets, needed so credentials can be delegated
# over GSSAPI SSH
{ ... }:

{
  security.krb5 = {
    enable = true;
    settings.libdefaults.forwardable = true;
  };
}
