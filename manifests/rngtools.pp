class cosmos::rngtools {
   package {"rng-tools":
      ensure    => latest
   }
   file {"/etc/default/rng-tools":
      content   => template("mnt/rng-tools.erp"),
      notify    => Service["rng-tools"],
      require   => Package["rng-tools"]
   }
   service {"rng-tools":
      ensure    => running,
      pattern   => "/usr/sbin/rngd",
      hasstatus => false,
      require   => File["/etc/default/rng-tools"]
   }
}
