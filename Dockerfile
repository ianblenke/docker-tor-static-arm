FROM multiarch/ubuntu-core:armhf-xenial

RUN apt-get update
RUN apt-get install -y build-essential curl zlib1g-dev libevent-dev libssl-dev
RUN curl -fsSL "https://www.torproject.com/dist/tor-0.3.2.10.tar.gz" | tar zxvf -

WORKDIR tor-0.3.2.10

RUN ./configure --prefix=$PWD/install \
                --enable-static-tor
RUN make -j$(nproc)
RUN make install
