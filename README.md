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
 * ```reboot```       - [Optional] Whether or not to reboot when the machine joins the domain. (reboot by default)
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

Changelog
---------

* Wout van Heeswijk <wout.van.heeswijk@gmail.com> -- Added a reboot option
* Ben Ford <ben.ford@puppetlabs.com> -- Use the join return value for success
* Thomas Linkin <trlinkin@gmail.com> -- Update module dependancy
* Thomas Linkin <trlinkin@gmail.com> -- Move license to LICENSE file to conform with Forge rules.
* Thomas Linkin <trlinkin@gmail.com> -- Correct some rubbish typos in the docs
* Thomas Linkin <trlinkin@gmail.com> -- Bunp version to 1.0.0 for release
* Thomas Linkin <trlinkin@gmail.com> -- Converting to metadata.json
* Thomas Linkin <trlinkin@gmail.com> -- Clean up fjoinoptions parameter
* Thomas Linkin <trlinkin@gmail.com> -- Remove `false` parameter in favor of `fjoinoption`
* Thomas Linkin <trlinkin@gmail.com> -- Merge remote-tracking branch 'beard/fjoinoption'
* Thomas Linkin <tom@puppetlabs.com> -- Merge pull request #2 from ghoneycutt/patch-1
* Josh Beard <beard@puppetlabs.com> -- Fix alignment of parameter list in README
* Josh Beard <beard@puppetlabs.com> -- Add 'fjoinoption' as a parameter
* Garrett Honeycutt <github@garretthoneycutt.com> -- Update README.md
* Thomas Linkin <trlinkin@gmail.com> -- Fill out docs further
* Thomas Linkin <trlinkin@gmail.com> -- Add $resetpw parameter
* Thomas Linkin <trlinkin@gmail.com> -- Readme content added
* Thomas Linkin <trlinkin@gmail.com> -- Ensure resource relationships
* Thomas Linkin <trlinkin@gmail.com> -- Reset Computer Account Password
* Thomas Linkin <trlinkin@gmail.com> -- Initial Commit

Support
-------

Please log tickets and issues at our [Projects site](http://www.github.com/trlinkin/puppet-domain_membership)
