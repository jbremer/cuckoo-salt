include:
  - cuckoo.deps

genisoimage:
  pkg.installed

vmcloak_git:
  git.latest:
    - name: https://github.com/jbremer/vmcloak
    - target: /srv/vmcloak
    - force_clone: True
    - force_fetch: True
    - force_checkout: True
    - force_reset: True
    - require:
      - pkg: cuckoo_dependencies

vmcloak_install:
  cmd.run:
    - name: cd /srv/vmcloak && pip install -r requirements.txt --upgrade && python setup.py build && python setup.py install && vmcloak-iptables 192.168.168.0/24 eno1
    - cwd: /srv/vmcloak
    - shell: /bin/bash
    - require:
      - git: vmcloak_git
      - pkg: genisoimage

/srv/iso:
  file.directory:
    - user: cuckoo
    - group: cuckoo
    - mode: 755
    - makedirs: True
    - require:
      - user: cuckoo
      - group: cuckoo

/srv/iso/Win_7SP1_x64.ISO:
  file.managed:
      - source: salt://cuckoo/files/Win_7SP1_x64.ISO
      - user: cuckoo
      - group: cuckoo
      - mode: 644
      - require:
        - file: /srv/iso

/srv/iso/Office_2010SP1_x64.ISO:
  file.managed:
    - source: salt://cuckoo/files/Office_2010SP1_x64.ISO
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: /srv/iso

/srv/iso/Archive.zip:
  file.managed:
    - source: salt://cuckoo/files/Archive.zip
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: /srv/iso

/srv/iso/dogezilla.jpg:
  file.managed:
    - source: salt://cuckoo/files/dogezilla.jpg
    - user: cuckoo
    - group: cuckoo
    - mode: 644
    - require:
      - file: /srv/iso

/srv/iso/win7:
  mount.mounted:
    - device: /srv/iso/Win_7SP1_x64.ISO
    - fstype: udf
    - mkmnt: True
    - persist: False
    - opts: loop
    - require:
      - file: /srv/iso/Win_7SP1_x64.ISO

vmcloak_cleanup:
  file.absent:
    - name: /srv/cuckoo/.vmcloak

vmcloak:
  cmd.script:
    - source: salt://cuckoo/files/vmcloak_generate.sh
    - cwd: /srv/vmcloak
    - user: cuckoo
    - group: cuckoo
    - shell: /bin/bash
    - template: jinja
    - require:
      - cmd: vmcloak_install
      - mount: /srv/iso/win7
      - file: vmcloak_cleanup
