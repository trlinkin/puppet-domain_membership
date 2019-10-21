# == Class: domain_membership
#
# Full description of class domain_membership here.
#
# === Parameters
#
# [*domain*]
#   AD domain which the node should be a member of.
# [*username*]
#   Username of domain user with machine join privileges.
# [*password*]
#   Password for domain user. This can optionally be passed as a "Secure
#   String" if the `$secure_password` parameter is true.
# [*secure_password*]
#   Indicate that the password provided is a "Secure String." Valid values
#   are `true` and `false`. Defaults to `false`.
# [*machine_ou*]
#   OU in the domain to create the machine account in. This is used durring
#   the initial join process. It cannot move the machine account later on.
# [*resetpw*]
#   Whether or not to force a machine password reset if for some reason the trust
#   between the domain and the machine becomes unsyncronized. Valid values are `true`
#   and `false`. Defaults to `true`.
# [*join_options*]
#   A bit flag for setting options for joining a domain.
#   See: http://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx
#   Defaults to '1'.
# [*reboot*]
#   Whether or not the computer should reboot after a domain join.
#   Valid values are 'true' and 'false'. Defaults to 'true'.
# [*user_domain*]
#   Domain the account with the specified username belongs to, if different
#   from the domain the machine is being joined to.
#
# === Examples
#
#  class { domain_membership:
#    domain        => 'pupetlabs.lan',
#    username      => 'administrator',
#    password      => 'fake5ecret',
#    join_options  => '3',
#  }
#
# === Authors
#
# Thomas Linkin <tom@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013 Thomas Linkin, unless otherwise noted.
#
class domain_membership (
  Stdlib::Fqdn $domain,
  String $username,
  Variant[String,Sensitive] $password,
  Optional[Stdlib::Fqdn] $user_domain           = undef,
  Boolean $secure_password                      = false,
  String $machine_ou                            = '$null',
  Boolean $resetpw                              = true,
  Boolean $reboot                               = true,
  Enum['immediately', 'finished'] $reboot_apply = 'finished',
  Pattern[/\d+/] $join_options                  = '1',
){

  $this_password = ($password =~ Sensitive) ? {
    true  => $password,
    false => Sensitive($password)
  }

  # Use Either a "Secure String" password or an unencrypted password
  if $secure_password {
    $_password = ("(New-Object System.Management.Automation.PSCredential('user',(convertto-securestring '${this_password}'))).GetNetworkCredential().password")
  }else{
    $_password = "'${this_password}'"
  }

  # Allow an optional user_domain to accomodate multi-domain AD forests
  if $user_domain {
    $_user_domain = $user_domain
    $_reset_username = "${user_domain}\\${username}"
  } else {
    $_user_domain = $domain
    $_reset_username = $username
  }
  exec { 'join_domain':
    environment => [ "Password=${this_password}" ],
    command     => "exit (Get-WmiObject -Class Win32_ComputerSystem).JoinDomainOrWorkGroup('${domain}',\$Password','${username}@${_user_domain}',${machine_ou},${join_options}).ReturnValue",
    unless      => "if((Get-WmiObject -Class Win32_ComputerSystem).domain -ne '${domain}'){ exit 1 }",
    provider    => powershell,
  }

  if $resetpw {
    exec { 'reset_computer_trust':
      environment => [ "Password=${_password}" ],
      command     => "netdom /RESETPWD /UserD:${_reset_username} /PasswordD:\$Password /Server:${domain}",
      unless      => "if ($(nltest /sc_verify:${domain}) -match 'ERROR_INVALID_PASSWORD') {exit 1}",
      provider    => powershell,
      require     => Exec['join_domain'],
    }
  }

  if $reboot {
    reboot { 'after_domain_join':
      subscribe => Exec['join_domain'],
      apply     => $reboot_apply,
    }
  }
}
