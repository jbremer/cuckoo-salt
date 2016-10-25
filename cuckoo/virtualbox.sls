/etc/rc.local:
  file.managed:
    - source: salt://cuckoo/files/rc.local
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - pkg: virtualbox
