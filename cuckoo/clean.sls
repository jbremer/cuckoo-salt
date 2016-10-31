include:
  - cuckoo.deps

stop_cuckoo:
  cmd.run:
    - supervisorctl stop cuckoo:
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - cwd: {{ salt['pillar.get']('cuckoo:cwd') }}

stop_vbox:
  cmd.run:
    - name: vmcloak-killvbox || true
    - user: cuckoo
    - require:
      - cmd: stop_cuckoo
      - pkg: virtualbox

remove_vms:
  cmd.run:
    - name: echo y|vmcloak-removevms
    - user: cuckoo
    - require:
      - cmd: stop_vbox

remove_vmcloak:
  file.absent:
    - name: /home/{{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}/.vmcloak
    - require:
      - cmd: remove_vms

cuckoo_clean:
  cmd.run:
    - name: cd {{ salt['pillar.get']('cuckoo:dir') }} && ./cuckoo.py --clean
    - user: cuckoo
    - require:
      - cmd: stop_cuckoo
