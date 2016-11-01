stop:
  cmd.run:
    - name: "supervisorctl stop cuckoo:"
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
