FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive

# perl
# NOTE This installs to /usr/local/bin. Debian's perl is at /usr/bin.
RUN apt-get update                                                              \
 && apt-get -y --no-install-recommends install gcc libc6-dev make wget xz-utils \
 && rm -fr /var/lib/apt/lists/*                                                 \
 && wget -q http://www.cpan.org/src/5.0/perl-5.28.0.tar.xz                      \
 && echo 059b3cb69970d8c8c5964caced0335b4af34ac990c8e61f7e3f90cd1c2d11e49       \
    perl-5.28.0.tar.xz | sha256sum -c --quiet                                   \
 && tar xJf perl-5.28.0.tar.xz                                                  \
 && cd perl-5.28.0                                                              \
 && ./Configure                                                                 \
    -Accflags="-DNO_MATHOMS -DPERL_DISABLE_PMC -DSILENT_NO_TAINT_SUPPORT"       \
    -des                                                                        \
    -Duseshrplib                                                                \
 && make -j`nproc`                                                              \
 && make install                                                                \
 && cd /                                                                        \
 && rm -r perl-5.28.0* usr/local/lib/perl5/5.28.0/pod                           \
 && apt-get -y purge gcc libc6-dev make wget xz-utils                           \
 && apt-get -y --purge autoremove

COPY cpm /usr/local/bin/
