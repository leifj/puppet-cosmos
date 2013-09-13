class cosmos::httpsproxy ($listen_ip,$certs = ['/etc/ssl/private/server.pem']) {
   include ufw
   package {'ssl-cert': ensure => latest }
   file {'/etc/ssl/private/server.pem':
      ensure => file,
      source => '/etc/ssl/private/snakeoil.pem',
      replace => false,
   }
   exec {'generate-snakeoil':
      command => 'cat /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/certs/ssl-cert-snakeoil.pem > /etc/ssl/private/snakeoil.pem',
      notify => File['/etc/ssl/private/server.pem'],
      creates => '/etc/ssl/private/snakeoil.pem',
      require => Package['ssl-cert'],
   }
   Exec['generate-snakeoil'] -> File['/etc/ssl/private/server.pem']
   pound::entry {"$name-httpsproxy-443":
      listen_ip => $listen_ip,
      listen_port => '443',
      listen_protocol => 'ListenHTTPS',
      head_require => 'Host:.*',
      backend_ip => '127.0.0.1',
      backend_port => '80',
      certs => $certs
   }
   ufw::allow { "allow-pound-https":
      ip   => 'any',
      port => 443
   }
}
