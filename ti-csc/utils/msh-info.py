
#!/usr/bin/env python3


'''
Ido Haber - ihaber@wisc.edu
September 2, 2024

This script allows you to quickly inspect the fields available in a mesh file 
from the command line. It lists both point data fields and cell data fields 
contained within the mesh file, making it easier to understand the contents 
and structure of the mesh.
'''


import meshio
import sys

def list_fields(mesh_file):
    # Read the mesh file
    mesh = meshio.read(mesh_file)

    # List point data fields
    print("Point Data Fields:")
    for field in mesh.point_data.keys():
        print(f" - {field}")

    # List cell data fields
    print("\nCell Data Fields:")
    for field in mesh.cell_data_dict.keys():
        print(f" - {field}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # If a file path is provided as an argument, use it
        mesh_file = sys.argv[1]
    else:
        # Otherwise, prompt the user to input the file path
        mesh_file = input("Please enter the path to the mesh file: ")

    list_fields(mesh_file)
