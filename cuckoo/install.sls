package:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/{{ salt['pillar.get']('cuckoo:version') }}
    - source: salt://cuckoo/files/{{ salt['pillar.get']('cuckoo:version') }}

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

conf:
  file.recurse:
    - name: {{ salt['pillar.get']('cuckoo:cwd') }}/conf
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - file_mode: 644
    - dir_mode: 750
    - template: jinja
    - source: salt://cuckoo/files/conf
