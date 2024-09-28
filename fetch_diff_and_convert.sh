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

TEMP_FILE="${HOME}/workspace/AS-FAQ-PREVIEW/temp_file.csv"
WS_PREVIEW_SOURCE="${HOME}/workspace/AS-FAQ-PREVIEW/source"
WS_BOT_SOURCE="${HOME}/workspace/AS-FAQ-Bot/data/source"
LOCAL_FILE="${WS_PREVIEW_SOURCE}/${CONVERTED_FILE_NAME}"


# Download the remote file to a temporary file
curl -s -S -L "https://drive.google.com/uc?id=${GOOGLE_FILE_ID}" -o ${TEMP_FILE}

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

#if [ ! -f "${LOCAL_FILE}" ]; then
#  mv "${TEMP_FILE}" "${LOCAL_FILE}"
#  echo "First download: ${CONVERTED_FILE_NAME} has been saved to ${WS_PREVIEW_SOURCE} and ${WS_BOT_SOURCE}"
#  cp "${LOCAL_FILE}" "${WS_BOT_SOURCE}"
#else
#  # Compare the temporary file and the local file
#  if ! diff "${TEMP_FILE}" "${LOCAL_FILE}" > /dev/null; then
#    # If the files are different, update the local file
#    mv "${TEMP_FILE}" "${LOCAL_FILE}"
#    echo "File updated: ${LOCAL_FILE}"
#    cp -f "${LOCAL_FILE}" "${WS_BOT_SOURCE}"
#  else
#    # If the files are the same, delete the temporary file
#    rm "${TEMP_FILE}" 
#    echo "${LOCAL_FILE} has no changes, no update needed."
#  fi
#fi

if [ ! -f "${LOCAL_FILE}" ]; then
  mv "${TEMP_FILE}" "${LOCAL_FILE}"
  echo "First download: ${CONVERTED_FILE_NAME} has been saved to ${WS_PREVIEW_SOURCE} and ${WS_BOT_SOURCE}"
  cp "${LOCAL_FILE}" "${WS_BOT_SOURCE}"
else
  # Check if TEMP_FILE is a valid CSV (the first line should have 6 fields)
  if [ "$(head -n 1 "${TEMP_FILE}" | awk -F, '{print NF}')" -ne 6 ]; then
    echo "${TEMP_FILE} is not valid CSV format"
    rm "${TEMP_FILE}"
  else
    # Compare the temporary file and the local file
    if ! diff "${TEMP_FILE}" "${LOCAL_FILE}" > /dev/null; then
      # If the files are different, update the local file
      mv "${TEMP_FILE}" "${LOCAL_FILE}"
      echo "File updated: ${LOCAL_FILE}"
      cp -f "${LOCAL_FILE}" "${WS_BOT_SOURCE}"
    else
      # If the files are the same, delete the temporary file
      rm "${TEMP_FILE}"
      echo "${LOCAL_FILE} has no changes, no update needed."
    fi
  fi
fi

 

