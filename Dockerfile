# Start from an official Ubuntu image
FROM ubuntu:20.04

# Set working directory inside the container
WORKDIR /

# Set non-interactive mode for package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary system packages
RUN apt-get update && apt-get install -y \
    python \
    file \
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
    libgl1-mesa-glx \
    libxt6 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Make the ti-csc directory in docker
RUN mkdir /ti-csc

# Copy ti-csc
COPY ../ti-csc ti-csc

# Install SimNIBS
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

# Additional steps to run execstack on process_mesh_files in specific field-analysis directories
RUN execstack -s /ti-csc/analyzer/field-analysis/process_mesh_files \
    && execstack -s /ti-csc/optimizer/field-analysis/process_mesh_files

# Set environment variables for SimNIBS
ENV PATH="/root/SimNIBS-4.1/bin:$PATH"
ENV SIMNIBSDIR="/root/SimNIBS-4.1"

# Install Miniconda (if Conda is not already installed)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda init
ENV PATH="/opt/conda/bin:$PATH"

# Install FSL with Conda
RUN conda create -y \
    -c https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/public/ \
    -c conda-forge \
    -n fsl-env fsl-avwutils

# Configure Conda environment and FSL
RUN echo "source activate fsl-env" >> ~/.bashrc && \
    echo 'export FSLDIR="/opt/conda/envs/fsl-env"' >> ~/.bashrc && \
    echo "source /opt/conda/envs/fsl-env/etc/fslconf/fsl.sh" >> ~/.bashrc

# Make sure Conda is activated for any subsequent shell sessions
ENV PATH="/opt/conda/envs/fsl-env/bin:$PATH"

# Prepare directories for testing
RUN mkdir -p /mnt/testing_project_dir/utils /mnt/testing_project_dir/Subjects /mnt/testing_project_dir/Simulations
COPY ti-csc/utils/testing_data/utils/montage_list.json /mnt/testing_project_dir/utils
COPY ti-csc/utils/testing_data/utils/roi_list.json /mnt/testing_project_dir/utils
COPY ti-csc/utils/testing_data/utils/EGI_template.csv /mnt/testing_project_dir/Subjects/m2m_ernie/eeg_positions/

# Download and unzip example dataset
RUN curl -L https://github.com/simnibs/example-dataset/releases/latest/download/simnibs4_examples.zip -o /mnt/testing_project_dir/Subjects/simnibs4_examples.zip && \
    unzip -q /mnt/testing_project_dir/Subjects/simnibs4_examples.zip -d /mnt/testing_project_dir/Subjects || echo "Zip file missing or download failed"

# Set PYTHONPATH for the project
ENV PYTHONPATH=/ti-csc:$PYTHONPATH
ENV PROJECT_DIR_NAME="testing_project_dir"

# Fix line endings for shell scripts
RUN [ -d /ti-csc/analyzer ] && find /ti-csc/analyzer -type f -name "*.sh" -exec dos2unix {} + || echo "/ti-csc/analyzer does not exist"

# Default command to run pytest for testing
# CMD ["pytest", "--maxfail=3", "--disable-warnings", "/ti-csc/tests"]
