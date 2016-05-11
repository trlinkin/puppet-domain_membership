# == Class: domain_membership
#
# Full description of class domain_membership here.
#
# === Parameters
#
# [*domain*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
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
  $domain,
  $username,
  $password,
  $secure_password = false,
  $machine_ou      = undef,
  $resetpw         = true,
  $reboot          = true,
  $join_options    = '1',
  $user_domain     = undef,
){

  # Validate Parameters
  validate_string($username)
  validate_string($password)
  validate_bool($resetpw)
  validate_re($join_options, '\d+', 'join_options parameter must be a number.')
  unless is_domain_name($domain) {
    fail('Class[domain_membership] domain parameter must be a valid rfc1035 domain name')
  }

  # Use Either a "Secure String" password or an unencrypted password
  if $secure_password {
    $_password = "(New-Object System.Management.Automation.PSCredential('user',(convertto-securestring '${password}'))).GetNetworkCredential().password"
  }else{
    $_password = "'${password}'"
  }

  # Allow an optional OU location for the creation of the machine
  # account to be specified. If unset, we use the powershell representation
  # of nil, which is the `$null` variable.
  if $machine_ou {
    validate_string($machine_ou)
    $_machine_ou = "'${machine_ou}'"
  }else{
    $_machine_ou = '$null'
  }

  # Allow an optional user_domain to accomodate multi-domain AD forests
  if $user_domain {
    unless is_domain_name($user_domain) {
      fail('Class[domain_membership] user_domain parameter must be a valid rfc1035 domain name')
    }
    $_user_domain = $user_domain
    $_reset_username = "${user_domain}\\${username}"
  } else {
    $_user_domain = $domain
    $_reset_username = $username
  }

  # Since the powershell command is combersome, we'll construct it here for clarity... well, almost clarity
  #
  $command = "(Get-WmiObject -Class Win32_ComputerSystem).JoinDomainOrWorkGroup('${domain}',${_password},'${username}@${_user_domain}',${_machine_ou},${join_options})"

  exec { 'join_domain':
    command  => "exit ${command}.ReturnValue",
    unless   => "if((Get-WmiObject -Class Win32_ComputerSystem).domain -ne '${domain}'){ exit 1 }",
    provider => powershell,
  }

  if $resetpw {
    exec { 'reset_computer_trust':
      command  => "netdom /RESETPWD /UserD:${_reset_username} /PasswordD:${_password} /Server:${domain}",
      unless   => "if ($(nltest /sc_verify:${domain}) -match 'ERROR_INVALID_PASSWORD') {exit 1}",
      provider => powershell,
      require  => Exec['join_domain'],
    }
  }

  if $reboot {
    reboot { 'after':
      subscribe => Exec['join_domain'],
      apply     => finished,
    }
  }
}
