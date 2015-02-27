# -*- mode: ruby -*-
# vi: set ft=ruby :
#
require 'yaml'
settings = YAML.load_file 'Vagrantfile.yml'

nat_mode = settings['nat_mode']
bridge = settings['bridge']
netmask = settings['netmask']
gateway = settings['gateway']
controller_bridged_ip = settings['controller']['bridged_ip']
controller_private_ip = settings['controller']['private_ip']
compute_bridged_ip = settings['compute']['bridged_ip']
compute_private_ip = settings['compute']['private_ip']

VAGRANTFILE_API_VERSION = "2"
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

# Begin controller
config.vm.define "controller" do |controller|
  controller.vm.box = "controller"
  controller.vm.hostname = "controller"
  controller.vm.box_url = "https://build.opnfv.org/releases/controller.box"

    controller.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--cpus", 1]
      v.customize ["modifyvm", :id, "--memory", 4096]
    end

          if nat_mode.nil? or nat_mode == 0
          puts "nat mode = no " 
          controller.vm.network "public_network", :bridge => bridge, ip: controller_bridged_ip, :auto_config => "true", :netmask => netmask
          controller.vm.network "private_network", ip: controller_private_ip
          controller.vm.provision :shell, :path => "./bin/prepare.sh", :args => gateway
          system('./bin/build_answerfile bridge')

          else
          puts "nat mode = yes " 
          controller.vm.network "private_network", ip: controller_private_ip, :netmask => "255.255.252.0"
          controller.vm.network :forwarded_port, host: 8080, guest: 80
          controller.vm.provision "shell", path: "./bin/prepare.sh", :args => gateway
          system('./bin/build_answerfile nat')
          end

  #Example skeleton for using the puppet provider
  controller.vm.provision "puppet" do |puppet|
      puppet.options = "--verbose"
      #Example for facter facts
      puppet.facter = {
        "vagrant" => "1"
      }
      #Exaple for Hiera config
      puppet.hiera_config_path = "hiera.yaml"
  end

  #config.vm.provision "shell", path: "prepare.sh"

end
  # End controller
 
  # Begin compute
config.vm.define "compute" do |compute|
  compute.vm.box = "controller"
  compute.vm.hostname = "compute"
  compute.vm.box_url = "https://build.opnfv.org/downloads/controller.box"
 
    compute.vm.provider "virtualbox" do |v|

      v.customize ["modifyvm", :id, "--cpus", 1]
      v.customize ["modifyvm", :id, "--memory", 2096]
      
    end

        if nat_mode.nil? or nat_mode == 0
          compute.vm.network "public_network", :bridge => bridge, ip: compute_bridged_ip, :auto_config => "true", :netmask => netmask
          compute.vm.network "private_network", ip: compute_private_ip
          compute.vm.provision :shell, :path => "./bin/prepare.sh", :args => gateway
        else 
          compute.vm.network "private_network", ip: compute_private_ip, :netmask => "255.255.252.0"
          compute.vm.provision "shell", path: "./bin/prepare.sh", :args => gateway
        end

  #Example skeleton for using the puppet provider
  compute.vm.provision "puppet" do |puppet|
      puppet.options = "--verbose"
      #Example for facter facts
      puppet.facter = {
        "vagrant" => "1"
      }
      #Exaple for Hiera config
      puppet.hiera_config_path = "hiera.yaml"
  end


end
 
end
