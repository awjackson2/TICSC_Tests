#!/bin/bash

#########################################
# Ido Haber - ihaber@wisc.edu
# September 2, 2024
#
# This is the main script for the optimizer tool, which collects input from 
# the user and orchestrates the execution of all necessary scripts and executables 
# in the pipeline. It handles ROI creation, leadfield matrix generation, 
# TI optimization, mesh processing, and output file updates.
#########################################

set -e  # Exit immediately if a command exits with a non-zero status

project_dir="/mnt/$PROJECT_DIR_NAME"
subject_dir="$project_dir/Subjects"

# Function to list available subjects
list_subjects() {
    subjects=()
    i=1
    for subject_path in "$subject_dir"/m2m_*; do
        if [ -d "$subject_path" ]; then
            subject_id=$(basename "$subject_path" | sed 's/m2m_//')
            subjects+=("$subject_id")
            echo "$i. $subject_id"
            ((i++))
        fi
    done
}

echo "Choose subjects:"
list_subjects

read -p "Enter the numbers of the subjects to analyze (comma-separated): " subject_choices
IFS=',' read -r -a selected_subjects <<< "$subject_choices"

# Get the current script directory
script_dir=$(pwd)

# Loop through selected subjects and run the pipeline
for subject_index in "${selected_subjects[@]}"; do
    subject_name="${subjects[$((subject_index-1))]}"
    roi_dir="$subject_dir/m2m_$subject_name/ROIs"

    # Call the ROI creator script to handle ROI creation or selection
    echo "Running roi-creator.py for subject $subject_name..."
    python3 roi-creator.py "$roi_dir"

    # Check if the ROI creation was successful
    if [ $? -eq 0 ]; then
        echo "ROI creation completed successfully for subject $subject_name."
    else
        echo "ROI creation failed for subject $subject_name. Exiting."
        exit 1
    fi

    # Define leadfield directories
    leadfield_vol_dir="$subject_dir/leadfield_vol_$subject_name"
    leadfield_gm_dir="$subject_dir/leadfield_gm_$subject_name"

    # Check if both leadfield directories exist
    if [ ! -d "$leadfield_vol_dir" ] || [ ! -d "$leadfield_gm_dir" ]; then
        echo "Missing Leadfield matrices for subject $subject_name. Do you wish to create them? It will take some time."
        read -p "Enter Y to create the leadfield matrices or N to exit: " create_leadfield
        if [ "$create_leadfield" = "Y" ] || [ "$create_leadfield" = "y" ]; then
            echo "Running leadfield.py for subject $subject_name..."
            simnibs_python leadfield.py "$subject_dir/m2m_$subject_name" "EGI_template.csv"
        else
            echo "Skipping leadfield creation. Exiting."
            exit 1
        fi
    else
        echo "Leadfield directories already exist for subject $subject_name. Skipping leadfield.py."
    fi

    # Set the leadfield_hdf path
    leadfield_hdf="$project_dir/Subjects/leadfield_$subject_name/${subject_name}_leadfield_EGI_template.hdf5"
    export LEADFIELD_HDF=$leadfield_hdf
    export PROJECT_DIR=$project_dir
    export SUBJECT_NAME=$subject_name

    # Call the TI optimizer script
    echo "Running TImax_optimizer.py for subject $subject_name..."
    simnibs_python ti_sim.py

    # Check if the TI optimization was successful
    if [ $? -eq 0 ]; then
        echo "TI optimization completed successfully for subject $subject_name."
    else
        echo "TI optimization failed for subject $subject_name. Exiting."
        exit 1
    fi

    # Call the sur2vol.py script to convert surface fields to volumetric NIfTI
    echo "Running sur2vol.py for subject $subject_name..."
    python3 sur2vol.py

    # Check if the sur2vol.py execution was successful
    if [ $? -eq 0 ]; then
        echo "Volumetric conversion completed successfully for subject $subject_name."
    else
        echo "Volumetric conversion failed for subject $subject_name. Exiting."
        exit 1
    fi

    # Call the nii2msh_conversion.sh script for NIfTI to mesh conversion
    echo "Running nii2msh_conversion.sh for subject $subject_name..."
    bash nii2msh_convert.sh "$project_dir" "$subject_name"

    # Check if the nii2msh_conversion.sh execution was successful
    if [ $? -eq 0 ]; then
        echo "NIfTI to mesh conversion completed successfully for subject $subject_name."
    else
        echo "NIfTI to mesh conversion failed for subject $subject_name. Exiting."
        exit 1
    fi

    # Call the ROI analyzer script
    echo "Running roi-analyzer.py for subject $subject_name..."
    python3 roi-analyzer.py "$roi_dir"

    # Check if the ROI analysis was successful
    if [ $? -eq 0 ]; then
        echo "ROI analysis completed successfully for subject $subject_name."
    else
        echo "ROI analysis failed for subject $subject_name. Exiting."
        exit 1
    fi

    # Define the mesh directory
    mesh_dir="$project_dir/Simulations/opt_$subject_name"

    # Run the process_mesh_files_new.sh script
    echo "Running process_mesh_files_new.sh for subject $subject_name..."
    ./field-analysis/run_process_mesh_files.sh "$mesh_dir"

    # Check if the mesh processing was successful
    if [ $? -eq 0 ]; then
        echo "Mesh processing completed successfully for subject $subject_name."
    else
        echo "Mesh processing failed for subject $subject_name. Exiting."
        exit 1
    fi

    # Run the Python script to update the output.csv file
    echo "Running update_output_csv.py for subject $subject_name..."
    python3 update_output_csv.py "$project_dir" "$subject_name"

    # Check if the Python script was successful
    if [ $? -eq 0 ]; then
        echo "Updated output.csv successfully for subject $subject_name."
    else
        echo "Failed to update output.csv for subject $subject_name. Exiting."
        exit 1
    fi
 
 # Run the mesh selector script
    bash mesh-selector.sh
done

echo "All tasks completed successfully for all selected subjects."

