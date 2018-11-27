stop_rooter:
  cmd.run:
    - name: systemctl stop cuckoo-rooter

stop_cuckoo:
  cmd.run:
    - name: "supervisorctl stop cuckoo:"
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}

stop_supervisord:
  cmd.run:
    - name: "supervisorctl shutdown"
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}

kill_related:
  cmd.run:
    - name: "vmcloak-killvbox"
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - ignore_retcode: True

flush_iptables:
  cmd.run:
    - name: iptables -F