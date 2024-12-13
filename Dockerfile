
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
    tcsh \
    tree \
    locales \
    fontconfig \
    execstack \
    imagemagick \
    curl \
    dos2unix \
    unzip \
    git \
    python3 \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV FSLDIR="/usr/local/fsl"
ENV DEBIAN_FRONTEND="noninteractive"
ENV LANG="en_GB.UTF-8"
    
# Install FSL (~)
RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py && \
    python ./fslinstaller.py -d /usr/local/fsl --debug \
    source $FSLDIR/etc/fslconf/fsl.sh

# Set up Python environment and install required Python packages
RUN pip3 install dcm2niix numpy scipy pandas meshio nibabel

# Install SimNIBS (~4.4GB)
RUN mkdir -p /simnibs && chmod -R 777 /simnibs
RUN wget https://github.com/simnibs/simnibs/releases/download/v4.1.0/simnibs_installer_linux.tar.gz -P /simnibs \
    && tar -xzf /simnibs/simnibs_installer_linux.tar.gz -C /simnibs \
    && /simnibs/simnibs_installer/install -s

# Set environment variables for SimNIBS
ENV PATH="/root/SimNIBS-4.1/bin:$PATH"
ENV SIMNIBSDIR="/root/SimNIBS-4.1"

# Set MATLAB Runtime version and installation directory
ENV MATLAB_RUNTIME_INSTALL_DIR="/usr/local/MATLAB/MATLAB_Runtime"

# Set LD_LIBRARY_PATH for MATLAB Runtime
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}\
${MATLAB_RUNTIME_INSTALL_DIR}/R2024b/runtime/glnxa64:\
${MATLAB_RUNTIME_INSTALL_DIR}/R2024b/bin/glnxa64:\
${MATLAB_RUNTIME_INSTALL_DIR}/R2024b/sys/os/glnxa64:\
${MATLAB_RUNTIME_INSTALL_DIR}/R2024b/extern/bin/glnxa64"



# Download and install MATLAB Runtime R2024a (~ 3.8GB)
RUN wget https://ssd.mathworks.com/supportfiles/downloads/R2024a/Release/1/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip -P /tmp \
    && unzip -q /tmp/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip -d /tmp/matlab_runtime_installer \
    && /tmp/matlab_runtime_installer/install -destinationFolder ${MATLAB_RUNTIME_INSTALL_DIR} -agreeToLicense yes -mode silent \
    && rm -rf /tmp/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip /tmp/matlab_runtime_installer

# Clone TI-CSC repository
# RUN git clone https://github.com/idossha/TI-CSC.git /ti-csc
# (~50MB)
COPY ./ti-csc ti-csc

# Create the target directory
RUN mkdir -p $SIMNIBSDIR/resources/ElectrodeCaps_MNI/

# Copy the ElectrodeCaps_MNI files
RUN cp /ti-csc/assets/ElectrodeCaps_MNI/* $SIMNIBSDIR/resources/ElectrodeCaps_MNI/

# Additional steps to run execstack on process_mesh_files in specific field-analysis directories
RUN execstack -s /ti-csc/analyzer/field-analysis/process_mesh_files \
    && execstack -s /ti-csc/optimizer/field-analysis/process_mesh_files

# Entry point script to ensure XDG_RUNTIME_DIR exists
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set working directory to TI-CSC
WORKDIR /ti-csc

# Install Bats (~1MB)
RUN git clone https://github.com/bats-core/bats-core.git /tmp/bats \
    && /tmp/bats/install.sh /usr/local \
    && rm -rf /tmp/bats

# Install pytest (~1MB)
RUN pip3 install pytest

# Prepare directories for testing
RUN mkdir -p /mnt/testing_project_dir /mnt/testing_project_dir/utils /mnt/testing_project_dir/Subjects /mnt/testing_project_dir/Simulations

# Copy test files
COPY ti-csc/utils/testing_data/utils/montage_list.json /mnt/testing_project_dir/utils
COPY ti-csc/utils/testing_data/utils/roi_list.json /mnt/testing_project_dir/utils
COPY ti-csc/utils/testing_data/utils/EGI_template.csv /mnt/testing_project_dir/Subjects/m2m_ernie/eeg_positions/

# Download and unzip example dataset (~1GB)
RUN curl -L https://github.com/simnibs/example-dataset/releases/latest/download/simnibs4_examples.zip -o /mnt/testing_project_dir/Subjects/simnibs4_examples.zip && \
    unzip -q /mnt/testing_project_dir/Subjects/simnibs4_examples.zip -d /mnt/testing_project_dir/Subjects || echo "Zip file missing or download failed"

RUN dos2unix /ti-csc/analyzer/*.sh /ti-csc/analyzer/field-analysis/*.sh /ti-csc/utils/tests/integration/*.sh

ENV LOCAL_PROJECT_DIR="mnt/testing_project_dir"
ENV PROJECT_DIR_NAME="testing_project_dir"

# Set the entrypoint and default command
#ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
#CMD ["/bin/bash"]