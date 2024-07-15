Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  # Configuración de red privada con IP fija
  config.vm.network "private_network", ip: "192.168.50.20"

  # Provisioning para instalar Puppet y wget
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y puppet wget
  SHELL

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "site.pp"
    puppet.module_path    = "modules"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end
end
