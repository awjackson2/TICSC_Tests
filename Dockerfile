# Dockerfile.simnibs
FROM ubuntu:20.04

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python          \
    file            \
    pulseaudio      \
    libquadmath0    \
    libxft2         \
    firefox         \
    libgomp1        \
    wget \
    git \
    unzip \
    python3.8 \
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
    tcsh \
    tree \
    locales \
    execstack \
    imagemagick \
    curl \
    dos2unix \
    python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV FSLDIR="/usr/local/fsl"
ENV LANG="en_GB.UTF-8"

# Install FSL
RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py && \
    python ./fslinstaller.py -d /usr/local/fsl --debug && \
    rm -f fslinstaller.py && \
    rm -rf $FSLDIR/miniconda/installer_log.txt

# Set up Python environment and install required Python packages
RUN pip3 install dcm2niix numpy scipy pandas meshio nibabel && \
    rm -rf /root/.cache/pip

# Install SimNIBS (~4.4GB)
RUN mkdir -p /simnibs && chmod -R 777 /simnibs && \
    wget https://github.com/simnibs/simnibs/releases/download/v4.1.0/simnibs_installer_linux.tar.gz -P /simnibs && \
    tar -xzf /simnibs/simnibs_installer_linux.tar.gz -C /simnibs && \
    /simnibs/simnibs_installer/install -s && \
    rm -rf /simnibs/simnibs_installer /simnibs/simnibs_installer_linux.tar.gz

# Set environment variables for SimNIBS
ENV PATH="/root/SimNIBS-4.1/bin:$PATH"
ENV SIMNIBSDIR="/root/SimNIBS-4.1"

# Set MATLAB Runtime version and installation directory for R2024b
ENV MATLAB_RUNTIME_VERSION="R2024b"
ENV MATLAB_RUNTIME_INSTALL_DIR="/usr/local/MATLAB/MATLAB_Runtime"
# Set environment variables for MATLAB Runtime
ENV LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/R2024b/bin/glnxa64:$LD_LIBRARY_PATH"

# Download and install MATLAB Runtime R2024b (~3.8GB)
RUN wget https://ssd.mathworks.com/supportfiles/downloads/${MATLAB_RUNTIME_VERSION}/Release/1/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_${MATLAB_RUNTIME_VERSION}_Update_1_glnxa64.zip -P /tmp && \
    unzip -q /tmp/MATLAB_Runtime_${MATLAB_RUNTIME_VERSION}_Update_1_glnxa64.zip -d /tmp/matlab_runtime_installer && \
    /tmp/matlab_runtime_installer/install -destinationFolder ${MATLAB_RUNTIME_INSTALL_DIR} -agreeToLicense yes -mode silent && \
    rm -rf /tmp/MATLAB_Runtime_${MATLAB_RUNTIME_VERSION}_Update_1_glnxa64.zip /tmp/matlab_runtime_installer

# Clone TI-CSC repository
COPY ./ti-csc ti-csc

# Create the target directory and copy resources
RUN mkdir -p $SIMNIBSDIR/resources/ElectrodeCaps_MNI/ && \
    cp /ti-csc/assets/ElectrodeCaps_MNI/* $SIMNIBSDIR/resources/ElectrodeCaps_MNI/

# Additional steps for specific field-analysis directories
RUN execstack -s /ti-csc/analyzer/field-analysis/process_mesh_files && \
    execstack -s /ti-csc/optimizer/field-analysis/process_mesh_files

# Copy the entrypoint script and ensure correct permissions and line endings
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    dos2unix /usr/local/bin/entrypoint.sh

# Set working directory to TI-CSC
WORKDIR /ti-csc

# Install Bats (~1MB)
RUN git clone https://github.com/bats-core/bats-core.git /tmp/bats && \
    /tmp/bats/install.sh /usr/local && \
    rm -rf /tmp/bats

# Install pytest (~1MB)
RUN pip3 install pytest && \
    rm -rf /root/.cache/pip

# Prepare directories for testing
RUN mkdir -p /mnt/testing_project_dir/utils /mnt/testing_project_dir/Subjects /mnt/testing_project_dir/Simulations
COPY /ti-csc/utils/testing_data/utils/montage_list.json /mnt/testing_project_dir/utils
COPY /ti-csc/utils/testing_data/utils/roi_list.json /mnt/testing_project_dir/utils
COPY /ti-csc/utils/testing_data/utils/EGI_template.csv /mnt/testing_project_dir/Subjects/m2m_ernie/eeg_positions/

ENV LOCAL_PROJECT_DIR="mnt/testing_project_dir"
ENV PROJECT_DIR_NAME="testing_project_dir"

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
