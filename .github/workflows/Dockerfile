#
# Dockerfile for KallistiOS Toolchain
#

# Define before FROM to use globally across stages
ARG BASE_PATH=/opt/toolchains/dc
ARG KOS_PATH=${BASE_PATH}/kos
ARG DCCHAIN_PATH=${KOS_PATH}/utils/dc-chain

FROM debian:latest as build-deps

RUN apt-get update && \
	apt-get install -y \
		gawk patch bzip2 tar make libgmp-dev libmpfr-dev libmpc-dev \
		gettext wget libelf-dev texinfo bison flex sed git build-essential \
		diffutils curl libjpeg-dev libpng-dev python3 pkg-config cmake \
		libisofs-dev meson ninja-build rake


FROM build-deps as toolchain

ARG KOS_PATH
ARG DCCHAIN_PATH
ARG TOOLCHAIN_PROFILE
ARG DCCHAIN_ARGS

# Copy Necessary Data into Container
# By only copying the necessary files to build the toolchain docker
# can cache the toolchain layer as long as none of the files in these directories
# are changed. Doing so would trigger rebuilding the toolchain.
# TODO: More specifically copy includes to avoid rebuilds
COPY kos/include ${KOS_PATH}/include
COPY kos/kernel/arch/dreamcast/include/arch ${KOS_PATH}/kernel/arch/dreamcast/include/arch
COPY kos/kernel/arch/dreamcast/include/dc ${KOS_PATH}/kernel/arch/dreamcast/include/dc
COPY kos/kernel/arch/dreamcast/kernel ${KOS_PATH}/kernel/arch/dreamcast/kernel
COPY kos/utils/dc-chain ${DCCHAIN_PATH}

ARG BUILD_TYPE=kos

RUN cd ${DCCHAIN_PATH} \
	&& make -j2 ${DCCHAIN_ARGS} verbose=0 makejobs=$(nproc)

# build kos and related tools
# TODO: Could probably use a slimmer base image
#		but we need some host build tools for kos anyway
FROM toolchain as kos

# copy entire KOS folder into container
# TODO: copy only folders necessary for build. 
#		Example: Changes to doc/ will trigger a rebuild which might be unwanted
COPY kos/addons /opt/toolchains/dc/kos/addons
COPY kos/doc /opt/toolchains/dc/kos/doc
COPY kos/include /opt/toolchains/dc/kos/include
# COPY kos/examples /opt/toolchains/dc/kos/examples
COPY kos/kernel /opt/toolchains/dc/kos/kernel
COPY kos/lib /opt/toolchains/dc/kos/lib
COPY kos/loadable /opt/toolchains/dc/kos/loadable
COPY kos/utils /opt/toolchains/dc/kos/utils
COPY kos/AUTHORS /opt/toolchains/dc/kos/AUTHORS
COPY kos/environ_base.sh /opt/toolchains/dc/kos/environ_base.sh
COPY kos/environ_dreamcast.sh /opt/toolchains/dc/kos/environ_dreamcast.sh
COPY kos/Makefile /opt/toolchains/dc/kos/Makefile
COPY kos/Makefile.prefab /opt/toolchains/dc/kos/Makefile.prefab
COPY kos/Makefile.rules /opt/toolchains/dc/kos/Makefile.rules
COPY kos/README.md /opt/toolchains/dc/kos/README.md

# setup environ.sh file using default
RUN cd /opt/toolchains/dc/kos \
	&& ls -la \
	&& cp doc/environ.sh.sample environ.sh \
	# create link so environ.sh is sourced for interactive shells
	# example: docker run --rm -it $TAG /bin/bash
	&& ln -s /opt/toolchains/dc/kos/environ.sh /etc/profile.d/kos.sh

# pristine (default) is for dreamcast
# naomi can be specified as a build_arg
# overwriting this at runtime could cause issues
# so avoid doing so
# TODO: Give a warning if runtime arg != build arg
ARG KOS_SUBARCH="pristine"
ENV KOS_SUBARCH=${KOS_SUBARCH}

# set BASH_ENV so it works for non interactive as well
# example: docker run --rm $TAG "make"
ENV BASH_ENV="/opt/toolchains/dc/kos/environ.sh"

# Set Shell to Bash so environ.sh will be sourced in every
# following run command
SHELL ["/bin/bash", "-c"]

# set entry point to bash so arg to docker run can be 
# run as a command.
ENTRYPOINT ["/bin/bash", "-c"]

# if run with no parameters just start bash
CMD ["/bin/bash"]

# build KOS
RUN cd /opt/toolchains/dc/kos && make -j$(nproc)

# COPY kos/examples /opt/toolchains/dc/kos/examples

FROM kos as kos-ports
COPY ports /opt/toolchains/dc/kos-ports
RUN cd /opt/toolchains/dc/kos-ports \
	&& sh utils/build-all.sh

COPY kos/examples /opt/toolchains/dc/kos/examples

