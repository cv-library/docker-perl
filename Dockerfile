FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

# perl
# NOTE This installs to /usr/local/bin. Debian's perl is at /usr/bin.
RUN apt-get update                                                              \
 && apt-get -y --no-install-recommends install gcc libc6-dev make wget xz-utils \
 && rm -fr /var/lib/apt/lists/*                                                 \
 && wget -q http://www.cpan.org/src/5.0/perl-5.22.0.tar.xz                      \
 && echo be83ead0c5c26cbbe626fa4bac1a4beabe23a9eebc15d35ba49ccde11878e196       \
    perl-5.22.0.tar.xz | sha256sum -c --quiet                                   \
 && tar xJf perl-5.22.0.tar.xz                                                  \
 && cd perl-5.22.0                                                              \
 && ./Configure                                                                 \
    -Accflags="-DNO_MATHOMS -DPERL_DISABLE_PMC"                                 \
    -des                                                                        \
    -Duseshrplib                                                                \
 && make -j`nproc`                                                              \
 && make install                                                                \
 && cd /                                                                        \
 && rm -r perl-5.22.0* usr/local/lib/perl5/5.22.0/pod                           \
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
