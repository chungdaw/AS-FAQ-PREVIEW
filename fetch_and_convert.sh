#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <google drive link> <converted_file_name>"
  exit 1
fi

GOOGLE_DRIVE_LINK="$1"
FILE_ID=$(echo $GOOGLE_DRIVE_LINK | grep -o 'd/[^/]*' | cut -d'/' -f2)
CONVERTED_FILE_NAME="$2"
FILE_NAME="downloaded_file.csv"
OUTPUT_FOLDER="${HOME}/workspace/AS-FAQ-PREVIEW/source/"

curl -L "https://drive.google.com/uc?id=${FILE_ID}" -o ${FILE_NAME}

if [ $? -eq 0 ]; then
  echo "${CONVERTED_FILE_NAME} downloaded successfully."
  iconv -f big5 -t utf-8 ${FILE_NAME} -o ${OUTPUT_FOLDER}/${CONVERTED_FILE_NAME}

  if [ $? -eq 0 ]; then
    echo "${CONVERTED_FILE_NAME} converted to UTF-8 successfully."
    sed -i 's/\r//' ${OUTPUT_FOLDER}/${CONVERTED_FILE_NAME}
    #head ${OUTPUT_FOLDER}/${CONVERTED_FILE_NAME}
  fi
fi

