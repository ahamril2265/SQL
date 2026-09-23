# SQLite equivalents for Postgres-only functions in answers.sql

`run_tests.py` runs your queries against SQLite (the only engine available
locally). `answers.sql` was written in Postgres dialect for readability. If
you copy patterns from it into `myanswers.sql`, swap these:

| Postgres                                   | SQLite equivalent                                              |
|---------------------------------------------|------------------------------------------------------------------|
| `DATE_TRUNC('month', order_date)`           | `strftime('%Y-%m', order_date)`                                  |
| `EXTRACT(YEAR FROM signup_date)`            | `strftime('%Y', signup_date)`                                    |
| `ship_date - order_date` (date subtraction) | `julianday(ship_date) - julianday(order_date)`                   |
| `TO_CHAR(order_date, 'Day')`                | `strftime('%w', order_date)` (0=Sunday..6=Saturday, map manually) |
| `SUBSTRING(email FROM POSITION('@' IN email) + 1)` | `substr(email, instr(email, '@') + 1)`                     |
| `first_name \|\| ' ' \|\| last_name`         | same — `\|\|` works in SQLite too                                |
| `NULLIF(x, 0)`                              | same — supported                                                 |
| `RANK()/DENSE_RANK()/ROW_NUMBER()/LAG()/LEAD()/NTILE()` | same — SQLite 3.25+ supports all window functions    |
| `BOOLEAN` type                              | SQLite has no real boolean; `0`/`1` integers work fine            |
| `CREATE VIEW`, `CREATE INDEX`               | same syntax, both supported                                       |

Example — Question 46 ("month with highest revenue"), Postgres → SQLite:

```sql
-- Postgres
SELECT DATE_TRUNC('month', o.order_date) AS month, SUM(...) AS revenue
...
GROUP BY month

-- SQLite
SELECT strftime('%Y-%m', o.order_date) AS month, SUM(...) AS revenue
...
GROUP BY month
```
