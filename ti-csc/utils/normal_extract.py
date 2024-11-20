
import meshio
import nibabel as nib
import numpy as np
from scipy import ndimage
import os


'''
Ido Haber - ihaber@wisc.edu
September 2, 2024
Optimized for optimizer pipeline

This script converts the normal component of a TI field from a surface mesh 
(.msh file) into a volumetric NIfTI file. The process involves mapping the 
surface normals to the closest voxel in a reference NIfTI volume, creating a 
3D representation of the normal component aligned with the original T1 scan.

Key Features:
- Transforms mesh coordinates to voxel space.
- Maps the TIamp_localnorm field to the corresponding voxel.
- Outputs the result as a NIfTI file for further analysis or visualization.
'''

def main(surface_msh_file, reference_nifti_file, output_nifti_file):
    # Check if the .msh file exists
    if not os.path.exists(surface_msh_file):
        raise FileNotFoundError(f"File {surface_msh_file} not found.")
    
    # Check if the reference NIfTI file exists
    if not os.path.exists(reference_nifti_file):
        raise FileNotFoundError(f"File {reference_nifti_file} not found.")
    
    # Step 1: Load the surface mesh
    mesh = meshio.read(surface_msh_file)
    
    # Extract the specific field
    if "TIamp_localnorm" not in mesh.point_data:
        raise ValueError("Field 'TIamp_localnorm' not found in the mesh file.")
    
    normals = mesh.point_data["TIamp_localnorm"]

    # Step 2: Load the reference NIfTI file
    ref_nifti = nib.load(reference_nifti_file)
    affine = ref_nifti.affine
    volume_shape = ref_nifti.shape
    
    # Step 3: Transform the surface coordinates to voxel space
    voxel_coords = nib.affines.apply_affine(np.linalg.inv(affine), mesh.points)
    
    # Initialize an empty volume for the normal component
    normal_volume = np.zeros(volume_shape)
    
    # Step 4: Map the normals to the closest voxel
    for coord, normal in zip(voxel_coords, normals):
        x, y, z = np.round(coord).astype(int)
        
        # Ensure that the coordinates are within bounds
        if 0 <= x < volume_shape[0] and 0 <= y < volume_shape[1] and 0 <= z < volume_shape[2]:
            normal_volume[x, y, z] = normal  # Or assign normal as needed
    
    # Step 5: Save the resulting volume as a NIfTI file
    new_nifti = nib.Nifti1Image(normal_volume, affine)
    nib.save(new_nifti, output_nifti_file)
    print(f"Normal component volume saved to {output_nifti_file}")

if __name__ == "__main__":
    # Example usage
    surface_msh_file = "Simulations/TI_norm_field_E003_E004_and_E005_E006.msh"
    reference_nifti_file = "m2m_RS/T1.nii.gz"
    output_nifti_file = "normal_component_volume.nii"

    main(surface_msh_file, reference_nifti_file, output_nifti_file)

