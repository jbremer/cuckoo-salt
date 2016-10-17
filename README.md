# cuckoo-salt

SaltStack formula for deploying Cuckoo Sandbox.

## Before running

- Known bug with the pip.installed state. See issue #5
- vmcloak_generate.sh needs an Office key
- Set pillar values

## Usage

* Setup a Salt master and one or more Salt minions as per [documentation](https://docs.saltstack.com/en/latest/topics/installation/index.html).
* Create the `/srv/salt` and `/srv/pillar` directories. (Don't forget to add them to file_roots and pillar_roots in `/etc/salt/master` config file)
* Create `/srv/pillar/top.sls` as per [documentation](https://docs.saltstack.com/en/latest/topics/pillar/).
* Create a symlink from `/srv/salt/pillar.example` to `/srv/pillar/cuckoo.sls`.
* Add `cuckoo` to pillar top file.
* Fill out the `cuckoo.sls` pillar as desired.
* Run `salt 'minion_id' saltutil.refresh_pillar` to reload modified pillar on minions.

## TODO

- Testing has been done on Ubuntu 16.04 LTS, but needs a lot more
- Pillarize all the configs/Make configuration as dynamic as possible
- Turn into a proper salt formula
- Think about creating a salt module for vmcloak since it's all python anyways
- Add a mongo deploy state?
- Add an ELK cluster deploy state?
