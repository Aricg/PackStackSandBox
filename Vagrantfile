# -*- mode: ruby -*-

# vi: set ft=ruby :
 
VAGRANTFILE_API_VERSION = "2"
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "Centos7"

 
# Begin controller
config.vm.define "controller" do |controller|
controller.vm.hostname = "controller"
  controller.vm.box_url = "https://build.opnfv.org/downloads/controller.box"

    controller.vm.provider "virtualbox" do |v|

      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--memory", 4096]

    end

    controller.vm.network "public_network", :bridge => "docker0", ip:"192.168.1.91", :auto_config => "true", :netmask => "255.255.255.0"
    controller.vm.network "private_network", ip: "192.168.22.92"

  #Example skeleton for using the puppet provider
  config.vm.provision "puppet" do |puppet|
      puppet.options = "--verbose"
      #Example for facter facts
      puppet.facter = {
        "vagrant" => "1"
      }
      #Exaple for Hiera config
      puppet.hiera_config_path = "hiera.yaml"
  end

  config.vm.provision "shell", path: "prepare.sh"

end
  # End controller
 
  # Begin compute
config.vm.define "compute" do |compute|
  compute.vm.hostname = "compute"
  compute.vm.box_url = "https://build.opnfv.org/downloads/compute.box"
 
    compute.vm.provider "virtualbox" do |v|

      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--memory", 2096]
      
    end

    compute.vm.network "public_network", :bridge => "docker0", ip:"192.168.1.93", :auto_config => "true", :netmask => "255.255.255.0"
    compute.vm.network "private_network", ip: "192.168.22.94"

  #Example skeleton for using the puppet provider
  config.vm.provision "puppet" do |puppet|
      puppet.options = "--verbose"
      #Example for facter facts
      puppet.facter = {
        "vagrant" => "1"
      }
      #Exaple for Hiera config
      puppet.hiera_config_path = "hiera.yaml"
  end

  config.vm.provision "shell", path: "prepare.sh"

end
 
end
