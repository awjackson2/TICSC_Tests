#!/bin/bash
# Exit immediately if a command exits with a non-zero status

set -e

export LD_LIBRARY_PATH="${MATLAB_RUNTIME_INSTALL_DIR}/R2024a/runtime/glnxa64/:${MATLAB_RUNTIME_INSTALL_DIR}/R2024a/runtime/glnxa64/lib/:${MATLAB_RUNTIME_INSTALL_DIR}/R2024a/bin/glnxa64/:${MATLAB_RUNTIME_INSTALL_DIR}/R2024a/sys/os/glnxa64/:${MATLAB_RUNTIME_INSTALL_DIR}/R2024a/sys/java/jre/glnxa64/jre/lib/amd64:$LD_LIBRARY_PATH"

# Navigate to the required directory
cd /ti-csc/analyzer || { echo "Directory /ti-csc/analyzer does not exist"; exit 1; }

# Run the script with the required inputs
{
    echo "2"    # Choose subject "ernie"
    echo "1"    # Isotropic simulation
    echo "U"    # Unipolar simulation
    echo "1"    # Little_Pairs montage
    echo "1"    # Anterior ROI
} | bash start-ana.sh

# Define the base directory for expected files
EXPECTED_DIR="/mnt/testing_project_dir/Simulations/sim_ernie"

# Define the expected files
EXPECTED_FILES=(
    # FEM files - TI_Little_Pairs
    "FEM/TI_Little_Pairs/TI.msh.opt"
    "FEM/TI_Little_Pairs/ernie_TDCS_1_el_currents.geo"
    "FEM/TI_Little_Pairs/ernie_TDCS_1_scalar.msh"
    "FEM/TI_Little_Pairs/ernie_TDCS_1_scalar.msh.opt"
    "FEM/TI_Little_Pairs/ernie_TDCS_2_el_currents.geo"
    "FEM/TI_Little_Pairs/ernie_TDCS_2_scalar.msh"
    "FEM/TI_Little_Pairs/ernie_TDCS_2_scalar.msh.opt"
    "FEM/TI_Little_Pairs/fields_summary.txt"
    # ROI_analysis files
    "ROI_analysis/mean_max_values.txt"
    # Whole-Brain-mesh files
    "Whole-Brain-mesh/ernie_TI_Little_Pairs_TI.msh"
    "Whole-Brain-mesh/results/ernie_TI_Little_Pairs_TI_histogram.png"
    "Whole-Brain-mesh/results/ernie_TI_Little_Pairs_TI_peaks_focality.mat"
    "Whole-Brain-mesh/results/ernie_TI_Little_Pairs_TI_surface.png"
    "Whole-Brain-mesh/results/summary.txt"
    # montage_imgs files
    "montage_imgs/Little_Pairs_highlighted_visualization.png"
    # niftis files
    "niftis/Anterior-sphere.nii.gz"
    "niftis/grey_ernie_TI_Little_Pairs_TI_output_MNI_TI_max.nii"
    "niftis/white_ernie_TI_Little_Pairs_TI_output_MNI_TI_max.nii"
    # parcellated_mesh files
    "parcellated_mesh/grey_ernie_TI_Little_Pairs_TI.msh"
    "parcellated_mesh/white_ernie_TI_Little_Pairs_TI.msh"
)

# Define wildcard files to search
WILDCARD_FILES=(
    "FEM/TI_Little_Pairs/*.log"
    "FEM/TI_Little_Pairs/*.mat"
)

# Verify files
echo "Verifying output files..."
for file in "${EXPECTED_FILES[@]}"; do
    if [[ ! -f "${EXPECTED_DIR}/${file}" ]]; then
        echo "Error: Expected file ${EXPECTED_DIR}/${file} was not created."
        exit 1
    else
        echo "Found: ${EXPECTED_DIR}/${file}"
    fi
done

# Verify wildcard files
echo "Checking for wildcard files..."
for wildcard in "${WILDCARD_FILES[@]}"; do
    found_files=$(find "${EXPECTED_DIR}/${wildcard%/*}" -name "${wildcard##*/}")
    if [[ -z "$found_files" ]]; then
        echo "Error: No files found matching ${EXPECTED_DIR}/${wildcard}"
        exit 1
    else
        echo "Found files matching ${EXPECTED_DIR}/${wildcard}:"
        echo "$found_files"
    fi
done

echo "All expected files are present."
