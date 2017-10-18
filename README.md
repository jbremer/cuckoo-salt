# cuckoo-salt

SaltStack formula for deploying Cuckoo Sandbox.

## Configuration

- vmcloak needs an Office key to be set in pillar.
- Pillar value for hosts network interface needs to be set in pillar to the correct value.

## Setup

* Setup a Salt master and one or more Salt minions as per [documentation](https://docs.saltstack.com/en/latest/topics/installation/index.html).
* Create the `/srv/salt` and `/srv/pillar` directories. (Don't forget to add them to file_roots and pillar_roots in `/etc/salt/master` config file)
* Create `/srv/pillar/top.sls` as per [documentation](https://docs.saltstack.com/en/latest/topics/pillar/).
* Create a symlink from `/srv/salt/pillar.example` to `/srv/pillar/cuckoo.sls`.
* Add `cuckoo` to pillar top file.
* Fill out the `cuckoo.sls` pillar as desired.
* Run `salt 'minion_id' saltutil.refresh_pillar` to reload modified pillar on minions.
* Run either `salt 'minion_id' state.highstate` or `salt 'minion_id' state.apply cuckoo`.

## Usage

The cuckoo-salt SaltStack formula features various commands for operating one
or more Cuckoo machines.

Common methods:
* `cuckoo.init`: fully setup Cuckoo & its dependencies.
* `cuckoo.vms`: setup VMs using VMCloak as per your configuration.
* `cuckoo.start`: start Cuckoo.
* `cuckoo.stop`: stop Cuckoo.

Maintenance methods:
* `cuckoo.community`: fetch the latest Community release.
* `cuckoo.install`: install Cuckoo.
* `cuckoo.uninstall`: uninstall Cuckoo.
* `cuckoo.update`: stop, uninstall, install, and start Cuckoo.
* `cuckoo.clean`: remove all analyses, submitted binaries, and database entries.
* `cuckoo.removevms`: remove all VMs
* `cuckoo.web`: enable the Cuckoo Web Interface (requires reporting:mongodb:enabled to be true)

## TODO

- Testing has been done on Ubuntu 16.04 LTS, but needs a lot more.
- Turn into a proper salt formula
- Add a mongo deploy state?
- Add an ELK cluster deploy state?
- Add user www-data to cuckoo & other way around.

## Reverse port tunneling & temporary Salt Master

In case one doesn't want to expose the SaltStack master to the internet the
entire time it is possible to use reverse tunneling in your setup. In such a
setup we'll assume three different types of machines: master, proxy, minion.

On the master machine:
* Setup salt-master and disable the service.

On the minion machine:
* Setup salt-minion and point it to your proxy.

On the proxy machine:
* Enable GatewayPorts for your user, https://askubuntu.com/questions/50064/reverse-port-tunnelling.

Now each time you'll want to push commands from the Master to a Minion, it is
required to go through the following steps:
* On the master, `ssh -R 4505:localhost:4505 -R 4506:localhost:4506 proxy`.
* On the master, run `salt-master -l debug` as a foreground process.
