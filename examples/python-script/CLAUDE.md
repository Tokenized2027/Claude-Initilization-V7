# Python Script — Claude Instructions

> Claude reads this file automatically at the start of every session.

## What this project is

A single file Python utility that `[one sentence: what does this script do]`. Example: "reads a CSV of transactions and prints a monthly summary."

## Stack

- Python 3.11+
- Standard library only, unless a specific task needs `requests`, `pandas`, or `beautifulsoup4`. New dependencies require approval.
- No packaging. Runs as `python3 script.py`.

## File layout

```
script.py          the one file that does the work
requirements.txt   only if we end up with dependencies
data/              input files (gitignored)
output/            generated output (gitignored)
```

## Rules for Claude

### Always

- Use type hints on function signatures.
- Use `argparse` for command line arguments. No bare `sys.argv` parsing.
- Print progress to stderr, results to stdout, so the script can be piped.
- Exit non zero on failure. Exit zero on success. Nothing in between.
- Handle `KeyboardInterrupt` gracefully (no stack trace on Ctrl-C).

### Never

- Hardcode paths. Use `pathlib.Path` and accept paths as arguments.
- Print secrets, tokens, or full credit card numbers, even in error messages.
- Add a dependency without asking first. Stdlib is almost always enough.
- Modify input files in place unless the user asks. Always write to `output/` by default.

## Testing

If the script grows past 100 lines, split it into functions and add a `tests/` folder with pytest.

```bash
python3 -m pytest tests/ -v
```

## Checklist before shipping

- [ ] `--help` explains what the script does in one screen.
- [ ] Fails cleanly on missing input files (no stack trace).
- [ ] Runs end to end on the example input in `data/example.*`.
- [ ] No secrets in the code. All config via CLI args or environment variables.
