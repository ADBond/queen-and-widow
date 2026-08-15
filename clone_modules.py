#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

def run(cmd):
    print("+", " ".join(cmd))
    subprocess.run(cmd, check=True)

def main():
    repos = json.loads(Path(sys.argv[1]).read_text())
    Path("deps").mkdir(exist_ok=True)

    for repo in repos:
        url, name, commit = repo["url"], repo["name"], repo["sha"]
        dest = Path("deps") / name
        print(f"== {name} @ {commit} ==")

        if not (dest / ".git").exists():
            run(["git", "clone", "--no-checkout", url, str(dest)])

        run(["git", "-C", str(dest), "fetch", "--depth", "1", "origin", commit])
        run(["git", "-C", str(dest), "checkout", "FETCH_HEAD"])

if __name__ == "__main__":
    main()
