#!/bin/bash

# Show command syntax
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <google drive link> <converted_file_name>"
  exit 1
fi

# Set the remote file URL and local file path
GOOGLE_DRIVE_FILE_URL="$1"
GOOGLE_FILE_ID=$(echo $GOOGLE_DRIVE_FILE_URL | grep -o 'd/[^/]*' | cut -d'/' -f2)
CONVERTED_FILE_NAME="$2"

TEMP_FILE="temp_file.csv"
UTF8_TEMP_FILE="utf8_temp_file.csv"
OUTPUT_FOLDER="${HOME}/workspace/AS-FAQ-PREVIEW/source/"
LOCAL_FILE="${HOME}/workspace/AS-FAQ-PREVIEW/source/${CONVERTED_FILE_NAME}"


# Download the remote file to a temporary file
curl -L "https://drive.google.com/uc?id=${GOOGLE_FILE_ID}" -o ${TEMP_FILE}


# Check if the download was successfully
if [ $? -eq 0 ]; then
  iconv -f big5 -t utf-8 ${TEMP_FILE} -o ${UTF8_TEMP_FILE}

  # Check if the convert was successfully
  if [ $? -eq 0 ]; then
    echo "${CONVERTED_FILE_NAME} downloaded and converted to utf8 successfully."
    sed -i 's/\r//' ${UTF8_TEMP_FILE}
    #head ${OUTPUT_FOLDER}/${CONVERTED_FILE_NAME}

    if [ ! -f "${LOCAL_FILE}" ]; then
      mv "${UTF8_TEMP_FILE}" "${LOCAL_FILE}"
      echo "${CONVERTED_FILE_NAME} saved as ${LOCAL_FILE}"
    else
      # Compare the temporary file and the local file
      if ! diff "${UTF8_TEMP_FILE}" "${LOCAL_FILE}" > /dev/null; then
        # If the files are different, update the local file
	mv "${UTF8_TEMP_FILE}" "${LOCAL_FILE}"
	echo "File updated: ${LOCAL_FILE}"
      else
	# If the files are the same, delete the temporary file
	rm "${TEMP_FILE}" "${UTF8_TEMP_FILE}"
	echo "Files are the same, no update needed."
      fi
    fi
  fi
 
fi

