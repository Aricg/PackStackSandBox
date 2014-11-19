PackStackSandBox
================

A template for further sanbox work with packstack, brings up two nodes. One controller and One Compute/Netowrking. Should be easy to modify to meet your needs. 

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

Modify Vagrantfile.yml to reflect the name of your bridge and the ips you want to give the virtualbox instnaces 

    bridge: docker0
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

I wont include any of the Networking or Launching images in this readme, you can refer to the README.questionable where I have some scripts that bring up and tear down networking  as well as add and launch a minimal VM.
The VM has network connectivity out, but I cant route to it from anywhere. I'm probably doing everything wrong, so feel free to step in and help me out. (pull request welcome :)
