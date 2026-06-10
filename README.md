# docstring-check

This is a precommit hook that you can use to check that newly added python functions and classes have docstrings :) since it only checks new and changed code rather than the whole codebase, you can use it to gradually introduce docstrings to a large codebase that has missing docstrings.

To install it into your repo you will need to copy the pre-commit hook config from `.pre-commit-config.yml` into your repo's `.pre-commit-config.yml`, and copy the `docstring-check.sh` script into your repo, somewhere the pre-commit hook can access it. You will also need to install `ruff` as this tool relies on it.

This is an example of how it works, showing you where a newly added function needs to have a docstring added:

```bash
[oscarsaharoy ~/projects/test] $ git commit -m"test"
check python ast.........................................................Passed
check for added large files..............................................Passed
check for merge conflicts................................................Passed
check for case conflicts.................................................Passed
check docstring is first.................................................Passed
check json...........................................(no files to check)Skipped
check yaml...........................................(no files to check)Skipped
docstring-check..........................................................Failed
- hook id: docstring-check
- exit code: 1

backend/test.py:1:5: D103 Missing docstring in public function
  |
1 | def new_function():
  |     ^^^^^^^^^^^^ D103
2 |     pass
  |

Found 1 missing docstring - please add docstrings for these classes and functions.
```

