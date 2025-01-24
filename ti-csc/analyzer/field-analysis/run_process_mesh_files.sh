#!/bin/bash
###############################################################################
# A script to set up MATLAB Runtime environment, debug library paths,
# and execute a compiled MATLAB application (process_mesh_files).
###############################################################################

# Bash options for debugging & robustness
# -e: Exit on any non-zero command
# -u: Treat unset variables as errors
# -x: Print each command before running it
# -o pipefail: Fail a pipeline if any subcommand fails
set -euxo pipefail

###############################################################################
# Function: find_matlab_runtime
#
# Searches for a valid MATLAB Runtime installation path and ECHOs ONLY that path.
# Debug messages are printed (>&2), so they don't get captured in the echo output.
###############################################################################
find_matlab_runtime() {
    local potential_paths=(
        "/usr/local/MATLAB/MATLAB_Runtime/R2024a"
        "/usr/local/MATLAB/MATLAB_Runtime/v951"
        "/opt/MATLAB/MATLAB_Runtime/R2024a"
        "$HOME/MATLAB_Runtime/R2024a"   # Replaces /home/$USER/...
    )

    echo "[DEBUG] Searching for MATLAB Runtime in potential paths:" >&2
    for path in "${potential_paths[@]}"; do
        echo "    $path" >&2
        if [ -d "$path" ]; then
            echo "[DEBUG] Found MATLAB Runtime at: $path" >&2
            # The echo here must ONLY output the actual path
            echo "$path"
            return 0
        fi
    done

    echo "[ERROR] MATLAB Runtime not found in known locations." >&2
    exit 1
}

###############################################################################
# MAIN
###############################################################################
exe_name="$0"
exe_dir=$(cd "$(dirname "$0")" && pwd)  # Absolute path of script directory

echo "============================================================================="
echo "Script Name          : $exe_name"
echo "Script Directory     : $exe_dir"
echo "Executing as User    : $(whoami)"
echo "Current Working Dir  : $(pwd)"
echo "============================================================================="

echo "[DEBUG] Finding MATLAB Runtime..."
# Store only the real path in MCROOT (no extra debug strings!)
MCROOT="$(find_matlab_runtime)"

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
# Use '|| true' so if 'ls' fails we don't exit immediately.
ls -lah "${MCROOT}/runtime/glnxa64" || true

echo "[DEBUG] Checking if the symbolic link for libmwmclmcrrt.so.25.1 is needed..."
if [ ! -f "${MCROOT}/runtime/glnxa64/libmwmclmcrrt.so.25.1" ]; then
    echo "[WARNING] libmwmclmcrrt.so.25.1 not found. Attempting to create a symlink to libmwmclmcrrt.so.24.1"
    if [ -f "${MCROOT}/runtime/glnxa64/libmwmclmcrrt.so.24.1" ]; then
        ln -s "${MCROOT}/runtime/glnxa64/libmwmclmcrrt.so.24.1" \
               "${MCROOT}/runtime/glnxa64/libmwmclmcrrt.so.25.1"
        echo "[DEBUG] Symlink created: libmwmclmcrrt.so.25.1 -> libmwmclmcrrt.so.24.1"
    else
        echo "[WARNING] libmwmclmcrrt.so.24.1 not found; skipping symlink creation. Continuing anyway..."
    fi
else
    echo "[DEBUG] libmwmclmcrrt.so.25.1 already exists; no symlink needed."
fi

echo "--------------------------------------"

# The first argument is the mesh directory
mesh_dir="${1:-}"
if [ -z "$mesh_dir" ]; then
    echo "[ERROR] No mesh directory argument provided. Usage: run_process_mesh_files.sh <mesh_dir>"
    exit 1
fi

echo "Mesh directory: $mesh_dir"
echo "--------------------------------------"

# Execute the MATLAB compiled script with the provided argument
# Make sure 'process_mesh_files' is in the same directory as $exe_dir or in PATH
echo "[DEBUG] Invoking process_mesh_files with: $mesh_dir"
eval "\"${exe_dir}/process_mesh_files\" \"$mesh_dir\""

echo "[DEBUG] process_mesh_files invocation completed successfully."
exit 0
