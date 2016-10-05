include:
  - cuckoo.virtualbox

cuckoo_dependencies:
  pkg.installed:
    - refresh: True
    - pkgs:
      - git
      - python-pip 
      - libffi-dev
      - libssl-dev
      - python-dev
      - unzip
      - libxml2-dev
      - libxslt-dev
      - libjpeg-dev
      - libpq-dev
      - automake
      - libtool
      - libjansson-dev
      - libmagic-dev
      - mongodb
      - postgresql
      - tcpdump

# TLDR; execute "salt 'machine name' state.apply cuckoo.deps" it will fail, then do "salt 'machine name' service.restart salt-minion" and now if you run the previous state all should be good.
# Happens probably only on Ubuntu 16.04, fill be fixed when the mentioned issues get fixed...either in salt or in pip.
# kinda broken, see https://github.com/saltstack/salt/issues/33163 and https://github.com/saltstack/salt/issues/24925
# basically pip upgrade fixes an Ubuntu 16.04 issue with salt running requirements.txt by updating from the ubuntu version to the upstream version
# At the same time this upgrade confuses salt, so the first state execution fails, but after a minion restart it succeeds. reload_modules: true should help but it doesn't.
upgrade_pip:
  cmd.run:
    - name: pip install --upgrade pip
    - reload_modules: true
    - require:
      - pkg: cuckoo_dependencies

cuckoo_setcap:
  cmd.run:
    - name: setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
    - require:
      - pkg: cuckoo_dependencies

psycopg2:
  pip.installed:
    - require:
      - cmd: upgrade_pip

'yara-python':
  pip.installed:
    - require:
      - cmd: upgrade_pip

distorm3:
  pip.installed:
    - require:
      - cmd: upgrade_pip

mongodb:
  service.running:
    - enable: True

postgresql:
  service.running:
    - enable: True

cuckoodb:
  postgres_database.present:
    - name: {{ salt['pillar.get']('db:name', 'cuckoo') }}
    - require:
      - service: postgresql

cuckoodb_user:
  postgres_user.present:
    - name: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - password: {{ salt['pillar.get']('db:password', 'cuckoo') }}
    - require:
      - service: postgresql

cuckoodb_priv:
  postgres_privileges.present:
    - name: {{ salt['pillar.get']('db:name', 'cuckoo') }}
    - object_name: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - object_type: database
    - privileges:
      - ALL
    - require:
      - postgres_database: cuckoodb
      - postgres_user: cuckoodb_user

{{ salt['pillar.get']('db:user'), 'cuckoo'}}:
  group:
    - present
    - require:
      - sls: cuckoo.virtualbox
  user.present:
    - fullname: cuckoo
    - gid_from_name: True
    - shell: /bin/bash
    - home: /srv/cuckoo
    - groups:
      - vboxusers
    - require:
      - sls: cuckoo.virtualbox