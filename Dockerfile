FROM ubuntu:22.04

RUN echo "Updating Ubuntu"
RUN apt-get update && apt-get upgrade -y

RUN echo "Installing dependencies..."
RUN apt install -y \
	ccache \
	clang \
	clang-format \
	clang-tidy \
	cppcheck \
	curl \
	doxygen \
	gcc \
	git \
	graphviz \
	make \
	ninja-build \
	python3 \
	python3-pip \
	tar \
	unzip \
	vim \
	cmake \
	build-essential \
	libssl-dev 
# 			googletest
RUN echo "Installing dependencies not found in the package repos..."

# RUN pip3 install conan

# RUN git clone https://github.com/catchorg/Catch2.git && \
# 		 cd Catch2 && \
# 		 cmake -Bbuild -H. -DBUILD_TESTING=OFF && \
# 		 cmake --build build/ --target install

# Disabled pthread support for GTest due to linking errors
RUN git clone https://github.com/google/googletest.git --branch release-1.14.0 && \
	cd googletest && \
	cmake -Bbuild -Dgtest_disable_pthreads=1 && \
	cmake --build build --config Release && \
	cmake --build build --target install --config Release

# RUN git clone https://github.com/microsoft/vcpkg && \
# 		cd vcpkg && \
# 		./bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries	
