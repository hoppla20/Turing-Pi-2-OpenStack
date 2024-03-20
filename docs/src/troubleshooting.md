# Troubleshooting

## Rockchip Ubuntu 22.04 - BSD Kernel 5.10

### Networking

Tested neutron configurations that do not work out of the box:

TODO add logs for failing neutron networking configurations

- ml2/openvswitch with default (iptables) firewall driver
- ml2/ovn

The only ml2 networking configuration that worked for me is ml2/openvswitch with the
[native OVS firewall driver](https://docs.openstack.org/kolla-ansible/latest/reference/networking/neutron.html#openvswitch-ml2-ovs).
These Problems could also be caused by the usage of a veth interface for external network connectivity.
