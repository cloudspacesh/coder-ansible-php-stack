# Ansible Roles

### Configure

Copy the `.env.dist` to `.env` and update by proper values, or run directly on the host without any `.env` file 

### Run
```
$ ./run.sh --ask-become-pass --tags base-system,zsh,php82,composer@2.6,mysql80,postgresql15,mailhog
```

