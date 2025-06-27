# Ansible Playbook for Coder Workspaces

## If you have passwordless sudo (e.g., Ubuntu VM):
### Apply core roles only:
```bash
./run.sh --tags core
```
### Apply core + extra roles:
```bash
./run.sh --tags core,php84,composer@2,mysql80,mailhog
```

## If sudo password is required:
### Apply core roles only:
```bash
./run.sh --ask-become-pass --tags core
```
### Apply core + extra roles:
```bash
./run.sh --ask-become-pass --tags core,php84,composer@2,mysql80,mailhog
```
