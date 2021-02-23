RTorrent Docker Test Environment
================================

Getting Started
---------------

```bash
# On linux systems:
./rdo init default

# On non-linux systems:
./rdo init machine

./rdo bash
```

Initialize the environment and start a custom bash session.

All commands assume you are working within the custom bash session.


Clone Repositories
------------------

```bash
rdo git clone
```

Clones the git repositories.


Build Docker Images
-------------------

```bash
rdo build all
```


Run CI tests
------------

```bash
rdo batch tests/ci-all
```
