# Use PyTorch runtime image as the base
FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-devel

# Set environment variables for CUDA
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=$CUDA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
ENV TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6+PTX;8.9;9.0" 

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update the system and install Python 3.8 with necessary tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    tar \
    python3-pip \
    python3-setuptools \
    python-is-python3 \
    ffmpeg \
    libsm6 \
    libxext6 \
    tree \
    g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN python --version


# Upgrade pip to the latest version
RUN pip install --no-cache-dir --upgrade pip

COPY ./requirements.txt ./requirements.txt
COPY ./submodules ./submodules

RUN pip install --no-cache-dir -r requirements.txt && \
    pip install submodules/simple-knn && \
    pip install submodules/diff-gaussian-rasterization && \
    pip install submodules/fused-ssim

RUN rm -rf ./requirements.txt && \
    rm -rf ./submodules

# Set working directory
WORKDIR /app
COPY run.sh /run.sh
COPY thirdparty/omnicli /omnicli
COPY . .

USER root
