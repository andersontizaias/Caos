#!/usr/bin/env python3
import json, sys

report = json.load(open(sys.argv[1]))
threshold = float(sys.argv[2])
coverage = report["lineCoverage"] * 100

print(f"Coverage: {coverage:.1f}% (threshold: {threshold}%)")

if coverage < threshold:
    print(f"FAIL: coverage {coverage:.1f}% is below {threshold}%")
    sys.exit(1)

print("PASS")
