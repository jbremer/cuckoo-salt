stop:
  cmd.run:
    - name: "supervisorctl stop cuckoo:"
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}

kill_tcpdump:
  cmd.run:
    - name: "killall tcpdump"
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
