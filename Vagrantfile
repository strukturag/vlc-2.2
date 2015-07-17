# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.define "linux-64bit" do |linux64bit|
    linux64bit.vm.box = "ubuntu/vivid64"

    linux64bit.vm.provision "shell", path: "scripts/vagrant/001_bootstrap.sh"
    linux64bit.vm.provision "shell", path: "scripts/vagrant/010_checkout.sh", privileged: false
    linux64bit.vm.provision "shell", path: "scripts/vagrant/020_dependencies.sh", privileged: false
    linux64bit.vm.provision "shell", path: "scripts/vagrant/030_compile.sh", privileged: false
    linux64bit.vm.provision "shell", path: "scripts/vagrant/040_package.sh", privileged: false
  end

  # Using a private network caused very slow network performance against the
  # local apt-cacher proxy.
  config.vm.network "public_network", bridge: "eth0"

  config.vm.provider "virtualbox" do |vb|
    # Don't show the VirtualBox GUI when booting the machine.
    vb.gui = false

    # I/O APIC must be enabled to support more than 1 cpu on 32bit systems
    # http://makandracards.com/jan0sch/24843-vagrant-virtualbox-32bit-systems-and-more-than-one-cpu
    vb.customize ["modifyvm", :id, "--ioapic", "on"]

    # Use multiple cpus to speed up building.
    vb.memory = 4096
    vb.cpus = 8
  end

end
