include:
  - cuckoo.deps
  - cuckoo.volatility
  - cuckoo.vmcloak
  - cuckoo.suricata

cuckoo_git:
  git.latest:
    - name: {{ salt['pillar.get']('cuckoo:git', 'https://github.com/cuckoosandbox/cuckoo.git') }}
    - target: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}
    - force_clone: True
    - force_reset: True
    - branch: {{ salt['pillar.get']('cuckoo:git_branch', 'master') }}
    - rev: {{ salt['pillar.get']('cuckoo:git_branch', 'HEAD') }}
    - require:
      - sls: cuckoo.deps
      - sls: cuckoo.volatility

cuckoo_req_install:
    cmd.run:
      - name: pip install -r {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/requirements.txt
      - require:
        - git: cuckoo_git
        - cmd: pip

cuckoo_chmod:
  file.directory:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 755
    - recurse:
      - user
      - group
    - require:
      - git: cuckoo_git
      - user: cuckoo_user
      - group: cuckoo_user

cuckoo_conf:
  file.recurse:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/conf
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - file_mode: 644
    - dir_mode: 750
    - template: jinja
    - source: salt://cuckoo/files/conf
    - require:
      - git: cuckoo_git
      - user: cuckoo_user
      - group: cuckoo_user

cuckoo_waf:
  cmd.run:
    - name: cd {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }} && ./utils/community.py -waf
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}
    - require:
      - git: cuckoo_git
      - user: cuckoo_user
      - group: cuckoo_user

/etc/init.d/cuckoo.sh:
  file.managed:
    - source: salt://cuckoo/files/cuckoo.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - git: cuckoo_git

cuckoo_process.conf:
  file.managed:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/screenconf/process.conf
    - source: salt://cuckoo/files/process.conf
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - template: jinja
    - makedirs: True
    - require:
      - user: cuckoo_user
      - group: cuckoo_user

cuckoo_api.conf:
  file.managed:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/screenconf/api.conf
    - source: salt://cuckoo/files/api.conf
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - template: jinja
    - makedirs: True
    - require:
      - user: cuckoo_user
      - group: cuckoo_user

cuckoo_limits.conf:
  file.append:
    - name: /etc/security/limits.conf
    - source: salt://cuckoo/files/limits.conf

cuckoo_start:
  cmd.run:
    - name: /etc/init.d/cuckoo.sh restart
    - shell: /bin/bash
    - require:
      - file: /etc/init.d/cuckoo.sh
      - cmd: cuckoo_req_install
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
