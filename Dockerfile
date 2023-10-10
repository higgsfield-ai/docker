FROM nvcr.io/nvidia/pytorch:22.10-py3

RUN apt -y update
RUN apt install -y libaio-dev
RUN python3 -m pip install --no-cache-dir --upgrade pip

RUN python3 -m pip uninstall -y torch torchvision torchaudio
RUN pip install --pre torch==2.2.0.dev20231007+cu121 --index-url https://download.pytorch.org/whl/nightly/cu121

RUN python3 -m pip install transformers
RUN python3 -m pip install accelerate
RUN python3 -m pip uninstall -y transformer-engine
RUN python3 -m pip uninstall -y torch-tensorrt apex
RUN python3 -m pip uninstall -y deepspeed || true


# setting default since buildargs of docker-py is not working
ARG UID=1000
ARG GID=1000

# Update the package list, install sudo, create a non-root user, and grant password-less sudo permissions
# We need non-root user so we won't mess up the .cache folder of the host
RUN apt update && \
  apt install -y sudo && \
  addgroup --gid $GID nonroot && \
  adduser --uid $UID --gid $GID --disabled-password --gecos "" nonroot && \
  echo 'nonroot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Set the non-root user as the default user
USER nonroot

WORKDIR /srv

RUN mkdir -p /home/nonroot/ || true

RUN sudo chown -R nonroot:nonroot /srv || true
