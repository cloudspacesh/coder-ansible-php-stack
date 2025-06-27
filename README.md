# Ansible Playbook for Coder Workspace

## If you have sudo without password (like ubuntu vm)
### Apply only core roles
```bash
./run.sh --tags core
```

### Apply extra roles
```bash
./run.sh --tags core,php84,composer@2,mysql80,mailhog
```

## Otherwise
### Apply only core roles
```bash
./run.sh --ask-become-pass --tags core
```

### Apply extra roles
```bash
./run.sh --ask-become-pass --tags core,php84,composer@2,mysql80,mailhog
```

