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
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: install

conf:
  file.recurse:
    - name: {{ salt['pillar.get']('cuckoo:cwd') }}/conf
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
    - name: cuckoo community
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
    - require:
      - cmd: install
      - user: cuckoo_user
      - group: cuckoo_user

api_uwsgi:
  cmd.run:
    - name: >
        cuckoo
        --user {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
        api --uwsgi
        > /etc/uwsgi/apps-available/cuckoo-api.ini && true
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
  file.symlink:
    - name: /etc/uwsgi/apps-enabled/cuckoo-api.ini
    - target: /etc/uwsgi/apps-available/cuckoo-api.ini

api_nginx:
  cmd.run:
    - name: >
        cuckoo
        --user {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
        api --nginx
        --host {{ salt['pillar.get']('api:host', 'localhost') }}
        --port {{ salt['pillar.get']('api:port', '8090') }}
        > /etc/nginx/sites-available/cuckoo-api && true
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
  file.symlink:
    - name: /etc/nginx/sites-enabled/cuckoo-api
    - target: /etc/nginx/sites-available/cuckoo-api

limits.conf:
  file.append:
    - name: /etc/security/limits.conf
    - source: salt://cuckoo/files/limits.conf

uwsgi:
  service.running:
    - enable: True
    - watch:
      - file: api_uwsgi

nginx:
  service.running:
    - enable: True
    - watch:
      - file: api_nginx
