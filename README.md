# Ansible Roles

### Configure

Copy the `.env.dist` to `.env` and update by proper values, or run directly on the host without any `.env` file 

### Apply only core roles
```
$ ./run.sh --ask-become-pass --tags php82,composer@2.6,mysql80,postgresql15,mailhog
```

### Apply extra roles
```
$ ./run.sh --ask-become-pass --tags php84,composer@2,mysql84,postgresql15,mailhog
```

