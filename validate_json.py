import json
import os
import glob

files = glob.glob('assets/i18n/*.json')
files.append('assets/questions.json')

for f in files:
    try:
        with open(f, 'r', encoding='utf-8') as fh:
            json.load(fh)
        print(f"{f}: OK")
    except Exception as e:
        print(f"{f}: ERROR - {e}")
