include:
  - cuckoo.vmcloak

vbox_removevms:
  cmd.run:
    - name: 'echo y|vmcloak-removevms'
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}

vmcloak_cleanup:
  file.absent:
    - name: {{ salt['pillar.get']('cuckoo:home', '/home/cuckoo') }}/.vmcloak
