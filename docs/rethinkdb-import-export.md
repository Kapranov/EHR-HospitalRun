You can import data as follows:

```bash
# Import a JSON document into table `users` in database `my_db`
$ rethinkdb import -c HOST:PORT -f user_data.json --table my_db.users

# Import a CSV document
$ rethinkdb import -c HOST:PORT -f user_data.csv --format csv --table my_db.users
```

The `export` command works as follows:

```bash
# Export a table into a JSON file (placed in the directory
# rethinkdb_export_DATE_TIME by default)
$ rethinkdb export -c HOST:PORT -e my_db.users

# Export a table into a CSV file
$ rethinkdb export -c HOST:PORT -e my_db.users --format csv \
                   --fields first_name,last_name,address      # `--fields` is mandatory when exporting into CSV
```

This is only a small taste of what import and export commands can
do. Run `rethinkdb import --help` and `rethinkdb export --help` for
more information on these commands.

No migration is required when upgrading from RethinkDB 2.3.x. Please
read the [RethinkDB 2.3.0 release notes](https://github.com/rethinkdb/rethinkdb/releases/tag/v2.3.0) if you're upgrading from an
older version.

Github repository [2.3.4 — Fantasia](https://github.com/rethinkdb/rethinkdb/releases/tag/v2.3.4).

See more about the 2.3.4 release in the [release announcement](http://www.rethinkdb.com/blog/2.3-release/).
