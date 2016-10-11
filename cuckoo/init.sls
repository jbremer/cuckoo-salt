include:
  - cuckoo.deps
  - cuckoo.volatility
  - cuckoo.vmcloak
  - cuckoo.suricata

cuckoo_razuz_git:
  git.latest:
    - name: https://github.com/razuz/cuckoo.git
    - target: /srv/cuckoo
    - force_clone: True
    - force_reset: True
    - require:
      - sls: cuckoo.deps
      - sls: cuckoo.volatility

cuckoo_req_install:
    pip.installed:
      - requirements: /srv/cuckoo/requirements.txt
      - upgrade: True
      - require:
        - git: cuckoo_razuz_git
        - pip: pip

/srv/cuckoo:
  file.directory:
    - user: cuckoo
    - group: cuckoo
    - mode: 755
    - recurse:
      - user
      - group
    - require:
      - git: cuckoo_razuz_git
      - user: cuckoo
      - group: cuckoo

/srv/cuckoo/conf:
  file.recurse:
    - user: cuckoo
    - group: cuckoo
    - file_mode: 644
    - dir_mode: 750
    - template: jinja
    - source: salt://cuckoo/files/conf
    - require:
      - git: cuckoo_razuz_git

/srv/cuckoo/conf/virtualbox.conf:
  file.managed:
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - source: salt://test/virtualbox.conf
    - template: jinja
    - makedirs: True
    - require:
      - git: cuckoo_razuz_git
      - file: /srv/cuckoo/conf

cuckoo_waf:
  cmd.run:
    - name: cd /srv/cuckoo && ./utils/community.py -waf
    - user: cuckoo
    - cwd: /srv/cuckoo
    - require:
      - git: cuckoo_razuz_git

/etc/init.d/cuckoo.sh:
  file.managed:
    - source: salt://cuckoo/files/cuckoo.sh
    - user: root
    - group: root
    - mode: 755
    - require:
        - git: cuckoo_razuz_git

'/srv/cuckoo/screenconf/process.conf':
  file.managed:
    - source: salt://cuckoo/files/process.conf
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - makedirs: True

'/srv/cuckoo/screenconf/api.conf':
  file.managed:
    - source: salt://cuckoo/files/api.conf
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - makedirs: True

'/etc/security/limits.conf':
  file.append:
    - source: salt://cuckoo/files/limits.conf

cuckoo_start:
  cmd.run:
    - name: /etc/init.d/cuckoo.sh restart
    - shell: /bin/bash
    - require:
      - file: /etc/init.d/cuckoo.sh
      - pip: cuckoo_req_install
      - sls: cuckoo.vmcloak

# We do have an initial systemd unit file, but it's untested/ugly and relies on the old init.d scripts for ExecStart/ExecStop
# Thusly it's currently commented out
#'cuckoo.sh':
  #  service.running:
    #- enable: True
    #- watch:
      #- file: /srv/cuckoo/conf
    #- require:
      #- file: /etc/init.d/cuckoo.sh
