# This manifest is managed using cosmos

class mnt::cosmos {
   file {'motd':
      ensure   => file,
      path     => '/etc/motd.tail',
      mode     => 0644,
      content  => "

This mashine (${::fqdn}) is managed by hostmaster@mnt.se and 
is running ${::operatingsystem} ${::operatingsystemrelease} using puppet version ${::puppetversion} and cosmos

"
   }
}
