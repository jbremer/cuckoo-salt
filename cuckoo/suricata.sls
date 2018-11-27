include:
  - cuckoo.deps

cuckoo_suricata:
  pkgrepo.managed:
    - ppa: oisf/suricata-stable
  pkg.latest:
    - name: suricata
    - refresh: True

cuckoo_suricata_certs:
  file.directory:
    - name: {{ salt['pillar.get']('cuckoo:home', '/home/cuckoo') }}/suricata/certs
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - mode: 755
    - makedirs: True
    - require:
      - user: cuckoo_user
      - group: cuckoo_user

cuckoo_suricata_yaml:
  file.managed:
    - name: /etc/suricata/suricata.yaml
    - source: salt://{{ slspath }}/files/suricata.yaml
    - user: root
    - group: root
    - template: jinja
    - require:
      - pkg: cuckoo_suricata

cuckoo_suricata_init:
  file.absent:
    - name: /etc/init.d/suricata

cuckoo_suricata_unit:
  file.managed:
    - name: /etc/systemd/system/suricata.service
    - source: salt://{{ slspath }}/files/suricata.service
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - pkg: cuckoo_suricata
      - file: cuckoo_suricata_init
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: cuckoo_suricata_unit
    - watch_in:
      - service: cuckoo_suricata_service

suricata_log_dir:
  file.directory:
    - name: /var/log/suricata
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: suricata
      - user: cuckoo_user
      - group: cuckoo_user

cuckoo_suricata_service:
    service.running:
      - name: suricata
      - enable: True
      - watch:
        - file: cuckoo_suricata_yaml
      - require:
        - file: cuckoo_suricata_unit
        - pkg: cuckoo_suricata

cuckoo_suricata_update:
  file.directory:
    - name: /var/lib/suricata/rules
    - user: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - group: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
    - makedirs: True
    - dir_mode: 750
    - file_mode: 640
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: suricata
      - user: cuckoo_user
      - group: cuckoo_user

{% if salt['pillar.get']('cuckoo:etpro') is defined %}
cuckoo_et_pro:
  cmd.run:
    - name: suricata-update enable-source et/pro secret-code={{ salt['pillar.get']('cuckoo:etpro') }}
    - runas: root
    - creates: /var/lib/suricata/update/sources/et-pro.yaml
    - require:
      - file: cuckoo_suricata_update
      - service: cuckoo_suricata_service
{% endif %}

cuckoo_suricata_oisf_trafficid:
  cmd.run:
    - name: suricata-update enable-source oisf/trafficid
    - runas: root
    - creates: /var/lib/suricata/update/sources/isf-trafficid.yaml
    - require:
      - cuckoo_suricata_update

cuckoo_suricata_ptresearch_attackdetection:
  cmd.run:
    - name: suricata-update enable-source ptresearch/attackdetection
    - runas: root
    - creates: /var/lib/suricata/update/sources/ptresearch-attackdetection.yaml
    - require:
      - cuckoo_suricata_update

cuckoo_suricata_ssl-fp-blacklist:
  cmd.run:
    - name: suricata-update enable-source sslbl/ssl-fp-blacklist
    - runas: root
    - creates: /var/lib/suricata/update/sources/sslbl-ssl-fp-blacklist.yaml
    - require:
      - cuckoo_suricata_update

cuckoo_suricata_etnetera_aggressive:
  cmd.run:
    - name: suricata-update enable-source etnetera/aggressive
    - runas: root
    - creates: /var/lib/suricata/update/sources/etnetera-aggressive.yaml
    - require:
      - cuckoo_suricata_update

cuckoo_suricata_update_cron:
  cron.present:
    - name: suricata-update
    - user: root
    - special: '@daily'
    - require:
      - file: cuckoo_suricata_update
