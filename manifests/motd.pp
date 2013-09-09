# This manifest is managed using cosmos

class cosmos::cosmos {
   file {'motd':
      ensure   => file,
      path     => '/etc/motd.tail',
      mode     => 0644,
      content  => "

This mashine (${::fqdn}) is is running ${::operatingsystem} ${::operatingsystemrelease} 
using puppet version ${::puppetversion} and cosmos

"
   }
}
