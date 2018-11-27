community:
  cmd.run:
    - name: cuckoo --cwd {{ salt['pillar.get']('cuckoo:cwd') }} community
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
