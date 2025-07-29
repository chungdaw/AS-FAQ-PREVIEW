#!/bin/bash


WS_PREVIEW="${HOME}/workspace/AS-FAQ-PREVIEW"
WS_BOT="${HOME}/workspace/AS-FAQ-Bot/data"

LOCAL_FILE="${WS_PREVIEW}/AS-ALL.txt"
TEMP_FILE="${WS_PREVIEW}/AS-ALL-TEMP.txt"

CURRENT_TIME=$(TZ=Asia/Taipei date '+%Y/%m/%d %H:%M')

echo -e "\n**** ${CURRENT_TIME} ****"

${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1_qaiG8txzw0Jct1EjUSPkCgmknZzuq1c/view?usp=drive_link AS-hro.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1pY15JdUA_doSpturHPNeLWG5S8LySjKw/view?usp=drive_link AS-dgbas.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1Hj6rNwxSoWSom693JBtlVjkCwW8bfBv3/view?usp=drive_link AS-dla.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1lSSFCe5qsFyeXmKBbzliXrRoigQHhOVl/view?usp=drive_link AS-ethics.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/17OhTLsKMerAN6T3LZW9u0GHS8Bk9-i9f/view?usp=drive_link AS-art.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1CGIsv2aFvabR_3YU0k-jL8QxrEC2gBFG/view?usp=drive_link AS-edoc.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1KS6eKkAe_Ib8X0CGcexqcIyiXQAV8O4f/view?usp=drive_link AS-media.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1tqNDdAK6jj7g2dskvmZZqfYWluCLozQP/view?usp=drive_link AS-meeting.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1pSQi1gPVgeA8qYVgWNCM0Jj6-u_zmAqk/view?usp=drive_link AS-dia.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1-O_IwjJ0aitbmkD_c3InUUYyOuCtjGvl/view?usp=drive_link AS-iptt.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1aEhy5hGuTsF75E9091_dPQIrKCCBdxyC/view?usp=drive_link AS-ITS.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1XzsVEiSHxgwQBk1I9lHWfueNlCq4GZ4H/view?usp=drive_link AS-proposal.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1iTfmlJg5tddbEIDcrOfoiiTrys04_8Pg/view?usp=drive_link AS-proposal2.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1kkVqvYgOquy1_r-Mxit2tQnjM-305MsB/view?usp=drive_link AS-proposal3.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/186BeehxOQEWu8tzknvcBCb5BmoMponSl/view?usp=drive_link AS-general.csv
${WS_PREVIEW}/fetch_diff_and_convert.sh https://drive.google.com/file/d/1_57sHTErrvRHJePstAxIidErV0TZhnVw/view?usp=drive_link AS-as.csv

python3 <<EOF
import pandas as pd
import os

data_folder = '/home/ic_chungdau_wang/workspace/AS-FAQ-PREVIEW/source'  # Folder where the source CSV files are located
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
    with open('/home/ic_chungdau_wang/workspace/AS-FAQ-PREVIEW/AS-ALL-TEMP.txt', 'w') as f:
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


if [ ! -f "${LOCAL_FILE}" ]; then
  mv "${TEMP_FILE}" "${LOCAL_FILE}"
  echo "AS-ALL-TEMP.txt saved as ${LOCAL_FILE}"
else
  # Compare the temporary file and the local file
  if ! diff "${TEMP_FILE}" "${LOCAL_FILE}" > /dev/null; then
    # If the files are different, update both workspaces
    mv "${TEMP_FILE}" "${LOCAL_FILE}"
    echo "AS-ALL.txt has been updated, sync to github.com:chungdaw/AS-FAQ-PREVIEW" 
    cd "${WS_PREVIEW}" || exit
    git pull origin main
    git add AS-ALL.txt
    git add source/*.csv
    git commit -m "update at ${CURRENT_TIME}"
    git push -u origin main    

    echo "AS-ALL.txt has been updated, sync to github.com:AS-AIGC/AS-FAQ-Bot"
    cp -f "${LOCAL_FILE}" "${WS_BOT}"
    cd "${WS_BOT}" || exit
    git pull origin main
    git add AS-ALL.txt
    git add source/*.csv
    git commit -m "update at ${CURRENT_TIME}"
    git push -u origin main
  else
    # If the files are the same, delete the temporary file
    rm "${TEMP_FILE}"
    echo "AS-ALL.txt are the same, no update needed."
  fi
fi
