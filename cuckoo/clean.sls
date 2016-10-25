include:
  - cuckoo.deps

# Once we put in the Cuckoo package, we'll be able to simply run
# "supervisorctl stop cuckoo".
stop_cuckoo:
  cmd.run:
    - name: exit

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
    - name: /home/{{ salt['pillar.get']('db:name', 'cuckoo') }}/.vmcloak
    - require:
      - cmd: remove_vms

db_drop:
  postgres_database.absent:
    - name: {{ salt['pillar.get']('db:name', 'cuckoo') }}
    - require:
      - service: postgresql

cuckoo_clean:
  cmd.run:
    - name: {{ salt['pillar.get']('cuckoo:dir') }} && ./cuckoo.py --clean
    - user: cuckoo
    - require:
      - cmd: stop_cuckoo
