FROM multiarch/ubuntu-core:armhf-xenial

#install curl and build essential
RUN apt-get update
RUN apt-get install -y build-essential curl

# Can't use system versions of libz, libevent, or libssl when doing a static build.

## Build openssl from source
RUN curl -fsSL "https://www.openssl.org/source/openssl-1.0.2m.tar.gz" | tar zxvf -
WORKDIR openssl-1.0.2m
RUN ./config --prefix=$PWD/install no-shared no-dso
RUN make -j$(nproc)
RUN make install
WORKDIR ..

# Build zlib from source
RUN curl -fsSL "https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz" | tar zxvf -
WORKDIR libevent-2.1.8-stable
RUN ./configure --prefix=$PWD/install \
                --disable-shared \
                --enable-static \
                --with-pic
RUN make -j$(nproc)
RUN make install
WORKDIR ..

# Build zlib from source
RUN curl -fsSL "https://zlib.net/zlib-1.2.11.tar.gz" | tar zxvf -
WORKDIR zlib-1.2.11
RUN ./configure --prefix=$PWD/install
RUN make -j$(nproc)
RUN make install
WORKDIR ..

# Static toribuild
ARG TOR_VERSION
ENV TOR_VERSION=0.3.2.10
RUN curl -fsSL "https://www.torproject.com/dist/tor-${TOR_VERSION}.tar.gz" | tar xzf -
WORKDIR tor-${TOR_VERSION}

RUN ./configure --prefix=$PWD/install \
                --enable-static-tor \
                --with-libevent-dir=/usr \
                --with-openssl-dir=$PWD/../openssl-1.0.2m/install \
                --with-zlib-dir=$PWD/../zlib-1.2.11/install \
                --with-libevent-dir=$PWD/../libevent-2.1.8-stable/install

RUN make -j$(nproc)
RUN make install
