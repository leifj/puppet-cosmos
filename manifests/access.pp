
class cosmos::access ($keys) {
   include stdlib

   file {'authorized_keys':
      path => '/root/.ssh/authorized_keys',
      content => join($keys,"\n")
   }

   include ufw
   ufw::allow { "allow-ssh-from-all":
      ip => any,
      port => 22
   }

   package {'openssh-server':
      ensure => latest
   }

   service {'ssh':
      name    => 'ssh',
      ensure  => running,
      enable  => true,
      require => Package['openssh-server']
   }

}
