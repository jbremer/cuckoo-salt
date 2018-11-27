include:
  - cuckoo.mongo

cuckoo_dependencies:
  pkg.installed:
    - refresh: True
    - pkgs:
      - git
      - python-setuptools
      - libffi-dev
      - libssl-dev
      - python-dev
      - unzip
      - libxml2-dev
      - libxslt1-dev
      - libjpeg-dev
      - libpq-dev
      - automake
      - libtool
      - libjansson-dev
      - libmagic-dev
      - postgresql
      - tcpdump
      - supervisor
      - uwsgi
      - uwsgi-plugin-python
      - nginx
      - p7zip-full
      - rar
      - unace-nonfree
      - cabextract

virtualbox:
  pkgrepo.managed:
    - name: deb http://download.virtualbox.org/virtualbox/debian {{ grains['lsb_distrib_codename'] }} contrib non-free
    - comps: contrib
    - dist: {{ grains['lsb_distrib_codename'] }}
    - file: /etc/apt/sources.list.d/oracle-virtualbox.list
    - key_url: https://www.virtualbox.org/download/oracle_vbox_2016.asc
    - require_in:
      - pkg: virtualbox
  pkg.installed:
    - name: virtualbox-{{ salt['pillar.get']('virtualbox:version') }}

{%- if salt['grains.get']('oscodename') == 'bionic' %}
cuckoo_bionic_pip:
  pkg.latest:
    - name: python-pip
    - require_in:
      - cmd: cuckoo_pip
    - require:
      - pkg: cuckoo_dependencies

{%- else %}
pip_uninstalled:
  pkg.removed:
    - name: python-pip
    - require:
      - pkg: cuckoo_dependencies

pip:
  cmd.run:
    - name: easy_install pip
    - require:
      - pkg: pip_uninstalled
    - require_in:
      - cmd: cuckoo_pip
{% endif %}

cuckoo_pip:
  cmd.run:
    - name: pip install -U psycopg2 yara-python==3.6.3 distorm3 setuptools pyopenssl

# Cuckoo-specific setup instructions, refer to the documentation.

# Patches for Ubuntu 16.04
{% if salt['grains.get']('oscodename') == 'xenial' %}
apparmor-utils:
  pkg.installed:
    - require:
      - pkg: cuckoo_dependencies

disable_aa_tcpdump:
  cmd.run:
    - name: aa-disable /usr/sbin/tcpdump
    - runas: root
    - onlyif: '/usr/sbin/aa-status | /bin/grep "/usr/sbin/tcpdump"'
    - require:
      - pkg: apparmor-utils

tcpdump_perms:
  file.managed:
    - name: /usr/sbin/tcpdump
    - user: root
    - group: cuckoo
    - mode: 750
    - create: False
    - replace: False
    - require:
      - pkg: cuckoo_dependencies
      - group: cuckoo_user

tcpdump_path:
  cmd.run:
    - name: >
        export PATH=$PATH:/usr/sbin
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - user: cuckoo_user

tcpdump_path_profile:
  file.replace:
    - name: /home/cuckoo/.profile
    - pattern: "/.local/bin:"
    - repl: "/.local/bin:/usr/sbin:"
    - require:
      - user: cuckoo_user

supervisor:
  service.running:
    - enable: True
    - require:
      - pkg: cuckoo_dependencies
{% endif %}

cuckoo_setcap:
  cmd.run:
    - name: setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
    - require:
      - pkg: cuckoo_dependencies

postgresql:
  service.running:
    - enable: True

db:
  postgres_database.present:
    - name: {{ salt['pillar.get']('db:name', 'cuckoo') }}
    - require:
      - service: postgresql

db_user:
  postgres_user.present:
    - name: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - password: {{ salt['pillar.get']('db:password', 'cuckoo') }}
    - require:
      - service: postgresql

db_priv:
  postgres_privileges.present:
    - name: {{ salt['pillar.get']('db:name', 'cuckoo') }}
    - object_name: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - object_type: database
    - privileges:
      - ALL
    - require:
      - postgres_database: db
      - postgres_user: db_user

cuckoo_user:
  group.present:
    - name: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - addusers:
      - www-data
  user.present:
    - name: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - fullname: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - gid_from_name: True
    - groups:
      - vboxusers