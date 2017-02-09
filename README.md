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

## TODO

- Testing has been done on Ubuntu 16.04 LTS, but needs a lot more.
- Turn into a proper salt formula
- Add a mongo deploy state?
- Add an ELK cluster deploy state?
