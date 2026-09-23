#!/usr/bin/env python3
"""
Grades myanswers.sql against canonical_answers.sql (SQLite-safe reference)
using the NorthStar Retail schema, and prints PASS/FAIL per question.

Usage:
    python run_tests.py                 # grade every question
    python run_tests.py 12              # grade only question 12
    python run_tests.py 12 40 70        # grade a specific set of questions
    python run_tests.py -v              # on FAIL, show a hint of what differed
    python run_tests.py --file other.sql

Grading method:
    - Runs your query and the reference query in separate connections
      (same schema), then compares results as a sorted set of rows
      (order-independent) with numeric values normalized so 2 vs 2.0
      don't cause false failures.
    - Question 65 (CREATE VIEW) and 66 (CREATE INDEX) are graded
      structurally: PASS if they execute without error.
    - Question 67 is a prose/design question — marked INFO (ungraded).
    - A blank block in myanswers.sql is marked SKIP.
    - Row order matters only if your query result order differs in a
      way that changes which values pair up per column position, which
      the set-comparison here does not check — see README note in
      SQLITE_NOTES.md if a query "looks right" but fails: check column
      order/aliases match the question's intent, not exact naming.
"""

import argparse
import re
import sqlite3
import sys
from pathlib import Path

HERE = Path(__file__).parent
SCHEMA_FILE = HERE / "schema.sql"
REFERENCE_FILE = HERE / "canonical_answers.sql"

BLOCK_RE = re.compile(r"^--\s*(\d+)\s*$", re.MULTILINE)

STRUCTURAL_ONLY = {65, 66}   # DDL: pass if it runs, don't compare rows
UNGRADED = {67}              # prose/design questions


def parse_blocks(path: Path) -> dict[int, str]:
    text = path.read_text(encoding="utf-8")
    matches = list(BLOCK_RE.finditer(text))
    blocks: dict[int, str] = {}
    for i, m in enumerate(matches):
        num = int(m.group(1))
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        body = text[start:end].strip()
        blocks[num] = body
    return blocks


def fresh_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(":memory:")
    conn.executescript(SCHEMA_FILE.read_text(encoding="utf-8"))
    return conn


def normalize_value(v):
    if isinstance(v, (int, float)):
        return round(float(v), 6)
    if isinstance(v, str):
        return v.strip()
    return v


def run_and_collect(conn: sqlite3.Connection, sql: str):
    """Returns (columns, sorted_rows) or raises sqlite3.Error. Runs every
    statement in `sql` (supports multi-statement blocks like DROP+CREATE
    VIEW) and reports results from the LAST statement that returns rows."""
    cur = conn.cursor()
    cols, rows = [], []
    for stmt in filter(None, (s.strip() for s in sql.split(";"))):
        cur.execute(stmt)
        if cur.description:
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
    normalized = sorted(
        tuple(normalize_value(v) for v in row) for row in rows
    )
    return cols, normalized


def main():
    parser = argparse.ArgumentParser(description="Grade myanswers.sql against the reference answers.")
    parser.add_argument("numbers", nargs="*", type=int, help="specific question numbers to grade")
    parser.add_argument("--file", default="myanswers.sql", help="answers file to grade (default: myanswers.sql)")
    parser.add_argument("-v", "--verbose", action="store_true", help="show a hint on failures")
    args = parser.parse_args()

    answers_path = HERE / args.file
    for f in (answers_path, SCHEMA_FILE, REFERENCE_FILE):
        if not f.exists():
            print(f"Could not find {f}")
            sys.exit(1)

    mine = parse_blocks(answers_path)
    reference = parse_blocks(REFERENCE_FILE)
    total_questions = 80
    targets = args.numbers if args.numbers else list(range(1, total_questions + 1))

    results = {}  # n -> "PASS" | "FAIL" | "ERROR" | "SKIP" | "INFO"

    for n in targets:
        if n in UNGRADED:
            results[n] = "INFO"
            print(f"Q{n:>2}: INFO  (design/prose question — not auto-graded)")
            continue

        my_sql = mine.get(n, "")
        if not my_sql:
            results[n] = "SKIP"
            print(f"Q{n:>2}: SKIP  (blank)")
            continue

        try:
            conn = fresh_conn()
            my_cols, my_rows = run_and_collect(conn, my_sql)
            conn.close()
        except sqlite3.Error as e:
            results[n] = "ERROR"
            print(f"Q{n:>2}: ERROR ({e})")
            continue

        if n in STRUCTURAL_ONLY:
            results[n] = "PASS"
            print(f"Q{n:>2}: PASS  (executed OK — DDL, not row-graded)")
            continue

        try:
            ref_conn = fresh_conn()
            ref_cols, ref_rows = run_and_collect(ref_conn, reference[n])
            ref_conn.close()
        except sqlite3.Error as e:
            print(f"Q{n:>2}: (reference query itself errored — {e}; skipping grade)")
            continue

        if my_rows == ref_rows:
            results[n] = "PASS"
            print(f"Q{n:>2}: PASS")
        else:
            results[n] = "FAIL"
            msg = f"Q{n:>2}: FAIL"
            if args.verbose:
                msg += f"  (your rows: {len(my_rows)}, expected rows: {len(ref_rows)}"
                if my_rows and ref_rows:
                    diff_mine = [r for r in my_rows if r not in ref_rows][:2]
                    diff_ref = [r for r in ref_rows if r not in my_rows][:2]
                    if diff_mine:
                        msg += f"; e.g. you have {diff_mine} not expected"
                    if diff_ref:
                        msg += f"; missing e.g. {diff_ref}"
                msg += ")"
            print(msg)

    print("=" * 50)
    counts = {k: sum(1 for v in results.values() if v == k) for k in ("PASS", "FAIL", "ERROR", "SKIP", "INFO")}
    print(f"Total: {len(results)}  Pass: {counts['PASS']}  Fail: {counts['FAIL']}  "
          f"Error: {counts['ERROR']}  Skip: {counts['SKIP']}  Info: {counts['INFO']}")


if __name__ == "__main__":
    main()
