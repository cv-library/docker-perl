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

COPY carton /usr/local/bin/carton
