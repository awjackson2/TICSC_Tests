
#!/bin/bash

##############################################
# Ido Haber - ihaber@wisc.edu
# September 2, 2024
# Optimized for TI-CSC toolbox
#
# This script helps create spherical regions of interest (ROIs) with a specified radius 
# as NIfTI files for visualization purposes. The spheres are based on voxel coordinates 
# from an input NIfTI volume. The script combines these spheres into a single ROI volume 
# for easier visualization and overlays it on the original volume using Freeview.
##############################################

# Directory setup
output_dir="../analyzer/base-niftis/"
mkdir -p $output_dir

# Volumes to process
volumes=(
   "../analyzer/base-niftis/MNI152_T1_1mm.nii.gz"
)

# Voxel coordinates to check
locations=(
  "95 73 127"
  "95 56 116"
  "95 79 89"
  "122 139 57"
)

# Location names
location_names=(
  "Anterior"
  "Posterior"
  "RSC"
  "LAA-IC"
)

# Radius for the spherical region (in voxels)
radius=3

# Initialize the combined ROI volume with zeros
combined_roi_file="${output_dir}/combined-spheres.nii.gz"
fslmaths ${volumes[0]} -mul 0 $combined_roi_file -odt float

# Create spherical ROIs and combine them into the combined ROI volume
for i in "${!locations[@]}"; do
  location="${locations[$i]}"
  location_name="${location_names[$i]}"

  IFS=' ' read -r vx vy vz <<< "$location"

  for volume in "${volumes[@]}"; do
    volume_file=$volume
    volume_name=$(basename $volume_file .nii)
    roi_file="${output_dir}/sphere_${volume_name}_${location_name}.nii.gz"

    # Create the spherical ROI
    fslmaths $volume_file -mul 0 -add 1 -roi $vx 1 $vy 1 $vz 1 0 1 temp_point -odt float
    fslmaths temp_point -kernel sphere $radius -dilM -bin $roi_file -odt float

    # Add the spherical ROI to the combined volume
    fslmaths $combined_roi_file -add $roi_file $combined_roi_file -odt float

    # Delete the temporary spherical ROI file
    rm -f $roi_file
  done
done

# Delete the temporary point file
rm -f temp_point.nii.gz

