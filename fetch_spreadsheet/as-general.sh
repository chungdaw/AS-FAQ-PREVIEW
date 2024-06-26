#!/bin/bash

#ACCESS_TOKEN=$(gcloud auth application-default print-access-token)


# url
# https://docs.google.com/spreadsheets/d/1aiFrwP6SonTZhiEwKLqOPsP0ViqJK_N-F4BSuHHjIRU/edit?gid=442771215#gid=442771215

# export to csv by using wget
# wget --header="Authorization: Bearer $ACCESS_TOKEN" \
#     "https://docs.google.com/spreadsheets/d/1aiFrwP6SonTZhiEwKLqOPsP0ViqJK_N-F4BSuHHjIRU/export?format=csv&gid=442771215" \
#     -O output.csv


SPREADSHEET_ID="1aiFrwP6SonTZhiEwKLqOPsP0ViqJK_N-F4BSuHHjIRU" 
CSV_FILE="spreadsheet.csv"
HEADER_FILE="header.csv"

wget -O $CSV_FILE "https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID/export?format=csv"

vi -c ':set fileencoding=utf8' -c ':wq' $CSV_FILE

awk 'NR>2' $CSV_FILE >> $HEADER_FILE

echo "appending content to $HEADER_FILE"

