#!/bin/bash


WORKSPACE="${HOME}/workspace/AS-FAQ-PREVIEW"
D_WORKSPACE="${HOME}/workspace/AS-FAQ-Bot"

${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1mrlWPX_UOdCroV0ysoB2CPqYT_8EarcC/view?usp=drive_link AS-hro.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1zwPVWV9eyUwq9tGqgQIjTgOGx4LYnWO3/view?usp=drive_link AS-dgbas.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1tGm32hXB8kemCajZzWy1m9bN0WNbgXLa/view?usp=drive_link AS-ethics.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1DV2L_VvaTLV58t3ERc9MSZGsvIikNijn/view?usp=drive_link AS-art.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1pJtzFlc7BzlPck0VW2AkynFiWY-MiRi7/view?usp=drive_link AS-edoc.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1hhjRnXgQ6yRA-cAV874k5MUl7pHjDZfS/view?usp=drive_link AS-media.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1YkVqZAuutBhPcszQQIbAOGUMhlCOjb-Z/view?usp=drive_link AS-meeting.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1Kse2ypEzekNEoMKq5k-jLsyD-wbhhY6E/view?usp=drive_link AS-dia.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1lgTQlCakHE_5Zxc89_0AfIcsHAcaBVau/view?usp=drive_link AS-iptt.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1UB4kSMSac07uW4oI9LJouDFM3yKLW4sy/view?usp=drive_link AS-ITS.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1o1NcHhmfcRg-mAuamJfQxpgCywVFF0Cu/view?usp=drive_link AS-proposal.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/19CmiZGizwQYct6VH4ExfEJebQu6HvImY/view?usp=drive_link AS-proposal2.csv
${WORKSPACE}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1XRGHXwkJCuimz5ynGlmxo7DgPaCYmKae/view?usp=drive_link AS-general.csv


python3 <<EOF
import pandas as pd
import os

data_folder = 'source'  # Folder where the source CSV files are located
dataframes = []  # List to store dataframes

try:
    # Iterate through all files in the data_folder
    for filename in os.listdir(data_folder):
        # Check if the file is a CSV file
        if filename.endswith('.csv'):
            filepath = os.path.join(data_folder, filename)  # Get the full file path
            try:
                df = pd.read_csv(filepath)  # Read the CSV file into a dataframe
                dataframes.append(df)  # Append the dataframe to the list
            except pd.errors.EmptyDataError:
                print(f"Warning: {filename} is empty and has been skipped.")
            except pd.errors.ParserError:
                print(f"Error: {filename} is not a valid CSV file and has been skipped.")
            except Exception as e:
                print(f"An unexpected error occurred while reading {filename}: {e}")

    # Combine all dataframes into a single dataframe
    combined_df = pd.concat(dataframes, ignore_index=True)
    # Drop the 'group' column from the combined dataframe
    combined_df = combined_df.drop('group', axis=1)

    # Write the combined data to a text file
    with open('AS-ALL.txt', 'w') as f:
        for index, row in combined_df.iterrows():
            for column_name, cell_value in row.items():
                # Replace any newline characters in the cell value
                cell_value = str(cell_value).replace('\n', '')
                f.write(f"{column_name}: {cell_value}\n")  # Write column name and cell value to the file
            f.write("\n")  # Print a blank line
            f.write("\n")  # Print another blank line

except FileNotFoundError:
    print(f"Error: The directory '{data_folder}' does not exist.")
except PermissionError:
    print("Error: You do not have permission to read/write files in the specified directory.")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
EOF
