# Base image: Ubuntu 20.04
FROM ubuntu:20.04

# Set noninteractive mode to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3.8 python3.8-venv python3.8-dev \
    wget git unzip curl jq tree locales imagemagick \
    build-essential cmake ninja-build \
    libglib2.0-0 libssl1.1 libopenblas-dev \
    libgl1-mesa-glx libglu1-mesa libosmesa6 mesa-utils \
    libqt5widgets5 libqt5gui5 libqt5core5a libqt5svg5 libqt5opengl5 \
    libreoffice bc dc \
    execstack dos2unix\ 
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# Set language environment
ENV LANG="en_GB.UTF-8"

# Install FSL
ENV FSLDIR="/usr/local/fsl"
RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py && \
    python3 ./fslinstaller.py -d /usr/local/fsl --debug && \
    rm -f fslinstaller.py

# Install required Python packages
RUN pip3 install --no-cache-dir dcm2niix numpy scipy pandas meshio nibabel pytest

# Install SimNIBS (~4.4GB)
RUN mkdir -p /simnibs && \
    wget https://github.com/simnibs/simnibs/releases/download/v4.1.0/simnibs_installer_linux.tar.gz -P /simnibs && \
    tar -xzf /simnibs/simnibs_installer_linux.tar.gz -C /simnibs && \
    /simnibs/simnibs_installer/install -s && \
    rm -rf /simnibs/simnibs_installer /simnibs/simnibs_installer_linux.tar.gz

# Set environment variables for SimNIBS
ENV PATH="/root/SimNIBS-4.1/bin:$PATH"
ENV SIMNIBSDIR="/root/SimNIBS-4.1"

# Install MATLAB Runtime (~3.8GB)
ENV MATLAB_RUNTIME_INSTALL_DIR="/usr/local/MATLAB/MATLAB_Runtime"
ENV LD_LIBRARY_PATH="${MATLAB_RUNTIME_INSTALL_DIR}/v99/runtime/glnxa64:${MATLAB_RUNTIME_INSTALL_DIR}/v99/bin/glnxa64:${MATLAB_RUNTIME_INSTALL_DIR}/v99/sys/os/glnxa64:${MATLAB_RUNTIME_INSTALL_DIR}/v99/sys/opengl/lib/glnxa64"

RUN wget https://ssd.mathworks.com/supportfiles/downloads/R2024a/Release/1/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip -P /tmp && \
    unzip -q /tmp/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip -d /tmp/matlab_runtime_installer && \
    /tmp/matlab_runtime_installer/install -destinationFolder ${MATLAB_RUNTIME_INSTALL_DIR} -agreeToLicense yes -mode silent && \
    rm -rf /tmp/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip /tmp/matlab_runtime_installer

# Copy the TI-CSC repository
COPY . /ti-csc

# Set up SimNIBS resources
RUN mkdir -p $SIMNIBSDIR/resources/ElectrodeCaps_MNI/ && \
    cp /ti-csc/assets/ElectrodeCaps_MNI/* $SIMNIBSDIR/resources/ElectrodeCaps_MNI/

# Adjust permissions for necessary executables
RUN execstack -s /ti-csc/analyzer/field-analysis/process_mesh_files && \
    execstack -s /ti-csc/optimizer/field-analysis/process_mesh_files

# Copy entrypoint script and ensure proper permissions
COPY ./utils/test/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && dos2unix /usr/local/bin/entrypoint.sh

# Set working directory
WORKDIR /ti-csc

# Install Bats for shell testing (~1MB)
RUN git clone https://github.com/bats-core/bats-core.git /tmp/bats && \
    /tmp/bats/install.sh /usr/local && \
    rm -rf /tmp/bats

# Prepare directories for testing
RUN mkdir -p /mnt/testing_project_dir/utils /mnt/testing_project_dir/Subjects /mnt/testing_project_dir/Simulations && \
    curl -L https://github.com/simnibs/example-dataset/releases/latest/download/simnibs4_examples.zip -o /mnt/testing_project_dir/Subjects/simnibs4_examples.zip && \
    unzip -q /mnt/testing_project_dir/Subjects/simnibs4_examples.zip -d /mnt/testing_project_dir/Subjects || echo "Zip file missing or download failed" && \
    rm -f /mnt/testing_project_dir/Subjects/simnibs4_examples.zip && \
    dos2unix /ti-csc/analyzer/*.sh /ti-csc/analyzer/field-analysis/*.sh /ti-csc/utils/test/integration/*.sh

# Copy testing data
COPY /utils/test/data/montage_list.json /mnt/testing_project_dir/utils
COPY /utils/test/data/roi_list.json /mnt/testing_project_dir/utils
COPY /utils/test/data/EGI_template.csv /mnt/testing_project_dir/Subjects/m2m_ernie/eeg_positions/

# Set environment variables for project directories
ENV LOCAL_PROJECT_DIR="/mnt/testing_project_dir"
ENV PROJECT_DIR_NAME="testing_project_dir"

# Set the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
