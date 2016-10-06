# cuckoo-salt
SaltStack formula for deploying Cuckoo Sandbox

## Before running

- Known bug with the pip.installed state. Waiting on an upstream fix. Current workaround is documented in the deps.sls file.
- vmcloak_generate.sh needs an Office key
- Testing has been done on Ubuntu 16.04 LTS, but needs a lot more 
