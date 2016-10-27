include:
  - cuckoo.deps
  - cuckoo.volatility
  - cuckoo.vmcloak
  - cuckoo.suricata

package:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/{{ salt['pillar.get']('cuckoo:version') }}
    - source: salt://cuckoo/files/{{ salt['pillar.get']('cuckoo:version') }}

install:
  cmd.run:
    - name: pip install -U {{ salt['pillar.get']('vmcloak:workingdir') }}/{{ salt['pillar.get']('cuckoo:version') }}
    - require:
      - sls: cuckoo.deps
      - sls: cuckoo.volatility
      - file: package

init:
  cmd.run:
    - name: cuckoo --cwd {{ salt['pillar.get']('cuckoo:cwd') }} init
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: install

conf:
  file.recurse:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/conf
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - file_mode: 644
    - dir_mode: 750
    - template: jinja
    - source: salt://cuckoo/files/conf
    - require:
      - cmd: init
      - user: cuckoo_user
      - group: cuckoo_user

community:
  cmd.run:
    - name: cuckoo --cwd {{ salt['pillar.get']('cuckoo:cwd') }} community
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: install
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

limits.conf:
  file.append:
    - name: /etc/security/limits.conf
    - source: salt://cuckoo/files/limits.conf
