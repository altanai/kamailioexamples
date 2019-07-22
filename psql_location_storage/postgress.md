## Postgress sql DB

object-relational database management system (ORDBMS) 

### features 
complex queries
foreign keys
triggers
updatable views
transactional integrity
multiversion concurrency control

### Usage:
  psql [OPTION]... [DBNAME [USERNAME]]

### General options:
  -c, --command=COMMAND    run only single command (SQL or internal) and exit
  -d, --dbname=DBNAME      database name to connect to (default: "root")
  -f, --file=FILENAME      execute commands from file, then exit
  -l, --list               list available databases, then exit
  -v, --set=, --variable=NAME=VALUE
                           set psql variable NAME to VALUE (e.g., -v ON_ERROR_STOP=1)
  -V, --version            output version information, then exit
  -X, --no-psqlrc          do not read startup file (~/.psqlrc)
  -1 ("one"), --single-transaction
                           execute as a single transaction (if non-interactive)
  -?, --help[=options]     show this help, then exit
      --help=commands      list backslash commands, then exit
      --help=variables     list special variables, then exit

Input and output options:
  -a, --echo-all           echo all input from script
  -b, --echo-errors        echo failed commands
  -e, --echo-queries       echo commands sent to server
  -E, --echo-hidden        display queries that internal commands generate
  -L, --log-file=FILENAME  send session log to file
  -n, --no-readline        disable enhanced command line editing (readline)
  -o, --output=FILENAME    send query results to file (or |pipe)
  -q, --quiet              run quietly (no messages, only query output)
  -s, --single-step        single-step mode (confirm each query)
  -S, --single-line        single-line mode (end of line terminates SQL command)

Output format options:
  -A, --no-align           unaligned table output mode
  -F, --field-separator=STRING
                           field separator for unaligned output (default: "|")
  -H, --html               HTML table output mode
  -P, --pset=VAR[=ARG]     set printing option VAR to ARG (see \pset command)
  -R, --record-separator=STRING
                           record separator for unaligned output (default: newline)
  -t, --tuples-only        print rows only
  -T, --table-attr=TEXT    set HTML table tag attributes (e.g., width, border)
  -x, --expanded           turn on expanded table output
  -z, --field-separator-zero
                           set field separator for unaligned output to zero byte
  -0, --record-separator-zero
                           set record separator for unaligned output to zero byte

Connection options:
  -h, --host=HOSTNAME      database server host or socket directory (default: "/var/run/postgresql")
  -p, --port=PORT          database server port (default: "5432")
  -U, --username=USERNAME  database user name (default: "root")
  -w, --no-password        never prompt for password
  -W, --password           force password prompt (should happen automatically)

### To list all postgress related packages 

```
>dpkg -l | grep postgres
ii  pgdg-keyring                      2018.2                         all          keyring for apt.postgresql.org
ii  postgresql-10                     10.9-1.pgdg90+1                amd64        object-relational SQL database, version 10 server
ii  postgresql-client-10              10.9-1.pgdg90+1                amd64        front-end programs for PostgreSQL 10
ii  postgresql-client-common          203.pgdg90+1                   all          manager for multiple PostgreSQL client versions
ii  postgresql-common                 203.pgdg90+1                   all          PostgreSQL database-cluster manager
```

Ref : https://www.postgresql.org/docs/11/index.html

