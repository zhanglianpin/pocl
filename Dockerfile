FROM amd64/ubuntu:16.04
ARG GIT_COMMIT=master
ARG GH_PR
ARG GH_SLUG=pocl/pocl
ARG LLVM_VERSION=4.0
LABEL git-commit=$GIT_COMMIT vendor=pocl distro=Ubuntu version=1.0
ENV TERM dumb
RUN apt update
RUN apt upgrade -y
RUN apt install -y software-properties-common wget
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-${LLVM_VERSION} main" && apt update
RUN apt install -y build-essential ocl-icd-libopencl1 cmake git pkg-config libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} make ninja-build ocl-icd-libopencl1 ocl-icd-dev ocl-icd-opencl-dev libhwloc-dev zlib1g zlib1g-dev clinfo dialog apt-utils

RUN cd /home ; git clone https://github.com/$GH_SLUG.git ; cd /home/pocl ; git checkout $GIT_COMMIT
RUN cd /home/pocl ; test -z "$GH_PR" || (git fetch origin +refs/pull/$GH_PR/merge && git checkout -qf FETCH_HEAD) && :
RUN cd /home/pocl ; mkdir b ; cd b; cmake -G Ninja -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-${LLVM_VERSION} -DCMAKE_INSTALL_PREFIX=/usr ..
RUN cd /home/pocl/b ; ninja install
CMD cd /home/pocl/b ; clinfo ; ctest -j4 --output-on-failure -L internal