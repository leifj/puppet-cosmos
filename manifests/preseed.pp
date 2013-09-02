class cosmos::preseed {
  define preseed_package ( $ensure, $domain) {
    file { "/tmp/$name.preseed":
      content => template("mnt/$name.preseed"),
      mode => 600,
      backup => false,
    }
    package { "$name":
      ensure => $ensure,
      responsefile => "/tmp/$name.preseed",
      require => File["/tmp/$name.preseed"],
    }
  }
}
