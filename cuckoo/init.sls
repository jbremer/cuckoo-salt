include:
  - cuckoo.deps
  - cuckoo.volatility
  - cuckoo.vmcloak
  - cuckoo.suricata

cuckoo_razuz_git:
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

cuckoo_user:
  group.present:
    - name: {{ salt['pillar.get']('db:user', 'cuckoo') }}
  user.present:
    - name: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - fullname: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - gid_from_name: True
    - shell: /bin/bash
    - home: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}
    - require:
      - git: cuckoo_razuz_git

razu_to_cuckoo:
  ssh_auth.present:
    - user: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - names:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZgFpsviyWrw2qJwS2kfyzfgdd5Ia8pV0oiETSAT8bXY69CTxM9OdfUGngOX9r1pI7kVOOtT6W5rLZ9xW4cze0klcnmN0EI6j2u9HT0lA1x5hZWp20F15kbcaCO8w+afjj05cCSPL2md3MgjD0aN5dJeYFnX2/PxYSQ7v2SuY2gwQH76c7kIzOTb7fHLHqUEQvit0eF5YZfu6NARkgsnxVozzIlLTmUA8lUoXndIwL6eqhTIRXZD354V/2f35H6r21P53GZy7rGgwMGjF+yAq3Uf3gvdZJWey82pui0ta1vba6FFhZbEnnuZTGBb06SPkeATSUTJUQ6Xglyls7996ZYlJJ2JBN7HccEvmuCT50fRHEUaUvFCxMu8clXQP8sIemx3x+RjjpbdacDsvJiACgeyub5LpGBoSU4qTAWLWtaL7/J7BedAZ7S19bafVVbW07gSaUiYDHyEgjkhhids+3BZaQ2EypRhC7+2QL+745TpMfn9UXHnXjlMKrC8O3TRHQ+V6Juk7KG36TNH9GddiN/wCGdJvIGLW8YcyyDE9Sz6KB3CfViAJRBtD880F8Ig2c3hMb8NZvZ7BFv/7BhVUauuqZkEygRGvwE7uoNbpW95amfPvvB+L2OS4Fm+TDYFFda1MvHg2B+9SqcmYZCpIsSUQvw0KoKwKvakVNFbpAQQ== razu@pimp
    - require:
      - user: cuckoo_user

cuckoo_req_install:
    pip.installed:
      - requirements: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/requirements.txt
      - upgrade: True
      - reload_modules: True
      - require:
        - git: cuckoo_razuz_git
        - pip: pip

cuckoo_chmod:
  file.directory:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}
    - user: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - mode: 755
    - recurse:
      - user
      - group
    - require:
      - git: cuckoo_razuz_git
      - user: cuckoo_user
      - group: cuckoo_user

cuckoo_conf:
  file.recurse:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/conf
    - user: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - file_mode: 644
    - dir_mode: 750
    - template: jinja
    - source: salt://cuckoo/files/conf
    - require:
      - git: cuckoo_razuz_git


cuckoo_waf:
  cmd.run:
    - name: cd {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }} && ./utils/community.py -waf
    - user: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}
    - require:
      - git: cuckoo_razuz_git

/etc/init.d/cuckoo.sh:
  file.managed:
    - source: salt://cuckoo/files/cuckoo.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
        - git: cuckoo_razuz_git

cuckoo_process.conf:
  file.managed:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/screenconf/process.conf
    - source: salt://cuckoo/files/process.conf
    - user: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - mode: 644
    - template: jinja
    - makedirs: True

cuckoo_api.conf:
  file.managed:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/screenconf/api.conf
    - source: salt://cuckoo/files/api.conf
    - user: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - mode: 644
    - template: jinja
    - makedirs: True

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
