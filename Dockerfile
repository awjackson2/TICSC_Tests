# Start from an official Ubuntu image
FROM ubuntu:20.04

# Set the working directory inside the container
WORKDIR /.

# Set non-interactive mode for package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python \
    file \
    pulseaudio \
    libquadmath0 \
    libxft2 \
    firefox \
    libgomp1 \
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
    dos2unix \
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

# Set MATLAB Runtime version and installation directory
ENV MATLAB_RUNTIME_INSTALL_DIR=/usr/local/MATLAB/MATLAB_Runtime

# Download and install MATLAB Runtime R2024a
RUN wget https://ssd.mathworks.com/supportfiles/downloads/R2024a/Release/1/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip -P /tmp \
    && unzip -q /tmp/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip -d /tmp/matlab_runtime_installer \
    && /tmp/matlab_runtime_installer/install -destinationFolder ${MATLAB_RUNTIME_INSTALL_DIR} -agreeToLicense yes -mode silent \
    && rm -rf /tmp/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip /tmp/matlab_runtime_installer

# Set environment variables for SimNIBS
ENV PATH="/root/SimNIBS-4.1/bin:$PATH"
ENV SIMNIBSDIR="/root/SimNIBS-4.1"

# Download and install FSL
ENV FSLDIR="/usr/local/fsl"
ENV DEBIAN_FRONTEND="noninteractive"
ENV LANG="en_GB.UTF-8"

RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py && \
    python ./fslinstaller.py -d /usr/local/fsl/

ENTRYPOINT [ "sh", "-c", ". /usr/local/fsl/etc/fslconf/fsl.sh && /bin/bash" ]

# Copy the entire project into the container
COPY . .

# Make the testing project dir that tests will use
RUN mkdir -p mnt/testing_project_dir
RUN mkdir -p mnt/testing_project_dir/utils
RUN mkdir -p mnt/testing_project_dir/Subjects
RUN mkdir -p mnt/testing_project_dir/Simulations

COPY ti-csc/utils/testing_data/utils/montage_list.json mnt/testing_project_dir/utils
COPY ti-csc/utils/testing_data/utils/roi_list.json mnt/testing_project_dir/utils
COPY ti-csc/utils/testing_data/utils/EGI_template.csv mnt/testing_project_dir/Subjects/m2m_ernie/eeg_positions/EGI_template.csv

# Download the zip file with additional flags to handle failures better
RUN curl -L https://github.com/simnibs/example-dataset/releases/latest/download/simnibs4_examples.zip -o mnt/testing_project_dir/Subjects/simnibs4_examples.zip || echo "Download failed"

# Optionally, you can unzip the file if needed
RUN apt-get install -y unzip && unzip mnt/testing_project_dir/Subjects/simnibs4_examples.zip -d mnt/testing_project_dir/Subjects

# Set PYTHONPATH to include ti-csc
ENV PYTHONPATH=/ti-csc:$PYTHONPATH

ENV PROJECT_DIR_NAME="testing_project_dir"

RUN find /ti-csc/analyzer -type f -name "*.sh" -exec dos2unix {} +

# Set the entrypoint to run pytest directly
#CMD ["pytest", "Unit_Tests"]