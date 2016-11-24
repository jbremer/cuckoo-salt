web_uwsgi:
  cmd.run:
    - name: >
        cuckoo
        --user {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
        web --uwsgi
        > /etc/uwsgi/apps-available/cuckoo-web.ini && true
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
  file.symlink:
    - name: /etc/uwsgi/apps-enabled/cuckoo-web.ini
    - target: /etc/uwsgi/apps-available/cuckoo-web.ini

web_nginx:
  cmd.run:
    - name: >
        cuckoo
        --user {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
        web --nginx
        --host {{ salt['pillar.get']('api:host', 'localhost') }}
        --port {{ salt['pillar.get']('api:port', '8000') }}
        > /etc/nginx/sites-available/cuckoo-web && true
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
  file.symlink:
    - name: /etc/nginx/sites-enabled/cuckoo-web
    - target: /etc/nginx/sites-available/cuckoo-web

uwsgi:
  service.running:
    - enable: True
    - watch:
      - file: web_uwsgi

nginx:
  service.running:
    - enable: True
    - watch:
      - file: web_nginx
