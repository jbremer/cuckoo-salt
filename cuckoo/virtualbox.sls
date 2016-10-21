virtualbox:
  pkgrepo.managed:
    - name: deb http://download.virtualbox.org/virtualbox/debian {{ grains['lsb_distrib_codename'] }} contrib non-free
    - comps: contrib
    - dist: {{ grains['lsb_distrib_codename'] }}
    - file: /etc/apt/sources.list.d/oracle-virtualbox.list
    - key_url: https://www.virtualbox.org/download/oracle_vbox_2016.asc
    - require_in:
      - pkg: virtualbox
  pkg.installed:
    - name: virtualbox-{{ salt['pillar.get']('virtualbox:version') }}

cuckoo_vboxusers:
  user.present:
    - name: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - groups:
      - vboxusers
    - require:
      - pkg: virtualbox

/etc/rc.local:
  file.managed:
    - source: salt://cuckoo/files/rc.local
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - pkg: virtualbox

vboxnet_clear:
  cmd.run:
    - name: vboxmanage list -l hostonlyifs | grep -oP "(?<=\s)vboxnet\d+$" | xargs -I {} vboxmanage hostonlyif remove {}
    - user: cuckoo
    - require:
      - user: cuckoo_vboxusers

vboxnet_create:
  cmd.run:
    - name: VBoxManage hostonlyif create
    - user: cuckoo
    - require:
      - user: cuckoo_vboxusers
      - cmd: vboxnet_clear

vboxnet_set:
  cmd.run:
    - name: VBoxManage setextradata global "HostOnly/vboxnet0/IPAddress" 192.168.168.1
    - user: cuckoo
    - require:
      - user: cuckoo_vboxusers
      - cmd: vboxnet_create

vboxnet_up:
  cmd.run:
    - name: /etc/rc.local
    - user: root
    - require:
      - file: /etc/rc.local
      - cmd: vboxnet_set
