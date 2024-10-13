#!/bin/bash

# Input file
input_file="packages.txt"

# Output files
supported_file="supported.txt"
not_supported_file="not_supported.txt"

# Clear previous content in the output files (if any)
> "$supported_file"
> "$not_supported_file"

# Read the input file line by line
while IFS= read -r line
do
  # Check if the line starts with '#' (not supported)
  if [[ $line == \#* ]]; then
    echo "$line" >> "$not_supported_file"
  else
    echo "$line" >> "$supported_file"
  fi
done < "$input_file"

echo "Packages have been separated into $supported_file and $not_supported_file."
