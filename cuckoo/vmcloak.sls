include:
  - cuckoo.deps

genisoimage:
  pkg.installed

vmcloak_install:
  cmd.run:
    # Do not upgrade dependencies here.
    - name: pip install vmcloak
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

archive_zip:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/archive.zip
    - source: salt://{{ slspath }}/files/archive.zip
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - require:
      - file: vmcloak_workingdir

wallpaper_jpg:
  file.managed:
    - name: {{ salt['pillar.get']('vmcloak:workingdir') }}/wallpaper.jpg
    - source: salt://{{ slspath }}/files/wallpaper.jpg
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 644
    - require:
      - file: vmcloak_workingdir

{% if salt['pillar.get']('vmcloak:interface') %}
vmcloak_iptables:
  cmd.run:
    - name: vmcloak-iptables {{ salt['pillar.get']('vmcloak:ipprefix') }}0/24 {{ salt['pillar.get']('vmcloak:interface') }}
    - runas: root
    - shell: /bin/bash
    - require:
      - cmd: vmcloak_install
{% endif %}
