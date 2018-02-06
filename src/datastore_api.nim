import db_sqlite, protocol, pdns

proc setup_ds(datastore: Datastore): void =
  pdns.setup_pdns(datastore)

proc close_ds(datastore: Datastore): void =
  datastore.ds.close()

proc open_ds(name: string): Datastore =
  new result
  result.ds = open(name, "", "", "")

proc exec*(db: DbConn, query: string, args: varargs[string]): proc =
  db_sqlite.exec(db, sql query, args)

proc getRow*(db: DbConn, query: string, args: varargs[string]): Row =
  db_sqlite.getRow(db, sql query, args)

proc init*(name: string) =
  let datastore = open_ds(name)
  setup_ds(datastore)
