yum -y install libguestfs-tools
openstack-config --set /etc/nova/nova.conf libvirt virt_type qemu
setsebool -P virt_use_execmem on
ln -s /usr/libexec/qemu-kvm /usr/bin/qemu-system-x86_64
service libvirtd restart
/bin/systemctl restart openstack-nova-compute.service
