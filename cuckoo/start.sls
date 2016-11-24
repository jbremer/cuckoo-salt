supervisord:
  cmd.run:
    # supervisord throws an error if it's already running
    - name: supervisord || true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}

start:
  cmd.run:
    - name: "supervisorctl start cuckoo:"
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
    - require:
      - cmd: supervisord
