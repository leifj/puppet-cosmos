
# inspired by http://blogs.thehumanjourney.net/oaubuntu/entry/kvm_vmbuilder_puppet_really_automated

define cosmos::kvm($domain, $ip, $netmask, $resolver, $gateway, $memory='512', $rootsize='20G', $cpus = '1' ) {
  exec { "create_cosmos_vm_${name}":
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    timeout => 3600,
    command => "virsh destroy $name ; virsh undefine $name ; /usr/bin/vmbuilder \
      kvm ubuntu  -d /var/lib/libvirt/images/$name -m $memory --cpus=$cpus --rootsize=$rootsize \
      --domain=$domain --ip=$ip --mask=$netmask --gw=$gateway --dns=$resolver \
      --hostname=$name --ssh-key=/root/.ssh/authorized_keys --libvirt=qemu:///system \
      --verbose --firstboot=/root/bootstrap-cosmos.sh \
      --copy=/root/cosmos_1.2-2_all.deb --addpkg=openssh-server --addpkg=unattended-upgrades && virsh start $name" ,
    unless => "/usr/bin/test -d /var/lib/libvirt/images/$name",
  }
}
