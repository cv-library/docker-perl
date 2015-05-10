FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

# perl
# NOTE This installs to /usr/local/bin. Debian's perl is at /usr/bin.
RUN apt-get update                                                              \
 && apt-get -y --no-install-recommends install gcc libc6-dev make wget xz-utils \
 && rm -fr /var/lib/apt/lists/*                                                 \
 && wget -q http://www.cpan.org/src/5.0/perl-5.21.11.tar.xz                     \
 && echo efd174beb0e7e9b5db91e42ab98090e4f748f66e9c1e3bf6813e56082e884562       \
    perl-5.21.11.tar.xz | sha256sum -c --quiet                                  \
 && tar xJf perl-5.21.11.tar.xz                                                 \
 && cd perl-5.21.11                                                             \
 && ./Configure                                                                 \
    -Accflags="-DNO_MATHOMS -DPERL_DISABLE_PMC"                                 \
    -des                                                                        \
    -Dusedevel                                                                  \
    -Duseshrplib                                                                \
 && make -j`nproc`                                                              \
 && make install                                                                \
 && rm -r /usr/local/lib/perl5/5.21.11/pod                                      \
 && cd /                                                                        \
 && rm -r perl-5.21.11*                                                         \
 && apt-get -y purge gcc libc6-dev make wget                                    \
 && apt-get -y --purge autoremove                                               \
    # Dev releases of perl have the version on the end of the binaries, rename.
 && find /usr/local/bin -name '*5.21.11' -exec bash -c 'mv $0 ${0::-7}' {} \;

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
