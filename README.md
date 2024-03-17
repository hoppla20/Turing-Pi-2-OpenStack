# OpenStack on Turing Pi 2 with RK1

## Building Images

- I've tried the provided `-aarch64` debian images but they had problems everywhere
- Setup registry somewhere (in my case `thor.fritz.box:4000`)
- Build own images using `kolla-build -b ubuntu --registry thor.fritz.box:4000 --push`
- Customize `docker_registry*` and `openstack_tag` options in [./ansible/files/kolla-globals.yml](./ansible/files/kolla-globals.yml)

## Disk setup

```
NAME           SIZE TYPE MOUNTPOINT          LABEL
mmcblk0       29.1G disk                     
├─mmcblk0p1    512M part /boot/firmware      system-boot
└─mmcblk0p2   28.6G part /                   writable
mmcblk0boot0     4M disk                 
mmcblk0boot1     4M disk                 
nvme0n1      232.9G disk                 
├─nvme0n1p1    115G part /var/lib/containers containers
└─nvme0n1p2  117.9G part                                    # lvm 'cinder-volumes'
```

## Preparations

```sh
cd ansible
ansible-playbook -i inventory.yaml preparations.playbook.yaml
```

Then you need to add the ssh host keys to the known_hosts of your deploy node (you don't need to login).
In my case:

```sh
ssh ubuntu@tp-rk-0.fritz.box
$ ssh tp-rk-0.fritz.box
yes
$ ssh tp-rk-1.fritz.box
yes
```

You can also disable HostKeyCheking in `/etc/ansible/ansible.cfg`.

## Deploy

```sh
cd ansible
ansible-playbook -i inventory.yaml deploy.playbook.yaml
```

To follow the deployment execute the following command on the deploy node:

```sh
tail -f /var/log/kolla-deploy/install-deps*
tail -f /var/log/kolla-deploy/bootstrap-servers*
tail -f /var/log/kolla-deploy/octavia-certificates*
tail -f /var/log/kolla-deploy/prechecks*
tail -f /var/log/kolla-deploy/deploy*
```

Note: `tail -f /var/log/kolla-deploy/*` somehow does not tail all files

## Post deploy

SSH onto the deploy node

```sh
cd /srv/kolla && . venv/bin/activate
kolla-ansible post-deploy && . /etc/kolla/admin-openrc.sh
pip install -c https://releases.openstack.org/constraints/upper/2023.2 \
    python-openstackclient \
    python-designateclient \
    python-octaviaclient
cp venv/share/kolla-ansible/init-runonce ./
# edit init-runonce
bash init-runonce
```
