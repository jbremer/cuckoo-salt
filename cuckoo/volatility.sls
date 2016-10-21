cuckoo_volatility_git:
  git.latest:
    - name: https://github.com/volatilityfoundation/volatility.git
    - target: /srv/volatility
    - force_clone: True

cuckoo_install_volatility:
  cmd.run:
    - name: cd /srv/volatility && python setup.py build && python setup.py build install
    - cwd: /srv/volatility
    - shell: /bin/bash
    - onchanges:
      - git: cuckoo_volatility_git
