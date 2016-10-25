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

winxp_iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/winxp.iso
    - source: salt://cuckoo/files/winxp.iso
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

win7x64_iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/win7x64.iso
    - source: salt://cuckoo/files/win7x64.iso
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

office2007.iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/office2007.iso
    - source: salt://cuckoo/files/office2007.iso
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

office2010.iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/office2010.iso
    - source: salt://cuckoo/files/office2010.iso
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

archive_zip:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/archive.zip
    - source: salt://cuckoo/files/archive.zip
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

wallpaper_jpg:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/wallpaper.jpg
    - source: salt://cuckoo/files/wallpaper.jpg
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: vmcloak_workingdir

winxp_mount:
  mount.mounted:
    - name: {{ salt['pillar.get']('vmcloak:isomountdir') }}/winxp
    - device: {{ salt['pillar.get']('vmcloak:workingdir') }}/winxp.iso
    - fstype: udf
    - mkmnt: True
    - persist: False
    - opts: loop
    - require:
      - file: winxp_iso

win7x64_mount:
  mount.mounted:
    - name: {{ salt['pillar.get']('vmcloak:isomountdir') }}/win7x64
    - device: {{ salt['pillar.get']('vmcloak:workingdir') }}/win7x64.iso
    - fstype: udf
    - mkmnt: True
    - persist: False
    - opts: loop
    - require:
      - file: win7x64_iso

vmcloak_cleanup:
  file.absent:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/.vmcloak

vmcloak_iptables:
  cmd.run:
    - name: vmcloak-iptables {{ salt['pillar.get']('vmcloak:ipprefix') }}0/24 {{ salt['pillar.get']('vmcloak:interface') }}
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
