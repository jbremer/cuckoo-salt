include:
  - cuckoo.stop

stop_vbox:
  cmd.run:
    - name: vmcloak-killvbox || true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}

cuckoo_clean:
  cmd.run:
    - name: cuckoo clean
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}
