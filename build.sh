#!/usr/bin/env bash

##########################################################################
# Nginx-PHP-FPM docker image build script
#
# @author: adrian7 <adrian.silimon.eu>                                   #
# @version: 0.2                                                          #
##########################################################################

SCRIPTNAME="$(basename $0)"
VERSION="0.2"

BUILDNAME="$1"

#Defaults
DEFAULT_CONFIG_DIR=dev
DEFAULT_CONFIG_VER=7

#Text formatting
t_underline=$(tput sgr 0 1)             # Underline
t_bold=$(tput bold)                     # Bold
t_red=$(tput setaf 1)                   # Red
t_green=$(tput setaf 2)                 # Green
t_blue=$(tput setaf 6)                  # Blue
t_white=$(tput setaf 7)                 # White
t_reset=$(tput sgr0)                    # Reset

usage() {

read -r -d '' HELP << EOM

$SCRIPTNAME version $VERSION

Usage: $SCRIPTNAME <name:tag> [options...]

tag:name    image name and tag

optional arguments:
 --help             displays this help message
 --env environment  use config-{env} configuration
 --php version      set php version / base image
 --customize folder the folder under ./custom to build from the resulting image; 

By default the script will build all folders in ./custom 

EOM

    echo "$HELP" 1>&2; exit 1;

}

warning() {
    printf "%s\n" "${t_bold}${t_red}(!) ${1} ${t_reset}"
}

info() {
    printf "%s\n" "${t_bold}${t_blue}(!) ${1}${t_reset}"
}

success() {
    printf "%s\n" "${t_bold}${t_green}(!) ${1}${t_reset}"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") 		set -- "$@" "-h" ;;
    "--env")  		set -- "$@" "-e" ;;
    "--php")  		set -- "$@" "-p" ;;
	"--customize")  set -- "$@" "-c" ;;
    *)        		set -- "$@" "$arg"
  esac
done

shift

# Parse short options
while getopts "e:p:c:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
            ;;
        p)
            p=${OPTARG}
			;;
        c)
            c=${OPTARG}
			;;	
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

CONFIG_DIR=$e
CONFIG_VER=$p
CUSTOMIZE=$c

#Init defaults
if 
	[ -z "$BUILDNAME" ] || 
	[ "$BUILDNAME" = '--php' ] || 
	[ "$BUILDNAME" = '--env' ] ; 
then
	warning "Please enter a name and tag for the image!"
	usage
fi

if [ -z "$CONFIG_DIR" ]; then
	CONFIG_DIR="$DEFAULT_CONFIG_DIR"
fi

if [ -d "$PWD/config-$CONFIG_DIR" ]; then
	echo ""
else
	warning "Folder ${PWD}/config-${CONFIG_DIR} doesn't exist!" 
	exit 1 
fi

if [ -z "$CONFIG_VER" ]; then
	CONFIG_VER="$DEFAULT_CONFIG_VER"
fi

#Start build
info "Building image ${BUILDNAME} ... 
 - using ${CONFIG_DIR} configuration 
 - with php version ${CONFIG_VER}"
 
#Docker build
docker build -t $BUILDNAME \
	--build-arg BUILD_CONFIG="${CONFIG_DIR}" \
    --build-arg BUILD_VERSION="${CONFIG_VER}" \
	.

#Build custom images based on the previously built image

if [ ! -z "$CUSTOMIZE" ] && [ ! -d "$PWD/custom/$CUSTOMIZE" ]; then 
	warning "Folder ${CUSTOMIZE} can't be built. Folder missing!"
	exit 1
fi

if [ -d "$PWD/custom" ]; then
	
	BUILD_DIR=$PWD/custom
	
	cd "$BUILD_DIR"
	
	for i in * ; do
		
		if [ ! -z "$CUSTOMIZE" ] && [ "$i" != "$CUSTOMIZE" ]; then
			continue
		fi
		
		if [ -d "$i" ] && [ -f "${BUILD_DIR}/${i}/Dockerfile" ]; then  
			
			DOCKERFILE_PATH="${BUILD_DIR}/${i}/Dockerfile"
	    	info "Building custom image $i:latest ..."
			
			docker build -t $i \
				-f "${DOCKERFILE_PATH}" \
				--build-arg BUILD_FROM="${BUILDNAME}" \
				--no-cache \
				"$BUILD_DIR/$i"
			
		else 
			warning "Folder ${i} can't be built. Dockerfile missing!"
		fi	
		
	done
	
fi
	 		 
 
 



