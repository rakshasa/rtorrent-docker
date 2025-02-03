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


Prepare Autoconf Scripts
------------------------

```bash
# This will fail when attempting to build libtorrent due to missing autoconf scripts.
rdo build all

docker run --rm -it --mount "type=bind,source=${PWD}/data,target=/data/" rdo/build/rtorrent/compiler:alpine-3 /bin/bash
```

While in the docker container, run the following:

```bash
cd /data/libtorrent

libtoolize
aclocal -I scripts
autoconf -i
autoheader
automake --add-missing

cd /data/rtorrent

libtoolize
aclocal -I scripts
autoconf -i
autoheader
automake --add-missing
```


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


Cleanup for Release
-------------------

```
make maintainer-clean
autoreconf --force --install
```
