# Dockerfile.simnibs
FROM ubuntu:20.04

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python file pulseaudio libquadmath0 libxft2 firefox libgomp1 \
    wget git unzip python3.8 python3-pip libglib2.0-0 libssl1.1 \
    libopenblas-dev build-essential tar bzip2 gcc g++ cmake libtool \
    libtool-bin autoconf automake pkg-config gettext ninja-build \
    python3.8-venv python3.8-dev libgl1-mesa-glx libglu1-mesa \
    mesa-utils libgl1-mesa-dri libglapi-mesa libosmesa6 libxt6 \
    libxext6 libxrender1 libxrandr2 libxfixes3 libxcursor1 \
    libxcomposite1 libxdamage1 libxi6 libqt5widgets5 libqt5gui5 \
    libqt5core5a libqt5svg5 libqt5opengl5 libgtk2.0-0 libreoffice \
    nodejs npm jq bc dc tcsh tree locales execstack imagemagick \
    curl dos2unix python3 \
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

# Set MATLAB Runtime version and installation directory
ENV MATLAB_RUNTIME_INSTALL_DIR="/usr/local/MATLAB/MATLAB_Runtime"

# Set LD_LIBRARY_PATH for MATLAB Runtime
ENV LD_LIBRARY_PATH="${MATLAB_RUNTIME_INSTALL_DIR}/v99/runtime/glnxa64:${MATLAB_RUNTIME_INSTALL_DIR}/v99/bin/glnxa64:${MATLAB_RUNTIME_INSTALL_DIR}/v99/sys/os/glnxa64:${MATLAB_RUNTIME_INSTALL_DIR}/v99/sys/opengl/lib/glnxa64"

# Download and install MATLAB Runtime R2024a (~3.8GB)
RUN wget https://ssd.mathworks.com/supportfiles/downloads/R2024a/Release/1/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip -P /tmp && \
    unzip -q /tmp/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip -d /tmp/matlab_runtime_installer && \
    /tmp/matlab_runtime_installer/install -destinationFolder ${MATLAB_RUNTIME_INSTALL_DIR} -agreeToLicense yes -mode silent && \
    rm -rf /tmp/MATLAB_Runtime_R2024a_Update_1_glnxa64.zip /tmp/matlab_runtime_installer

# Set working directory
WORKDIR /ti-csc
#
# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
