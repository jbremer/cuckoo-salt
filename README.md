# cuckoo-salt
SaltStack formula for deploying Cuckoo Sandbox

## Before running

- Known bug with the pip.installed state. Waiting on an upstream fix. Current workaround is documented in the deps.sls file.
- vmcloak_generate.sh needs an Office key
- Testing has been done on Ubuntu 16.04 LTS, but needs a lot more 

## TODO

- Moar testing
- Pillarize all the configs/Make configuration as dynamic as possible
- Turn into a proper salt formula
- Think about creating a salt module for vmcloak since it's all python anyways
- Add a mongo deploy state?
- Add an ELK cluster deploy state?
