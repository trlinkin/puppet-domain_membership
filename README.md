domain_membership
=================

Manage Active Directory domain membership with this module.

Parameters
----------

 * ```domain```       - AD domain which the node should be a member of.
 * ```username```     - User with ability to join machines to a Domain.
 * ```password```     - Password for domain joining user.
 * ```machine_ou```   - [Optional] OU in the directory for the machine account to be created in.
 * ```resetpw```      - [Optional] Whether or not to force machine password reset if it becomes out of sync with the domain.
 * ```join_options``` - [Optional] A bit field for options to use when joining the domain. See http://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx Defaults to '1' (default domain join).

Usage
-----

        class { 'domain_membership':
          domain       => 'puppet.example',
          username     => 'joinmember',
          password     => 'sUp3r_s3cR3t!',
          join_options => '3',
        }

Contact
-------

  If you have questions or concerns about this module, email me at tom@puppetlabs.com

Support
-------

Please log tickets and issues at our [Projects site](http://www.github.com/trlinkin/puppet-domain_membership)
