# Ansible Roles

### Configure

Copy the `.env.dist` to `.env` and update by proper values, or run directly on the host without any `.env` file 

### Apply only core roles
```bash
./run.sh --ask-become-pass --tags core
```

### Apply extra roles
```bash
./run.sh --ask-become-pass --tags core,php84,composer@2,mysql84,postgresql15,mailhog
```

