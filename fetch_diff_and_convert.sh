#!/bin/bash

# Show command syntax
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <google drive file url> <output file name>"
  exit 1
fi

# Set the remote file URL and local file path
GOOGLE_DRIVE_FILE_URL="$1"
GOOGLE_FILE_ID=$(echo $GOOGLE_DRIVE_FILE_URL | grep -o 'd/[^/]*' | cut -d'/' -f2)
CONVERTED_FILE_NAME="$2"

TEMP_FILE="temp_file.csv"
OUTPUT_FOLDER="${HOME}/workspace/AS-FAQ-PREVIEW/source/"
LOCAL_FILE="${HOME}/workspace/AS-FAQ-PREVIEW/source/${CONVERTED_FILE_NAME}"


# Download the remote file to a temporary file
curl -L "https://drive.google.com/uc?id=${GOOGLE_FILE_ID}" -o ${TEMP_FILE}

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Download failed, exiting."
  exit 1
fi


# Determine the encoding of the downloaded file
encoding=$(uchardet "${TEMP_FILE}")

case $encoding in
  iso-8859-1)
    iconv -f iso-8859-1 -t utf-8 "${TEMP_FILE}" -o "${TEMP_FILE}.utf8"
    mv "${TEMP_FILE}.utf8" "${TEMP_FILE}"
    ;;
  us-ascii|utf-8)
    # No conversion needed for UTF-8 and ASCII, but if present, check for BOM and remove 
    if [ "$(head -c 3 "${TEMP_FILE}")" == $'\xef\xbb\xbf' ]; then
      tail -c +4 "${TEMP_FILE}" > "${TEMP_FILE}.nobom"
      mv "${TEMP_FILE}.nobom" "${TEMP_FILE}"
    fi
    ;;
  big5)
    iconv -f big5 -t utf-8 "${TEMP_FILE}" -o "${TEMP_FILE}.utf8"
    mv "${TEMP_FILE}.utf8" "${TEMP_FILE}"
    ;;
  utf-16|utf-16le|utf-16be)
    iconv -f $encoding -t utf-8 "${TEMP_FILE}" -o "${TEMP_FILE}.utf8"
    mv "${TEMP_FILE}.utf8" "${TEMP_FILE}"
    ;;
  *)
    # Attempt conversion for other encodings (including Unicode)
    iconv -f $encoding -t utf-8 "${TEMP_FILE}" -o "${TEMP_FILE}.utf8" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo "Unknown or unsupported encoding: $encoding"
      rm "${TEMP_FILE}"
      exit 1
    else
      mv "${TEMP_FILE}.utf8" "${TEMP_FILE}"
    fi
    ;;
esac

echo "${CONVERTED_FILE_NAME} are downloaded and converted to utf8 successfully."
sed -i 's/\r//' ${TEMP_FILE}

if [ ! -f "${LOCAL_FILE}" ]; then
  mv "${TEMP_FILE}" "${LOCAL_FILE}"
  echo "${CONVERTED_FILE_NAME} saved as ${LOCAL_FILE}"
else
  # Compare the temporary file and the local file
  if ! diff "${TEMP_FILE}" "${LOCAL_FILE}" > /dev/null; then
    # If the files are different, update the local file
    mv "${TEMP_FILE}" "${LOCAL_FILE}"
    echo "File updated: ${LOCAL_FILE}"
  else
    # If the files are the same, delete the temporary file
    rm "${TEMP_FILE}" 
    echo "Files are the same, no update needed."
  fi
fi
 
