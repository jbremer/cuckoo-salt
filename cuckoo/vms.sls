include:
  - cuckoo.deps
  - cuckoo.vmcloak

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

{% if salt['pillar.get']('office:2007') != 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' %}
office2007.iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/office2007.iso
    - source: {{ salt['pillar.get']('vmcloak:iso:office2007') }}
    - skip_verify: True
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - replace: False
    - require:
      - file: vmcloak_workingdir
{% endif %}

{% if salt['pillar.get']('office:2010') != 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' %}
office2010.iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/office2010.iso
    - source: {{ salt['pillar.get']('vmcloak:iso:office2010') }}
    - skip_verify: True
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - replace: False
    - require:
      - file: vmcloak_workingdir
{% endif %}

{% if salt['pillar.get']('vms:winxp:create') %}
winxp_iso:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/winxp.iso
    - source: {{ salt['pillar.get']('vmcloak:iso:winXPiso') }}
    - skip_verify: True
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
    - source: {{ salt['pillar.get']('vmcloak:iso:win7x64iso') }}
    - skip_verify: True
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - replace: False
    - require:
      - file: vmcloak_workingdir

win7x64_mount:
  mount.mounted:
    - name: {{ salt['pillar.get']('vmcloak:isomountdir') }}/win7x64
    - device: {{ salt['pillar.get']('vmcloak:workingdir') }}/win7x64.iso
    - fstype: udf
    - mkmnt: True
    - persist: False
    - opts: loop,ro
    - require:
      - file: win7x64_iso
{% endif %}

vboxnet0_remove:
  cmd.run:
    - name: >
        vboxmanage list -l hostonlyifs | grep -oP "(?<=\s)vboxnet\d+$" |
        xargs -I {} vboxmanage hostonlyif remove {} && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - user: cuckoo_user
      - pkg: virtualbox

vboxnet0_create:
  cmd.run:
    - name: VBoxManage hostonlyif create
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: vboxnet0_remove

vboxnet0_setextra:
  cmd.run:
    - name: >
        VBoxManage setextradata global "HostOnly/vboxnet0/IPAddress"
        {{ salt['pillar.get']('vmcloak:ipprefix') }}1 && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: vboxnet0_create

vboxnet0_ipconfig:
  cmd.run:
    - name: >
        VBoxManage hostonlyif ipconfig vboxnet0
        --ip {{ salt['pillar.get']('vmcloak:ipprefix') }}1
        --netmask 255.255.255.0 && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: vboxnet0_setextra

{% if salt['pillar.get']('vms:winxp:create') %}
winxp_master_init:
  cmd.run:
    - name: >
        vmcloak init --winxp winxp_master
        --iso-mount {{ salt['pillar.get']('vmcloak:isomountdir') }}/winxp
        --serial-key {{ salt['pillar.get']('vms:winxp:serialkey') }}
        --ip {{ salt['pillar.get']('vmcloak:ipprefix') }}2
        --gateway {{ salt['pillar.get']('vmcloak:ipprefix') }}1
        --dns {{ salt['pillar.get']('vmcloak:dns') }}
        --ramsize {{ salt['pillar.get']('vms:winxp:ramsize') }}
        --vramsize {{ salt['pillar.get']('vms:winxp:vramsize') }}
        && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: vboxnet0_ipconfig
      - mount: winxp_mount

winxp_master_install:
  cmd.run:
    - name: >
        vmcloak install winxp_master
        adobepdf:9.0.0 wic pillow dotnet:4.0 wallpaper
        && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: winxp_master_init

winxp_snapshots:
  cmd.run:
    - name: >
        vmcloak snapshot winxp_master
        --count {{ salt['pillar.get']('vms:winxp:count') }}
        {{ salt['pillar.get']('vms:winxp:basename') }}
        {{ salt['pillar.get']('vmcloak:ipprefix') }}{{ salt['pillar.get']('vms:winxp:ipstart') + 1 }}
        && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: winxp_master_install
{% endif %}

{% if salt['pillar.get']('vms:win7x64:create') %}
win7x64_master_init:
  cmd.run:
    - name: >
        vmcloak init --win7x64 win7x64_master
        --iso-mount {{ salt['pillar.get']('vmcloak:isomountdir') }}/win7x64
        --ip {{ salt['pillar.get']('vmcloak:ipprefix') }}2
        --gateway {{ salt['pillar.get']('vmcloak:ipprefix') }}1
        --dns {{ salt['pillar.get']('vmcloak:dns') }}
        --cpus {{ salt['pillar.get']('vms:win7x64:cpus') }}
        --ramsize {{ salt['pillar.get']('vms:win7x64:ramsize') }}
        --vramsize {{ salt['pillar.get']('vms:win7x64:vramsize') }}
        && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: vboxnet0_ipconfig
      - mount: win7x64_mount

win7x64_master_install:
  cmd.run:
    - name: >
        vmcloak install win7x64_master
        adobepdf:9.0.0 wic pillow dotnet:4.6.1 java:7u71 flash:15.0.0.167
        winrar cuteftp wallpaper
        && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: win7x64_master_init

{% if salt['pillar.get']('office:2007') != 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' %}
win7x64_office2007:
  cmd.run:
    - name: >
        vmcloak install win7x64_master
        office
        office.isopath={{ salt['pillar.get']('vmcloak:workingdir') }}/office2007.iso
        office.serialkey={{ salt['pillar.get']('office:2007') }}
        office.activate=1
        && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: win7x64_master_install
      - file: office2007.iso
{% endif %}

{% if salt['pillar.get']('office:2010') != 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' %}
win7x64_office2010:
  cmd.run:
    - name: >
        vmcloak install win7x64_master
        office
        office.isopath={{ salt['pillar.get']('vmcloak:workingdir') }}/office2010.iso
        office.serialkey={{ salt['pillar.get']('office:2010') }}
        office.activate=1
        && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: win7x64_master_install
      - file: office2010.iso
{% endif %}

win7x64_snapshots:
  cmd.run:
    - name: >
        vmcloak snapshot win7x64_master
        --count {{ salt['pillar.get']('vms:win7x64:count') }}
        {{ salt['pillar.get']('vms:win7x64:basename') }}
        {{ salt['pillar.get']('vmcloak:ipprefix') }}{{ salt['pillar.get']('vms:win7x64:ipstart') + 1 }}
        && true
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - require:
      - cmd: win7x64_master_install
{% endif %}
