from nilearn.image import new_img_like
import nibabel as nib
import numpy as np

'''
Ido Haber - ihaber@wisc.edu
September 4, 2024

For future feaute where we will be able to analyze field in patches of cortex instead of spheres. 
'''


# Path to the HCP atlas NIfTI file
hcp_atlas_path = 'MNI_Glasser_HCP_v1.0.nii.gz'

# Load the HCP atlas
hcp_atlas_img = nib.load(hcp_atlas_path)
hcp_atlas_data = hcp_atlas_img.get_fdata()

# Define the regions of interest with their labels
regions_of_interest = [
    14,   # L-RSC
    15,   # L-POS2

]

# Create a mask that only includes the regions of interest, preserving their original labels
combined_mask = np.zeros_like(hcp_atlas_data)

for region_label in regions_of_interest:
    combined_mask[hcp_atlas_data == region_label] = region_label

# Create a new NIfTI image for the combined mask using nilearn
combined_mask_img = new_img_like(hcp_atlas_img, combined_mask)

# Save the combined mask as a new NIfTI file
combined_mask_path = 'new.nii.gz'
combined_mask_img.to_filename(combined_mask_path)

print(f'New mask saved to {combined_mask_path}')
