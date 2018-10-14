#!/usr/bin/env bash
#
# To build and push Docker images of different combination of PHP and Subversion versions.
#

set -e

usage()
{
cat << EOF
usage: $0

This script builds a Docker image with specific versions of PHP and Subversion.

OPTIONS:
   -h | --help    Show this message
   -p | --push    Push the image to the Docker Hub registry (optional)

Sample commands:

    # To build an image with specific versions of PHP and Subversion.
    PHP_VERSION=7.2 SVN_VERSION=1.10.3 ./build.sh

    # To build and push an image with specific versions of PHP and Subversion.
    PHP_VERSION=7.2 SVN_VERSION=1.10.3 ./build.sh -p
EOF
}

DOCKER_PUSH=
while :; do
    case $1 in
        -h|-\?|--help)
            usage
            exit
            ;;
        -p|--push)
            DOCKER_PUSH=true
            ;;
        --) # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *) # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done

if [ -z "${PHP_VERSION}" ] ; then
    echo "Error: environment variable 'PHP_VERSION' is empty or not set."
    echo "       Please run command '$0 -h' to see help information."
    exit 1
fi
if [ -z "${SVN_VERSION}" ] ; then
    echo "Error: environment variable 'SVN_VERSION' is empty or not set."
    echo "       Please run command '$0 -h' to see help information."
    exit 1
fi

echo "Building image deminy/php-svn:php-${PHP_VERSION}-svn-${SVN_VERSION}."

sed "s/%%PHP_VERSION%%/${PHP_VERSION}/g" Dockerfile.tpl > Dockerfile
docker build \
    --no-cache \
    --build-arg SVN_VERSION=${SVN_VERSION} \
    -t "deminy/php-svn:php-${PHP_VERSION}-svn-${SVN_VERSION}" .

if [ "${DOCKER_PUSH}" = "true" ] ; then
    echo "Pushing image deminy/php-svn:php-${PHP_VERSION}-svn-${SVN_VERSION}"
    docker push "deminy/php-svn:php-${PHP_VERSION}-svn-${SVN_VERSION}"
    echo "Done building and pushing image deminy/php-svn:php-${PHP_VERSION}-svn-${SVN_VERSION}."
else
    echo "Done building image deminy/php-svn:php-${PHP_VERSION}-svn-${SVN_VERSION}."
    echo "To push the image built to the Docker Hub registry, please run following command:"
    echo "    docker push deminy/php-svn:php-${PHP_VERSION}-svn-${SVN_VERSION}"
fi