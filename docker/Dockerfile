# Minimal dockerfile to test hfst

FROM ubuntu:latest
MAINTAINER Flammie A Pirinen <flammie@iki.fi>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential automake autoconf git wget lsb-release libtool zip \
    pkg-config libicu-dev libfst-dev libfoma-dev zlib1g-dev bison flex &&\
    git clone https://github.com/hfst/hfst && \
    cd hfst && \ 
    ./autogen.sh && \
    ./configure && \
    make && \
    make check

