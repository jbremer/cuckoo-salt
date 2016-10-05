suricata:
  pkgrepo.managed:
    - ppa: oisf/suricata-stable
  pkg.latest:
    - name: suricata
    - refresh: True

/var/log/suricata:
  file.directory:
    - user: {{ salt['pillar.get']('db:user'), 'cuckoo'}}
    - group: {{ salt['pillar.get']('db:user'), 'cuckoo'}} 
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: suricata

/srv/cuckoo/suricata/certs:
  file.directory:
    - user: cuckoo
    - group: cuckoo
    - mode: 755
    - makedirs: True

/etc/suricata/suricata.yaml:
  file.managed:
    - source: salt://cuckoo/files/suricata.yaml
    - user: root
    - group: root
    - template: jinja
    -require:
      - pkg: suricata

/etc/init.d/suricata:
  file.managed:
    - source: salt://cuckoo/files/suricata
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/suricata/suricata.yaml

suricata_service:
    service.running:
      - name: suricata
      - enable: True
      - watch:
        - file: /etc/init.d/suricata
        - file: /etc/suricata/suricata.yaml
      - require:
        - pkg: suricata
