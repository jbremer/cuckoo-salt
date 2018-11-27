mongo_percona_repo:
  pkgrepo.managed:
    - humanname: Percona repository
    - name: deb [ arch=amd64 ] http://mirror.cert.ee/repo.percona.com/apt {{ salt['grains.get']('oscodename') }} main 
    - dist: {{ salt['grains.get']('oscodename') }}
    - file: /etc/apt/sources.list.d/percona.list
    - keyid: 8507EFA5
    - keyserver: keyserver.ubuntu.com

percona_mongo_server:
  pkg.installed:
    - name: percona-server-mongodb-36
    - refresh: True
    - require:
      - pkgrepo: mongo_percona_repo

mongo_percona_conf:
  file.managed:
    - name: /etc/mongod.conf
    - source: salt://{{ slspath }}/files/mongod.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja

mongo_db_dir:
  file.directory:
    - name: {{ salt['pillar.get']('cuckoo:mongo:dbPath', '/var/lib/mongodb') }}
    - user: mongod
    - group: mongod
    - dir_mode: 775
    - file_mode: 644
    - clean: True
    - recurse:
      - user
      - group
      - mode

mongo_limits_conf:
  file.append:
    - name: /etc/security/limits.conf
    - source: salt://cuckoo/files/limits.conf

cuckoo_mongod_service:
  service.running:
    - name: mongod
    - enable: True
    - watch:
      - pkg: percona_mongo_server
      - file: mongo_percona_conf
      - file: mongo_db_dir
      - file: mongo_limits_conf
