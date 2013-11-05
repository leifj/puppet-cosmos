
# inspired by http://blogs.thehumanjourney.net/oaubuntu/entry/kvm_vmbuilder_puppet_really_automated

define cosmos::dhcp_kvm($mac, $repo, $suite='precise', $bridge='br0', $memory='512', $rootsize='20G', $cpus = '1' ) {

  #
  # Create
  #
  file { "/tmp/firstboot_${name}":
    ensure => file,
    content => "#!/bin/sh\ncd /root && sed -i \"s/${name}.${domain}//g\" /etc/hosts && /root/bootstrap-cosmos.sh ${name} ${repo} && cosmos update && cosmos apply\n",
  } ->

  file { "/tmp/files_${name}":
    ensure => file,
    content => "/root/cosmos_1.2-2_all.deb /root\n/root/bootstrap-cosmos.sh /root\n",
  } ->

  exec { "check_kvm_enabled_${name}":
    command => "/usr/sbin/kvm-ok",
  } ->

  exec { "create_cosmos_vm_${name}":
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    timeout => '3600',
    command => "virsh destroy $name || true ; virsh undefine $name || true ; /usr/bin/vmbuilder \
    kvm ubuntu -d /var/lib/libvirt/images/$name -m $memory --cpus $cpus --rootsize $rootsize --bridge $bridge \
    --hostname $name --ssh-key /root/.ssh/authorized_keys --suite $suite --flavour virtual --libvirt qemu:///system \
    --verbose --firstboot /tmp/firstboot_${name} --copy /tmp/files_${name} \
    --addpkg openssh-server --addpkg unattended-upgrades > /tmp/vm-$name-install.log 2>&1" ,
    unless => "/usr/bin/test -d /var/lib/libvirt/images/${name}",
    before => File["${name}.xml"],
    require => [Package['python-vm-builder'],
                Exec["check_kvm_enabled_${name}"],
                ],
  }

  #
  # Start
  #
  file { "${name}.xml":
    ensure  => 'present',
    path    => "/etc/libvirt/qemu/${name}.xml",
  } ->

  cosmos_kvm_replace { "replace_mac_${name}":
    file                   => "/etc/libvirt/qemu/${name}.xml",
    pattern_no_slashes     => "<mac address=\\x27.+\\x27\\/>",      # \x27 is single quote in perl
    replacement_no_slashes => "<mac address=\\x27${mac}\\x27\\/>",  # \x27 is single quote in perl
  } ->

  exec { "start_cosmos_vm_${name}":
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    timeout => '60',
    command => "virsh start $name",
    onlyif  => "grep -q \"<mac address='${mac}'/>\" /etc/libvirt/qemu/${name}.xml",
    unless  => "virsh list | egrep -q \\ ${name}\\ +running",
    require => [Exec["check_kvm_enabled_${name}"],
                ],
  }

}


# from http://projects.puppetlabs.com/projects/puppet/wiki/Simple_Text_Patterns/5
define cosmos_kvm_replace($file, $pattern_no_slashes, $replacement_no_slashes) {
  exec { "/usr/bin/perl -pi -e 's/$pattern_no_slashes/$replacement_no_slashes/' '$file'":
    onlyif => "/usr/bin/perl -ne 'BEGIN { \$ret = 1; } \$ret = 0 if /$pattern_no_slashes/ && ! /$replacement_no_slashes/ ; END { exit \$ret; }' '$file'",
  }
}

