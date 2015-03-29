FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

# perl
# NOTE This installs to /usr/local/bin. Debian's perl is at /usr/bin.
RUN apt-get update                                                        \
 && apt-get -y --no-install-recommends install gcc libc6-dev make wget    \
 && rm -fr /var/lib/apt/lists/*                                           \
 && wget -q http://www.cpan.org/src/5.0/perl-5.20.2.tar.gz                \
 && echo b1a43992a717d506095856d370550caa11dba8132a4fdaa186a1ae7e1fbd9b9d \
    perl-5.20.2.tar.gz | sha256sum -c --quiet                             \
 && tar xzf perl-5.20.2.tar.gz                                            \
 && cd perl-5.20.2                                                        \
 && ./Configure                                                           \
    -Accflags="-DNO_MATHOMS -DPERL_DISABLE_PMC"                           \
    -des                                                                  \
    -Duseshrplib                                                          \
 && make -j`nproc`                                                        \
 && make install                                                          \
 && cd /                                                                  \
 && rm -r perl-5.20.2*                                                    \
 && apt-get -y purge gcc libc6-dev make wget                              \
 && apt-get -y --purge autoremove

# cpanm
RUN apt-get update                                                       \
 && apt-get -y --no-install-recommends install ca-certificates make wget \
 && rm -fr /var/lib/apt/lists/*                                          \
 && wget -qO-                                                            \
    https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm    \
    | perl - --skip-satisfied App::cpanminus                             \
 && rm -r ~/.cpanm                                                       \
 && apt-get -y purge ca-certificates make wget                           \
 && apt-get -y --purge autoremove
