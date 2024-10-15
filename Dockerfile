#
# Development container base on Debian Wheezy
#
# The container contains:python3.4.5, CMake, VTK, Tcl, Tk, OpenGL
#
FROM rockylinux:9
LABEL maintainer='robertdreilly'


WORKDIR /tmpbuild

COPY . .
RUN cp *CA.crt /etc/pki/ca-trust/source/anchors
RUN update-ca-trust

###################################################################################################################
# Download sources & setup supporting libraries that are needed to build VTK
###################################################################################################################
# Download & extract VTK
ADD https://www.vtk.org/files/release/9.3/VTK-9.3.0.tar.gz /tmpbuild
RUN tar -zxvf VTK-9.3.0.tar.gz




RUN dnf install -y epel-release
RUN dnf install -y --enablerepo=devel gcc-c++ cmake openssl openssl-devel zip which

# Download, extract & build CMake
# http://www.vtk.org/Wiki/VTK/Configure_and_Build
ADD https://github.com/Kitware/CMake/releases/download/v3.25.3/cmake-3.25.3.tar.gz /tmpbuild
RUN tar -xvf cmake-3*
RUN cd /tmpbuild/cmake-3.25.3 && /tmpbuild/cmake-3.25.3/bootstrap
RUN cd /tmpbuild/cmake-3.25.3 && make
RUN cd /tmpbuild/cmake-3.25.3 && make install

# Install OpenGL
RUN dnf install -y mesa-libGL mesa-libGL-devel libX11-devel libXt-devel
RUN dnf install -y tcl tk python-devel python
# Debian, Ubuntu
# https://en.wikibooks.org/wiki/OpenGL_Programming/Installation/Linux
# RUN dnf update && dnf group install -y "Development Tools"


# Download & build Tcl
# https://www.tcl.tk/doc/howto/compile.html#unix
#ADD https://prdownloads.sourceforge.net/tcl/tcl8.6.6-src.tar.gz /tmpbuild
#RUN tar -zxvf tcl8.6.6-src.tar.gz
#RUN cd /tmpbuild/tcl8.6.6/unix
#RUN /tmpbuild/tcl8.6.6/unix/configure && make && make install

# Download & build Tk
# https://www.tcl.tk/doc/howto/compile.html
#ADD http://prdownloads.sourceforge.net/tcl/tk8.6.6-src.tar.gz && tar -zxvf tk8.6.6-src.tar.gz
#RUN cd tk8.6.6/unix && ./configure && make && make install
###################################################################################################################
# /end setup
###################################################################################################################

###################################################################################################################
# Building VTK with python interfaces
# http://ghoshbishakh.github.io/blog/blogpost/2016/03/05/buid-vtk.html
###################################################################################################################
RUN mkdir /vtk-build2
RUN cd /vtk-build2 && cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_TESTING:BOOL=OFF \
  -DVTK_WRAP_PYTHON:BOOL=ON \
  -DVTK_WRAP_PYTHON_SIP:BOOL=ON \
  -DVTK_WRAP_TCL:BOOL=ON \
  -DVTK_PYTHON_VERSION:STRING=3 \
  -DVTK_USE_TK:BOOL=ON \
  /tmpbuild/VTK-9.3.0

# Build VTK
RUN cd /vtk-build2 && make

# Now install the python bindings
RUN cd /vtk-build2/Wrapping/Python && make && make install

# Set environment variable to add the VTK libs to the Shared Libraries
# http://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html
ENV export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/vtk-build2/lib
# ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib:/vtk-build2/lib
###################################################################################################################
# /end VTK Build
###################################################################################################################

# Create Mount points
# https://docs.docker.com/engine/reference/builder/#/volume
#
# - /vtk-build: directory is used to build the VTK library from with a container with ccmake
# - /out: directory is used for python to write output files (JPEG, PNG, etc)
#VOLUME ["/vtk-build", "/out"]
#VOLUME ["/out"]

# Create the possible mount points
RUN mkdir /out && mkdir /src

# Set the source dir as default
WORKDIR /src

# Add examples
ADD examples /examples

# Enter the bash by default
CMD ["bash"]
