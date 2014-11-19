PackStackSandBox
================

Nothing about this is good yet. You have been warned.

Currently have it running in 6GB of memory. 

Requirements
============
Get VirtualBox https://www.virtualbox.org/wiki/Downloads
Get Vagrant https://www.vagrantup.com/downloads.html
Install vagrant-vbguest

    vagrant plugin install vagrant-vbguest

Enable bridged mode on your local machine

    $ brctl show
    bridge name     bridge id               STP enabled     interfaces
    docker0         8000.28d244719f30       no              enp0s25

Get this repo

    git clone git@github.com:Aricg/PackStackSandBox.git && cd PackStackSandBox

Modify Vagrantfile.yml 

    controller:
      bridged_ip: 192.168.1.91
      private_ip: 192.168.22.92
    compute:
      bridged_ip: 192.168.1.93
      private_ip: 192.168.22.94

Launch Vagrant
    
      vagrant up

ssh into the vagrant controller (password is vagrant)

  eval $(./parse_yaml Vagrantfile.yml) && ssh root@$controller_bridged_ip

run packstack
  cd /vagrant && ./RunPackstack




Please refer to the REAME file. I'll mark it up as I make changes

