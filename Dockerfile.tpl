FROM php:%%PHP_VERSION%%-cli

# We accept build parameter SVN_VERSION and make it persistent in the Docker image.
# @see https://docs.docker.com/engine/reference/builder/#arg
ARG SVN_VERSION
ENV SVN_VERSION $SVN_VERSION

RUN \
  apt-get update   && \
  apt-get install -y  \
    libapr1-dev       \
    libaprutil1-dev   \
    libsqlite3-dev    \
    libtool           \
    libtool-bin       \
    python            \
    zlib1g-dev     && \
  curl -LO https://github.com/apache/subversion/archive/${SVN_VERSION}.tar.gz && \
  tar -zxvf ${SVN_VERSION}.tar.gz  && \
  cd subversion-${SVN_VERSION}     && \
  ./autogen.sh                     && \
  LDFLAGS="-Wl,-rpath,/usr/local/lib" ./configure --with-lz4=internal --with-utf8proc=internal && \
  make                             && \
  make install                     && \
  cd ..                            && \
  rm -rf subversion-${SVN_VERSION} && \
  curl                    \
    -sf                   \
    --connect-timeout 5   \
    --max-time         15 \
    --retry            5  \
    --retry-delay      2  \
    --retry-max-time   60 \
    http://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
  composer --version && \
  php --version      && \
  svn --version

WORKDIR /docker-php-svn
