#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

def run(cmd, cwd=None):
    print("+", " ".join(cmd))
    subprocess.run(cmd, cwd=cwd, check=True)

def main():
    repos_json, base_path, out_dir = sys.argv[1], sys.argv[2], sys.argv[3]
    repos = json.loads(Path(repos_json).read_text())

    for repo in repos:
        name = repo["name"]
        print(f"== Building {name} ==")

        repo_dir = Path("deps") / name
        dest = Path(out_dir) / name

        run(["npm", "ci"], cwd=repo_dir)
        # 	TODO: do we need more than just vite build?
        run([
            "npx", "vite", "build",
            f"--base=/{base_path}/{name}/",
            f"--outDir={dest.resolve()}",
            "--emptyOutDir",
        ], cwd=repo_dir)

if __name__ == "__main__":
    main()
