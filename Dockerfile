# Start from an official Ubuntu image
FROM ubuntu:20.04

# Set the working directory inside the container
WORKDIR /.

# Set non-interactive mode for package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    git \
    unzip \
    python3-pip \
    libglib2.0-0 \
    libssl1.1 \
    libopenblas-dev \
    build-essential \
    tar \
    bzip2 \
    gcc \
    g++ \
    cmake \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    pkg-config \
    gettext \
    curl \
    ninja-build \
    python3.8-venv \
    python3.8-dev \
    libgl1-mesa-glx \
    libglu1-mesa \
    mesa-utils \
    libgl1-mesa-dri \
    libglapi-mesa \
    libosmesa6 \
    libxt6 \
    libxext6 \
    libxrender1 \
    libxrandr2 \
    libxfixes3 \
    libxcursor1 \
    libxcomposite1 \
    libxdamage1 \
    libxi6 \
    libqt5widgets5 \
    libqt5gui5 \
    libqt5core5a \
    libqt5svg5 \
    libqt5opengl5 \
    libgtk2.0-0 \
    libreoffice \
    nodejs \
    npm \
    jq \
    bc \
    dc \
    vim \
    tmux \
    tcsh \
    tree \
    locales \
    fontconfig \
    execstack \
    imagemagick \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Python packages directly into the system Python environment
COPY requirements.txt .
RUN pip3 install --upgrade pip && \
    pip3 install -r requirements.txt

# Install SimNIBS
RUN mkdir -p /simnibs && chmod -R 777 /simnibs
RUN wget https://github.com/simnibs/simnibs/releases/download/v4.1.0/simnibs_installer_linux.tar.gz -P /simnibs \
    && tar -xzf /simnibs/simnibs_installer_linux.tar.gz -C /simnibs \
    && /simnibs/simnibs_installer/install -s

# Set environment variables for SimNIBS
ENV PATH="/root/SimNIBS-4.1/bin:$PATH"
ENV SIMNIBSDIR="/root/SimNIBS-4.1"

# Copy the entire project into the container
COPY . .

# Ensure the target directory exists
RUN mkdir -p TICSC/utils/testing_data

# Download the zip file with additional flags to handle failures better
RUN curl -L https://github.com/simnibs/example-dataset/releases/latest/download/simnibs4_examples.zip -o TICSC/utils/testing_data/simnibs4_examples.zip || echo "Download failed"

# Optionally, you can unzip the file if needed
RUN apt-get install -y unzip && unzip TICSC/utils/testing_data/simnibs4_examples.zip -d TICSC/utils/testing_data/

# Set PYTHONPATH to include TICSC
ENV PYTHONPATH=/TICSC:$PYTHONPATH

# Set the entrypoint to run pytest directly
#CMD ["pytest", "Unit_Tests"]