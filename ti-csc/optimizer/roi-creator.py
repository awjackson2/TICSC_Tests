import os
import csv
import sys
import subprocess

'''
Ido Haber - ihaber@wisc.edu
October 16, 2024
Optimized for optimizer pipeline

This script manages the creation of Regions of Interest (ROIs) for simulations.
It lists existing ROIs along with their coordinates and allows users to add new ones,
with the option to visualize the subject's T1-weighted MRI in Freeview before specifying ROI coordinates.

Key Features:
- Lists existing ROIs and displays their coordinates.
- Option to add new ROIs.
- Prompts the user to open Freeview for visual aid when adding new ROIs.
- Saves ROI coordinates to a CSV file and maintains a list of all ROI files.
- Handles file permissions and directory creation as needed.
'''

def save_roi_to_csv(roi_name, coordinates, directory):
    if not os.path.exists(directory):
        os.makedirs(directory)
    file_path = os.path.join(directory, f"{roi_name}.csv")
    with open(file_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(coordinates)
    return file_path

def list_existing_rois(directory):
    existing_rois = []
    if os.path.exists(directory):
        for file_name in os.listdir(directory):
            if file_name.endswith('.csv'):
                existing_rois.append(file_name[:-4])
    return existing_rois

def read_roi_coordinates(roi_name, directory):
    file_path = os.path.join(directory, f"{roi_name}.csv")
    if os.path.exists(file_path):
        with open(file_path, mode='r') as file:
            reader = csv.reader(file)
            coordinates = next(reader)
            coordinates = [float(coord.strip()) for coord in coordinates]
            return coordinates
    return []

def call_view_nifti(roi_directory):
    # Assuming the script is in the same directory; adjust this path if needed
    view_nifti_script = os.path.join(os.getcwd(), "view-nifti.sh")

    # Ensure the script has execute permissions
    subprocess.run(['chmod', '+x', view_nifti_script])

    # Extract project directory and subject name
    subject_name = os.path.basename(os.path.dirname(roi_directory)).replace('m2m_', '')
    project_dir = os.path.dirname(os.path.dirname(roi_directory))
    
    subprocess.call([view_nifti_script, project_dir, subject_name])

def main():
    # Check if the ROI directory is passed as an argument
    if len(sys.argv) < 2:
        print("Error: ROI directory path is required as an argument.")
        sys.exit(1)

    roi_directory = sys.argv[1]

    # List existing ROIs
    existing_rois = list_existing_rois(roi_directory)

    if existing_rois:
        # Display existing ROIs and their coordinates
        print("Existing ROIs and their coordinates:")
        for idx, roi in enumerate(existing_rois, start=1):
            coordinates = read_roi_coordinates(roi, roi_directory)
            print(f"{idx}. {roi}: {coordinates}")
        print(" ")

    # Ask user if they want to add a new ROI
    add_new_roi = input("Do you want to add a new ROI? (yes/no): ").strip().lower()
    if add_new_roi not in ['yes', 'y']:
        print("No new ROI added. Exiting.")
        sys.exit(0)

    # User chooses to add a new ROI
    open_freeview = input("Do you want to open Freeview for visual reference? (yes/no): ").strip().lower()
    if open_freeview in ['yes', 'y']:
        call_view_nifti(roi_directory)
    roi_name = input("Name of new ROI: ")

    # Prompt user to enter coordinates
    while True:
        coords_input = input(f"Enter RAS coordinates for ROI '{roi_name}' (x y z): ")
        coords_input = coords_input.replace(',', ' ').split()
        if len(coords_input) != 3:
            print("Please enter exactly three values for x, y, and z.")
            continue
        try:
            coordinates = [float(coord.strip()) for coord in coords_input]
            break
        except ValueError:
            print("Invalid input. Please enter numeric values for coordinates.")

    # Save the ROI to a CSV file
    roi_file = save_roi_to_csv(roi_name, coordinates, roi_directory)

    # Append the new ROI file to roi_list.txt
    roi_list_path = os.path.join(roi_directory, 'roi_list.txt')
    with open(roi_list_path, 'a') as file:
        file.write(f"{roi_file}\n")

    print(f"ROI '{roi_name}' has been saved in the '{roi_directory}' directory.")

if __name__ == "__main__":
    main()

