FROM debian:jessie

RUN apt-get update                                                     \
 && apt-get -y --no-install-recommends install gcc libc6-dev make wget \
 && rm -fr /var/lib/apt/lists/*

# NOTE This installs to /usr/local/bin, with Debian's perl being at /usr/bin
#
# Passing -march=corei7-avx to GCC means this binary will require an i3/5/7
# Sandy Bridge or higher.
RUN wget -q http://www.cpan.org/src/5.0/perl-5.20.2.tar.gz                \
 && echo b1a43992a717d506095856d370550caa11dba8132a4fdaa186a1ae7e1fbd9b9d \
        perl-5.20.2.tar.gz | sha256sum -c --quiet                         \
 && tar xzf perl-5.20.2.tar.gz                                            \
 && cd perl-5.20.2                                                        \
 && ./Configure                                                           \
        -Accflags="                                                       \
            -DNO_MATHOMS                                                  \
            -DPERL_DISABLE_PMC                                            \
            # Sandy Bridge or higher                                      \
            -march=corei7-avx"                                            \
        -des                                                              \
        -Dprivlib=/usr/local/lib/perl5                                    \
        -Dsitearch=/usr/local/lib/perl5                                   \
        -Dsitelib=/usr/local/lib/perl5                                    \
        -Duseshrplib                                                      \
        -Dvendorarch=/usr/local/lib/perl5                                 \
        -Dvendorlib=/usr/local/lib/perl5                                  \
 && make -j`nproc`                                                        \
 && make install                                                          \
 && cd /                                                                  \
 && rm -r perl-5.20.2*

RUN export PERL5LIB=/carton/lib/perl5                          \
 && export PERL_MB_OPT=--install_base\ /carton                 \
 && export PERL_MM_OPT=INSTALL_BASE=/carton                    \
 && apt-get update                                             \
 && apt-get -y --no-install-recommends install ca-certificates \
 && rm -fr /var/lib/apt/lists/*                                \
 && wget -qO- http://cpanmin.us | perl - -l carton Carton      \
 && apt-get -y purge ca-certificates                           \
 && apt-get -y --purge autoremove                              \
 && cd carton                                                  \
 && touch cpanfile                                             \
 && bin/carton install                                         \
 && bin/carton bundle                                          \
 && mv vendor/bin/carton /usr/local/bin                        \
 && cd /                                                       \
 && rm -r carton
