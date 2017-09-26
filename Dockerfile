FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

# perl
# NOTE This installs to /usr/local/bin. Debian's perl is at /usr/bin.
RUN apt-get update                                                              \
 && apt-get -y --no-install-recommends install gcc libc6-dev make wget xz-utils \
 && rm -fr /var/lib/apt/lists/*                                                 \
 && wget -q http://www.cpan.org/src/5.0/perl-5.26.1.tar.xz                      \
 && echo fe8208133e73e47afc3251c08d2c21c5a60160165a8ab8b669c43a420e4ec680       \
    perl-5.26.1.tar.xz | sha256sum -c --quiet                                   \
 && tar xJf perl-5.26.1.tar.xz                                                  \
 && cd perl-5.26.1                                                              \
 && ./Configure                                                                 \
    -Accflags="-DNO_MATHOMS -DPERL_DISABLE_PMC -DSILENT_NO_TAINT_SUPPORT"       \
    -des                                                                        \
    -Duseshrplib                                                                \
 && make -j`nproc`                                                              \
 && make install                                                                \
 && cd /                                                                        \
 && rm -r perl-5.26.1* usr/local/lib/perl5/5.26.1/pod                           \
 && apt-get -y purge gcc libc6-dev make wget xz-utils                           \
 && apt-get -y --purge autoremove

# cpanm
RUN apt-get update                                                       \
 && apt-get -y --no-install-recommends install ca-certificates make wget \
 && rm -fr /var/lib/apt/lists/*                                          \
 && wget -qO-                                                            \
    https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm |  \
    perl - --skip-satisfied App::cpanminus                               \
 && rm -r ~/.cpanm                                                       \
 && apt-get -y purge ca-certificates make wget                           \
 && apt-get -y --purge autoremove
