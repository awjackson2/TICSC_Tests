#!/usr/bin/env python3

import argparse
import csv
import glob
import os

'''
Ido Haber - ihaber@wisc.edu
September 4, 2024

Script that helps you convert digitized EEG net from a .csv to .geo
.geo is compatible with Gmsh which will be able to visualize 
EEG net + head model


'''



def format_electrode_data(input_path, output_path):
    with open(input_path, "r", encoding="utf-8") as csvfile, open(
        output_path, "w", encoding="utf-8"
    ) as outputfile:
        csvreader = csv.reader(csvfile)
        # Skip the header
        next(csvreader)
        outputfile.write('View""{\n')

        for row in csvreader:
            # Assuming columns are in the order of electrode name, X, Y, Z
            # Adjust the indices if your CSV format is different
            if len(row) < 4:
                continue  # Skip rows that don't have enough data
            x, y, z, name = row[1], row[2], row[3], row[4]
            outputfile.write(f"SP({x}, {y}, {z}){{0}};\n")
            outputfile.write(f'T3({x}, {y}, {z}, 0){{"{name}"}};\n')

        outputfile.write(
            """};\n
myView = PostProcessing.NbViews-1;
View[myView].PointType=1;
View[myView].PointSize=6;
View[myView].LineType=1;
View[myView].LineWidth=2; """
        )


def process_directory(directory_path):
    csv_files = glob.glob(os.path.join(directory_path, "*.csv"))
    for input_path in csv_files:
        output_path = os.path.splitext(input_path)[0] + ".geo"
        format_electrode_data(input_path, output_path)
        print(f"Processed {input_path} -> {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Convert CSV files to GEO format for SimNIBS."
    )
    parser.add_argument(
        "directory",
        type=str,
        nargs="?",
        default=".",
        help="Directory containing the CSV files",
    )

    args = parser.parse_args()

    if os.path.isdir(args.directory):
        process_directory(args.directory)
    else:
        print("The provided directory does not exist or is not a directory.")


if __name__ == "__main__":
    main()
