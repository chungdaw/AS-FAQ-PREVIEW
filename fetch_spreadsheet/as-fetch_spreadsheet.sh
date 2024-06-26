#!/bin/bash

/home/ic_chungdau_wang/faq/fetch_and_convert.sh 1vRfyjp1Y479Dxhxm-H9CgP5KwWwPvCA9 as-its.csv
/home/ic_chungdau_wang/faq/fetch_and_convert.sh 1XA8tPXU1jhc39pQ5qAij-1I3cfZnHJBO as-finding.csv
/home/ic_chungdau_wang/faq/fetch_and_convert.sh 1xUtU7fl4yHEkcSmNcDr8Pz_sTsxDX1qR as-art.csv
/home/ic_chungdau_wang/faq/fetch_and_convert.sh 126VWafW_G0gw7cyGHJG78GsJbr3qd5vV as-dia.csv
/home/ic_chungdau_wang/faq/fetch_and_convert.sh 1Gp5oV6ByaYuH2Nki7d81EjmxNkXIFrIM as-general.csv
/home/ic_chungdau_wang/faq/fetch_and_convert.sh 1SYmDVGKjqLkQK0px7_rLhhsNTpBomuzA as-iptt.csv


# 確保 CSV 內容為 UTF-8
vi -c ':set fileencoding=utf8' -c ':wq' $CSV_FILE

# 使用 Python 顯示第1和第2筆記錄
python3 <<EOF
import csv

csv_file = "$CSV_FILE"

with open(csv_file, encoding='utf-8') as f:
    reader = csv.reader(f)
    header = next(reader)  # 讀取標題行
    first_record = next(reader)  # 讀取第一筆記錄
    second_record = next(reader)  # 讀取第二筆記錄

print("The first record is:")
print(first_record)
print("\nThe second record is:")
print(second_record)
EOF
