#!/bin/bash -xe

# packages required for to build, can be safely removed when done
DEV_PACKAGES="git-core gcc gcc-c++ boost-devel cmake autoconf automake libtool mariadb-devel"

# packages required for operation
PACKAGES="hostname mariadb-server"

# install required packages
# dnf install -y $DEV_PACKAGES
# dnf install -y $PACKAGES

# # create directories
# mkdir -p /_src && cd /_src

# # pull sources
# git clone https://github.com/anton-povarov/pinba2
# git clone https://github.com/anton-povarov/meow
# git clone https://github.com/nanomsg/nanomsg

# build nanomsg and install (this one is a lil tricky to build statically)
cd /_src/nanomsg
cmake \
	-DNN_STATIC_LIB=ON \
	-DNN_ENABLE_DOC=OFF \
	-DNN_MAX_SOCKETS=4096 \
	-DCMAKE_C_FLAGS="-fPIC -DPIC" \
	-DCMAKE_INSTALL_PREFIX=/_install/nanomsg \
	-DCMAKE_INSTALL_LIBDIR=lib \
	.

make -j4
make install

# pinba
cd /_src/pinba2
./buildconf.sh
./configure --prefix=/_install/pinba2 \
	--with-mysql=/usr \
	--with-boost=/usr \
	--with-meow=/_src/meow \
	--with-nanomsg=/_install/nanomsg
make -j4

# FIXME: this needs to be easier
# for install, just copy stuff to mysql plugin dir
PLUGINDIR=$(mysql_config --plugindir)
echo "PLUGINDIR is $PLUGINDIR"
cp /_src/pinba2/mysql_engine/.libs/libpinba_engine2.so /usr/lib64/mariadb/plugin

# clean everything
rm -rf /_src
rm -rf /_install
