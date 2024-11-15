#!/bin/bash

##############################################
# Ido Haber - ihaber@wisc.edu
# October 16, 2024
# Optimized for optimizer pipeline
#
# This script is designed to convert parcellated mesh files (e.g., GM and WM meshes) to NIfTI format 
# using a subject's T1-weighted MRI as a reference. It ensures the anatomical accuracy 
# of simulations by aligning the mesh with the subject's brain anatomy in MNI space.
#
# Key Features:
# - Converts parcellated mesh files to NIfTI format using the subject2mni tool.
# - Validates input directories and files to ensure smooth execution.
# - Automatically creates an output directory for the resulting NIfTI files.
# - Provides detailed error handling for common issues like missing files or directories.
##############################################

# Get the subject ID, subject directory, and simulation directory from the command-line arguments
subject_id="$1"
subject_dir="$2"
simulation_dir="$3"

# Define the directory containing .msh files
MESH_DIR="$simulation_dir/sim_${subject_id}/parcellated_mesh"
# Define the path to the reference directory
FN_REFERENCE="$subject_dir/m2m_${subject_id}"
# Define the output directory
OUTPUT_DIR="$simulation_dir/sim_${subject_id}/niftis"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if MESH_DIR exists and is a directory
if [ ! -d "$MESH_DIR" ]; then
  echo "Error: Directory $MESH_DIR does not exist."
  exit 1
fi

# Check if FN_REFERENCE exists and is a directory
if [ ! -d "$FN_REFERENCE" ]; then
  echo "Error: Reference directory $FN_REFERENCE does not exist."
  exit 1
fi

# Loop through all .msh files in the directory
for FN_MESH in "$MESH_DIR"/*.msh; do
  # Check if any .msh files are found
  if [ ! -f "$FN_MESH" ]; then
    echo "Error: No .msh files found in $MESH_DIR."
    exit 1
  fi
  
  # Get the base name of the .msh file (without directory and extension)
  BASE_NAME=$(basename "$FN_MESH" .msh)
  
  # Define the output file name
  FN_OUT="$OUTPUT_DIR/${BASE_NAME}_output.nii"
  
  # Run the subject2mni command
  subject2mni -i "$FN_MESH" -m "$FN_REFERENCE" -o "$FN_OUT"
  if [ $? -ne 0 ]; then
    echo "Error: subject2mni command failed for $FN_MESH."
    exit 1
  fi
done

echo "Processing complete!"

