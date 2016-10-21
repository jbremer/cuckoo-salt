include:
  - cuckoo.deps

genisoimage:
  pkg.installed

vmcloak_install:
  pip.installed:
    - name: vmcloak
    - upgrade: True
    - require:
      - pip: pip

vmcloak_workingdir:
  file.directory:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}
    - user: cuckoo
    - group: cuckoo
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode
    - makedirs: True
    - require:
      - user: cuckoo_user

Win_ISO:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/Win_7SP1_x64.ISO
    - source: salt://cuckoo/files/Win_7SP1_x64.ISO
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

Office_ISO:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/Office_2010SP1_x64.ISO
    - source: salt://cuckoo/files/Office_2010SP1_x64.ISO
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

Archive_zip:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/Archive.zip
    - source: salt://cuckoo/files/Archive.zip
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

wallpaper:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/dogezilla.jpg
    - source: salt://cuckoo/files/dogezilla.jpg
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

mount_winiso:
  mount.mounted:
    - name: {{ salt['pillar.get']('vmcloak:isomount') }}
    - device: /srv/iso/Win_7SP1_x64.ISO
    - fstype: udf
    - mkmnt: True
    - persist: False
    - opts: loop
    - require:
      - file: Win_ISO

vmcloak_cleanup:
  file.absent:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/.vmcloak

vmcloak_iptables:
  cmd.run:
    - name: vmcloak-iptables 192.168.168.0/24 {{ salt['pillar.get']('vmcloak:interface') }}
    - runas: root
    - shell: /bin/bash
    - require:
      - pip: vmcloak_install

vmcloak:
  cmd.script:
    - source: salt://cuckoo/files/vmcloak_generate.sh
    - cwd: {{ salt['pillar.get']('vmcloak:workingdir') }}
    - user: cuckoo
    - group: cuckoo
    - shell: /bin/bash
    - template: jinja
    - require:
      - pip: vmcloak_install
      - mount: mount_winiso
      - file: vmcloak_cleanup
      - cmd: vmcloak_iptables
      - cmd: vboxnet_up
