#!/bin/bash
###############################################################################
# A script to set up MATLAB Runtime environment, debug library paths, and
# execute a compiled MATLAB application (process_mesh_files).
###############################################################################

# Immediately exit on error (-e), print each command before execution (-x),
# fail if any command in a pipeline fails (-o pipefail), and treat unset 
# variables as errors (-u).
set -euxo pipefail

###############################################################################
# Function: find_matlab_runtime
# Searches for a valid MATLAB Runtime installation path.
###############################################################################
find_matlab_runtime() {
    local potential_paths=(
        "/usr/local/MATLAB/MATLAB_Runtime/R2024a"
        "/usr/local/MATLAB/MATLAB_Runtime/v951"
        "/opt/MATLAB/MATLAB_Runtime/R2024a"
        "/home/$USER/MATLAB_Runtime/R2024a"
    )

    echo "[DEBUG] Searching for MATLAB Runtime in potential paths:"
    for path in "${potential_paths[@]}"; do
        echo "    $path"
        if [ -d "$path" ]; then
            echo "[DEBUG] Found MATLAB Runtime at: $path"
            echo "$path"
            return 0
        fi
    done

    echo "[ERROR] MATLAB Runtime not found. Please install it or update the script with the correct path."
    exit 1
}

###############################################################################
# Main script logic
###############################################################################
exe_name="$0"
exe_dir=$(cd "$(dirname "$0")" && pwd) # Absolute path of this script's directory

echo "============================================================================="
echo "Script Name          : $exe_name"
echo "Script Directory     : $exe_dir"
echo "Executing as User    : $(whoami)"
echo "Current Working Dir  : $(pwd)"
echo "============================================================================="

echo "[DEBUG] Finding MATLAB Runtime..."
MCROOT=$(find_matlab_runtime)

echo "--------------------------------------"
echo "Setting up environment variables"
echo "MATLAB Runtime root: ${MCROOT}"
echo "--------------------------------------"

# Construct LD_LIBRARY_PATH
LD_LIBRARY_PATH=".:${MCROOT}/runtime/glnxa64"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${MCROOT}/bin/glnxa64"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${MCROOT}/sys/os/glnxa64"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${MCROOT}/sys/java/jre/glnxa64/jre/lib/amd64"
export LD_LIBRARY_PATH

echo "[DEBUG] LD_LIBRARY_PATH is ${LD_LIBRARY_PATH}"
echo "--------------------------------------"

# Validate library presence by listing them
echo "[DEBUG] Listing MATLAB Runtime libraries in: ${MCROOT}/runtime/glnxa64"
ls -lah "${MCROOT}/runtime/glnxa64" || true

echo "[DEBUG] Checking if the symbolic link for libmwmclmcrrt.so.25.1 is needed..."
if [ ! -f "${MCROOT}/runtime/glnxa64/libmwmclmcrrt.so.25.1" ]; then
    echo "[WARNING] libmwmclmcrrt.so.25.1 not found. Attempting to create a symlink to libmwmclmcrrt.so.24.1"
    # Only create symlink if .24.1 exists:
    if [ -f "${MCROOT}/runtime/glnxa64/libmwmclmcrrt.so.24.1" ]; then
        ln -s "${MCROOT}/runtime/glnxa64/libmwmclmcrrt.so.24.1" \
               "${MCROOT}/runtime/glnxa64/libmwmclmcrrt.so.25.1"
        echo "[DEBUG] Created symlink libmwmclmcrrt.so.25.1 -> libmwmclmcrrt.so.24.1"
    else
        echo "[ERROR] libmwmclmcrrt.so.24.1 not found; cannot create symlink for .25.1!"
        exit 1
    fi
fi

echo "--------------------------------------"
mesh_dir="$1"
echo "[DEBUG] Mesh directory argument: $mesh_dir"

# Validate existence of $mesh_dir
if [ -z "$mesh_dir" ]; then
    echo "[ERROR] No mesh directory specified! Usage: $0 <mesh_directory>"
    exit 1
fi
if [ ! -d "$mesh_dir" ]; then
    echo "[ERROR] Specified mesh directory does not exist: $mesh_dir"
    exit 1
fi

echo "--------------------------------------"
echo "[DEBUG] Verifying the compiled MATLAB executable and its linked libraries"
# Use 'ldd' to ensure dynamic libraries are resolved
echo "Running: ldd \"${exe_dir}/process_mesh_files\""
ldd "${exe_dir}/process_mesh_files" || true
echo "--------------------------------------"

echo "[DEBUG] Checking file permissions on the compiled MATLAB script:"
ls -l "${exe_dir}/process_mesh_files"

echo "--------------------------------------"
echo "[DEBUG] Final environment before execution:"
env | sort
echo "--------------------------------------"

echo "[DEBUG] Now invoking process_mesh_files with the specified mesh directory..."
eval "\"${exe_dir}/process_mesh_files\"" "$mesh_dir"

echo "[INFO] Script finished successfully."
exit 0
