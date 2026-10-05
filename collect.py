#!/usr/bin/env python3
"""Collect GPU temperatures from nvidia-smi.

Runs `nvidia-smi --query-gpu=name,temperature.gpu --format=csv,noheader`,
parses each line into `{ name, tempC }`, and outputs JSON to stdout.

If nvidia-smi fails (no GPUs, no driver, or not installed), outputs `[]`
and exits 0 (not an error).
"""

import csv
import json
import subprocess
import sys
from shlex import quote


def main():
    try:
        result = subprocess.run(
            ["nvidia-smi", "--query-gpu", "name,temperature.gpu", "--format=csv,noheader"],
            capture_output=True,
            text=True,
            timeout=10,
        )
    except subprocess.TimeoutExpired:
        print(json.dumps([]), file=sys.stdout)
        sys.exit(0)
    except Exception:
        print(json.dumps([]), file=sys.stdout)
        sys.exit(0)

    # Parse CSV output
    gpus = []
    for line in result.stdout.strip().split("\n"):
        if not line.strip():
            continue
        try:
            reader = csv.reader([line])
            row = next(reader)
            if len(row) >= 2:
                name = row[0].strip()
                temp_c = float(row[1].strip())
                gpus.append({"name": name, "tempC": temp_c})
        except (ValueError, StopIteration, IndexError):
            # Skip malformed lines
            continue

    print(json.dumps(gpus))
    sys.exit(0)


if __name__ == "__main__":
    main()
