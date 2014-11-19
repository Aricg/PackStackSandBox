# -*- mode: ruby -*-
# vi: set ft=ruby :
#
require 'yaml'
settings = YAML.load_file 'Vagrantfile.yml'
bridge = settings['bridge']
controller_bridged_ip = settings['controller']['bridged_ip']
controller_private_ip = settings['controller']['private_ip']
compute_bridged_ip = settings['compute']['bridged_ip']
compute_private_ip = settings['compute']['private_ip']

#
system('./build_answerfile')
 
VAGRANTFILE_API_VERSION = "2"
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

 
# Begin controller
config.vm.define "controller" do |controller|
  controller.vm.box = "controller"
  controller.vm.hostname = "controller"
  controller.vm.box_url = "https://build.opnfv.org/downloads/controller.box"

    controller.vm.provider "virtualbox" do |v|

      v.customize ["modifyvm", :id, "--cpus", 1]
      v.customize ["modifyvm", :id, "--memory", 4096]

    end

    controller.vm.network "public_network", :bridge => bridge, ip: controller_bridged_ip, :auto_config => "true", :netmask => "255.255.255.0"
    controller.vm.network "private_network", ip: controller_private_ip

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
  compute.vm.box = "compute"
  compute.vm.hostname = "compute"
  compute.vm.box_url = "https://build.opnfv.org/downloads/compute.box"
 
    compute.vm.provider "virtualbox" do |v|

      v.customize ["modifyvm", :id, "--cpus", 1]
      v.customize ["modifyvm", :id, "--memory", 2096]
      
    end

    compute.vm.network "public_network", :bridge => "docker0", ip: compute_bridged_ip, :auto_config => "true", :netmask => "255.255.255.0"
    compute.vm.network "private_network", ip: compute_private_ip

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
