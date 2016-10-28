include:
  - cuckoo.deps

genisoimage:
  pkg.installed

vmcloak_install:
  cmd.run:
    - name: pip install -U vmcloak
    - require:
      - cmd: pip

vmcloak_workingdir:
  file.directory:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode
    - makedirs: True
    - require:
      - user: cuckoo_user

office2007.iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/office2007.iso
    - source: salt://cuckoo/files/office2007.iso
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - require:
      - file: vmcloak_workingdir

office2010.iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/office2010.iso
    - source: salt://cuckoo/files/office2010.iso
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - require:
      - file: vmcloak_workingdir

archive_zip:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/archive.zip
    - source: salt://cuckoo/files/archive.zip
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - require:
      - file: vmcloak_workingdir

wallpaper_jpg:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/wallpaper.jpg
    - source: salt://cuckoo/files/wallpaper.jpg
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - require:
      - file: vmcloak_workingdir

{% if salt['pillar.get']('vms:winxp:create') %}
winxp_iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/winxp.iso
    - source: salt://cuckoo/files/winxp.iso
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - require:
      - file: vmcloak_workingdir

winxp_mount:
  mount.mounted:
    - name: {{ salt['pillar.get']('vmcloak:isomountdir') }}/winxp
    - device: {{ salt['pillar.get']('vmcloak:workingdir') }}/winxp.iso
    - fstype: iso9660
    - mkmnt: True
    - persist: False
    - opts: loop,ro
    - require:
      - file: winxp_iso
{% endif %}

{% if salt['pillar.get']('vms:win7x64:create') %}
win7x64_iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/win7x64.iso
    - source: salt://cuckoo/files/win7x64.iso
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - require:
      - file: vmcloak_workingdir

win7x64_mount:
  mount.mounted:
    - name: {{ salt['pillar.get']('vmcloak:isomountdir') }}/win7x64
    - device: {{ salt['pillar.get']('vmcloak:workingdir') }}/win7x64.iso
    - fstype: iso9660
    - mkmnt: True
    - persist: False
    - opts: loop,ro
    - require:
      - file: win7x64_iso
{% endif %}

vmcloak_cleanup:
  file.absent:
    - name: {{ salt['pillar.get']('cuckoo:dir', '/srv/cuckoo') }}/.vmcloak

vmcloak_iptables:
  cmd.run:
    - name: vmcloak-iptables {{ salt['pillar.get']('vmcloak:ipprefix') }}0/24 {{ salt['pillar.get']('vmcloak:interface') }}
    - runas: root
    - shell: /bin/bash
    - require:
      - cmd: vmcloak_install
