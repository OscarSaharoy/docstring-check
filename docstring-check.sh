#!/usr/bin/env bash

# script to check newly added python code has docstrings, using ruff + git diff

changed_files=$(git diff --name-only --cached | grep -E "\.py$")

git diff --cached --unified=0 $changed_files > /tmp/docstring_check_changed_files_diff.txt
FORCE_COLOR=1 ruff check $changed_files --select D101,D102,D103 > /tmp/docstring_check_ruff_output.txt 2>/dev/null

python3 -c "
import re
from strip_ansi import strip_ansi

with open('/tmp/docstring_check_changed_files_diff.txt') as diff_file:
    diff = diff_file.read()

with open('/tmp/docstring_check_ruff_output.txt') as ruff_file:
    ruff_result = ruff_file.read()

getfile = lambda error: strip_ansi(error).split(':')[0]
getline = lambda error: int(strip_ansi(error).split(':')[1])

def get_chunk_range(ch):
    range_string = rs = re.split(r'\+| ', ch)[3]
    start_length = sl = rs.split(',') if ',' in rs else [rs, '1']
    return int(sl[0]), int(sl[0]) + int(sl[1])

ruff_errors = [(error, getfile(error), getline(error)) for error in ruff_result.split('\n\n')[:-1]]
ruff_errors = [error for error in ruff_errors if 'class Migration' not in error[0] and 'class Meta' not in error[0]]

file_diffs = diff.split('+++ b/')
line_ranges = []
for file_diff in file_diffs:
    filename = file_diff.split('\n')[0]
    chunk_headers = [line for line in file_diff.split('\n') if line.startswith('@@')]
    line_ranges.extend([(filename, *get_chunk_range(ch)) for ch in chunk_headers])

ruff_errors = [error for (error, filename, line) in ruff_errors if any(filename == range_filename and range_start <= line < range_end for (range_filename, range_start, range_end) in line_ranges)]
if ruff_errors:
    print('\n\n'.join(ruff_errors))
    print(f'\nFound {len(ruff_errors)} missing docstring{\"s\" if len(ruff_errors) > 1 else \"\"} - please add docstrings for these classes and functions.')
    exit(1)
"
