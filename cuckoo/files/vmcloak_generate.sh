#/bin/bash
# This script uses vmcloak to generate vm-s for cuckoo

vmcloak init --win7x64 win7master --iso-mount /srv/iso/win7/ --ip 192.168.56.199 --gateway 192.168.56.1 --dns 8.8.8.8 --ramsize 4096 --vramsize 128
vmcloak install win7master adobepdf:9.4.0 wic pillow dotnet:4.6.1 java:7u71 flash:15.0.0.167 winrar cuteftp ie11 wallpaper extract extract.zip=/srv/iso/Archive.zip extract.dir=Desktop
vmcloak install win7master office office.isopath=/srv/iso/Office_2010SP1_x64.ISO office.serialkey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX office.activate=1
vmcloak snapshot --count {{ salt['pillar.get']('vmcloak:count') }} --cpus 4 --resolution 1280x1024 --ramsize 4096 win7master {{ salt['pillar.get']('vmcloak:basename') }} {{ salt['pillar.get']('vmcloak:ipprefix') }}{{ salt['pillar.get']('vmcloak:ipstart') }}
