package:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/{{ salt['pillar.get']('cuckoo:version') }}
    - source: salt://{{ slspath }}/files/{{ salt['pillar.get']('cuckoo:version') }}

install:
  cmd.run:
    - name: pip install -U {{ salt['pillar.get']('vmcloak:workingdir') }}/{{ salt['pillar.get']('cuckoo:version') }}
    - require:
      - file: package

{{ salt['pillar.get']('cuckoo:cwd') }}:
  file.directory:
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}

init:
  cmd.run:
    - name: cuckoo --cwd {{ salt['pillar.get']('cuckoo:cwd') }} init
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: install
      - file: {{ salt['pillar.get']('cuckoo:cwd') }}

/etc/supervisor/supervisord.conf:
  file.symlink:
    - target: {{ salt['pillar.get']('cuckoo:cwd') }}/supervisord.conf
    - force: True

conf:
  file.recurse:
    - name: {{ salt['pillar.get']('cuckoo:cwd') }}/conf
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - file_mode: 644
    - dir_mode: 750
    - template: jinja
    - source: salt://{{ slspath }}/files/conf

conf_supervisor:
  file.managed:
    - name: {{ salt['pillar.get']('cuckoo:cwd') }}/supervisord.conf
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - file_mode: 644
    - dir_mode: 750
    - source: salt://{{ slspath }}/files/supervisord.conf
    - template: jinja
    - require:
      - file: conf

cuckoo-rooter:
  file.managed:
    - name: /etc/systemd/system/cuckoo-rooter.service
    - file_mode: 644
    - template: jinja
    - source: salt://{{ slspath }}/files/cuckoo-rooter.service
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      -file: cuckoo-rooter