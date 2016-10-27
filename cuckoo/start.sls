supervisord:
  cmd.run:
    # supervisord throws an error if it's already running
    - name: supervisord || true
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}

start:
  cmd.run:
    - supervisorctl start cuckoo:
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
