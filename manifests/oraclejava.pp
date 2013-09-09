class cosmos::oraclejava {
   file {'oracle-license-selections':
       ensure   => 'file',
       path     => '/etc/oracle-java-license',
       content  => template("cosmos/oracle-java-license.erp")
   }
   exec {'oracle-license':
       require  => File['oracle-license-selections'],
       command => 'debconf-set-selections < /etc/oracle-java-license'
   }
   apt::ppa { 'ppa:webupd8team/java': }
   package {'oracle-java7-installer': 
      ensure    => 'latest',
      require   => Exec['oracle-license']
   }
}
