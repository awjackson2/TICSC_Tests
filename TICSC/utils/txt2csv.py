import csv
import sys

''' 
Ido Haber - ihaber@wisc.edu
September 4, 2024

This script takes digitized sensor data from Brainstorm 
and transofrm it to a .csv SimNIBS appropriate format.

Input should be "EEG/Brainsight .txt format from Brainstorm export"

'''


def process_file(input_file, output_file):
    try:
        with open(input_file, 'r', encoding='utf-8') as infile, open(output_file, 'w', newline='', encoding='utf-8') as outfile:
            reader = csv.reader(infile, delimiter='\t')
            writer = csv.writer(outfile)

            # Write the header
            #writer.writerow(['Electrode', 'Loc. X', 'Loc. Y', 'Loc. Z', 'Sample Name'])

            # Skip the header and notes in the input file
            for _ in range(7):
                next(reader)

            # Process each line in the input file
            for row in reader:
                if row:  # ensuring the row is not empty
                    sample_name = row[0]
                    loc_x = row[2]
                    loc_y = row[3]
                    loc_z = row[4]
                    writer.writerow(['Electrode', loc_x, loc_y, loc_z, sample_name])

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 bs2sn.py input.txt output.csv")
    else:
        input_path = sys.argv[1]
        output_path = sys.argv[2]
        process_file(input_path, output_path)
        print(f"File processed successfully: {output_path}")
