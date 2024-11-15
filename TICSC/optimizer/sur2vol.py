
import os
import meshio
import nibabel as nib
import numpy as np

'''
Ido Haber - ihaber@wisc.edu
October 3, 2024
Optimized for optimizer pipeline

This script extracts the vector of the normal component of the TI field with 
respect to the middle layer of the cortex and maps it to the closest voxel in a NIfTI file, 
referencing the original T1 scan.

Key Features:
- Converts surface field data from a mesh file (.msh) into a volumetric NIfTI format.
- Uses the reference T1-weighted MRI scan to ensure proper spatial alignment.
- Processes all relevant mesh files in the directory and saves the results as NIfTI files.
'''

def create_volumetric_nifti(source_msh_file, reference_nifti_file, output_nifti_file, field_name):
    """Convert a surface field from a mesh to a volumetric NIfTI."""
    source_mesh = meshio.read(source_msh_file)
    
    if field_name not in source_mesh.point_data:
        raise ValueError(f"Field '{field_name}' not found in the source mesh.")
    
    surface_field_data = source_mesh.point_data[field_name]
    
    ref_nifti = nib.load(reference_nifti_file)
    affine = ref_nifti.affine
    volume_shape = ref_nifti.shape
    
    voxel_coords = nib.affines.apply_affine(np.linalg.inv(affine), source_mesh.points)
    
    volumetric_field = np.zeros(volume_shape)
    
    for coord, value in zip(voxel_coords, surface_field_data):
        x, y, z = np.round(coord).astype(int)
        if 0 <= x < volume_shape[0] and 0 <= y < volume_shape[1] and 0 <= z < volume_shape[2]:
            volumetric_field[x, y, z] = value
    
    new_nifti = nib.Nifti1Image(volumetric_field, affine)
    nib.save(new_nifti, output_nifti_file)
    print(f"Volumetric NIfTI saved to {output_nifti_file}")

def process_directory(project_dir, subject_name, field_name="TIamp_localnorm"):
    """Process all .msh files starting with 'TI_norm_field' and save NIfTI files in the output directory."""
    input_dir = os.path.join(project_dir, f"Simulations/opt_{subject_name}")
    reference_nifti_file = os.path.join(project_dir, f"Subjects/m2m_{subject_name}/T1.nii.gz")
    output_dir = os.path.join(project_dir, f"Simulations/opt_{subject_name}/niftis")
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Get the list of relevant .msh files
    msh_files = [f for f in os.listdir(input_dir) if f.startswith("TI_norm_field") and f.endswith(".msh")]
    total_files = len(msh_files)  # Total number of files to process
    
    # Process each .msh file and display progress
    for i, filename in enumerate(msh_files):
        source_msh_file = os.path.join(input_dir, filename)
        output_nifti_file = os.path.join(output_dir, f"{os.path.splitext(filename)[0]}_volumetric.nii.gz")
        
        # Progress indicator (formatted as 003/256)
        progress_str = f"{i+1:03}/{total_files}"
        print(f"{progress_str} Processing {filename}...")

        # Call the function to create a volumetric NIfTI file
        create_volumetric_nifti(source_msh_file, reference_nifti_file, output_nifti_file, field_name)

if __name__ == "__main__":
    # Get project directory and subject name from environment variables
    project_dir = os.getenv('PROJECT_DIR')
    subject_name = os.getenv('SUBJECT_NAME')

    # Process all relevant .msh files and convert them to NIfTI
    process_directory(project_dir, subject_name)

