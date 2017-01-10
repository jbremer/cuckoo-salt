include:
  - cuckoo.deps
  - cuckoo.volatility
  - cuckoo.vmcloak
  - cuckoo.suricata
  - cuckoo.install
  - cuckoo.community

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
