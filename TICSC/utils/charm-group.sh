#!/bin/bash

##############
# By Ido Haber / ihaber@wisc.edu
# October 25, 2024
# For STRENGTHEN project
##############

# Define the main directory path where m2m_subjectID will be created.
subjects_dir="/mnt/${PROJECT_DIR_NAME}/Subjects"

# Define the MRIs parent directory 
niftis_dir="/mnt/$PROJECT_DIR_NAME/MRIs"

echo $subjects_dir
echo $niftis_dir

# Change to the main directory
cd "$subjects_dir"

# Loop over each subject directory in $niftis_dir
for subdir in "$niftis_dir"/*/; do
    # Extract the subject ID from the directory name (last three characters)
    x=$(basename "$subdir")

    # Define the paths for y and z (drop z if you are only using T1)
    y="${niftis_dir}/${x}/sub-${x}_ses-base_acq-MPRAGE_T1w.nii.gz"
    z="${niftis_dir}/${x}/sub-${x}_ses-base_acq-CUBE_T2w.nii.gz"
    
    echo "Subject ID: $x"
    echo "T1 Image: $y"
    echo "T2 Image: $z"

    # Run the command
    # qform is a rigid body transformation while sform is another option performing affine transformation.
    charm "$x" "$y" "$z" --forceqform
done

