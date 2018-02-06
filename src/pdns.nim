import db_sqlite, protocol

proc setup_pdns*(datastore: Datastore): void =
  datastore.ds.exec(sql"PRAGMA foreign_keys = 1;")

  datastore.ds.exec(sql"""
  CREATE TABLE domains (
    id                    INTEGER PRIMARY KEY,
    name                  VARCHAR(255) NOT NULL COLLATE NOCASE,
    master                VARCHAR(128) DEFAULT NULL,
    last_check            INTEGER DEFAULT NULL,
    type                  VARCHAR(6) NOT NULL,
    notified_serial       INTEGER DEFAULT NULL,
    account               VARCHAR(40) DEFAULT NULL
  );""")

  datastore.ds.exec(sql"CREATE UNIQUE INDEX name_index ON domains(name);")

  datastore.ds.exec(sql"""   
  CREATE TABLE records (
    id                    INTEGER PRIMARY KEY,
    domain_id             INTEGER DEFAULT NULL,
    name                  VARCHAR(255) DEFAULT NULL,
    type                  VARCHAR(10) DEFAULT NULL,
    content               VARCHAR(65535) DEFAULT NULL,
    ttl                   INTEGER DEFAULT NULL,
    prio                  INTEGER DEFAULT NULL,
    change_date           INTEGER DEFAULT NULL,
    disabled              BOOLEAN DEFAULT 0,
    ordername             VARCHAR(255),
    auth                  BOOL DEFAULT 1,
    FOREIGN KEY(domain_id) REFERENCES domains(id) ON DELETE CASCADE ON UPDATE CASCADE
  );""")
  
  datastore.ds.exec(sql"CREATE INDEX rec_name_index ON records(name);")
  datastore.ds.exec(sql"CREATE INDEX nametype_index ON records(name,type);")
  datastore.ds.exec(sql"CREATE INDEX domain_id ON records(domain_id);")
  datastore.ds.exec(sql"CREATE INDEX orderindex ON records(ordername);")

  datastore.ds.exec(sql""" 
  CREATE TABLE supermasters (
    ip                    VARCHAR(64) NOT NULL,
    nameserver            VARCHAR(255) NOT NULL COLLATE NOCASE,
    account               VARCHAR(40) NOT NULL
  );""")

  datastore.ds.exec(sql"""
  CREATE UNIQUE INDEX ip_nameserver_pk ON supermasters(ip, nameserver);""")

  datastore.ds.exec(sql""" 
  CREATE TABLE comments (
    id                    INTEGER PRIMARY KEY,
    domain_id             INTEGER NOT NULL,
    name                  VARCHAR(255) NOT NULL,
    type                  VARCHAR(10) NOT NULL,
    modified_at           INT NOT NULL,
    account               VARCHAR(40) DEFAULT NULL,
    comment               VARCHAR(65535) NOT NULL,
    FOREIGN KEY(domain_id) REFERENCES domains(id) ON DELETE CASCADE ON UPDATE CASCADE
  );""")

  datastore.ds.exec(sql""" 
  CREATE INDEX comments_domain_id_index ON comments (domain_id);""")

  datastore.ds.exec(sql"""
  CREATE INDEX comments_nametype_index ON comments (name, type);""")

  datastore.ds.exec(sql""" 
  CREATE INDEX comments_order_idx ON comments (domain_id, modified_at);""")

  datastore.ds.exec(sql""" 
  CREATE TABLE domainmetadata (
   id                     INTEGER PRIMARY KEY,
   domain_id              INT NOT NULL,
   kind                   VARCHAR(32) COLLATE NOCASE,
   content                TEXT,
   FOREIGN KEY(domain_id) REFERENCES domains(id) ON DELETE CASCADE ON UPDATE CASCADE
  );""")

  datastore.ds.exec(sql""" 
  CREATE INDEX domainmetaidindex ON domainmetadata(domain_id);""")

  datastore.ds.exec(sql""" 
  CREATE TABLE cryptokeys (
   id                     INTEGER PRIMARY KEY,
   domain_id              INT NOT NULL,
   flags                  INT NOT NULL,
   active                 BOOL,
   content                TEXT,
   FOREIGN KEY(domain_id) REFERENCES domains(id) ON DELETE CASCADE ON UPDATE CASCADE
  );""")
  
  datastore.ds.exec(sql""" 
  CREATE INDEX domainidindex ON cryptokeys(domain_id);""")

  datastore.ds.exec(sql""" 
  CREATE TABLE tsigkeys (
   id                     INTEGER PRIMARY KEY,
   name                   VARCHAR(255) COLLATE NOCASE,
   algorithm              VARCHAR(50) COLLATE NOCASE,
   secret                 VARCHAR(255)
  );""")

  datastore.ds.exec(sql""" 
  CREATE UNIQUE INDEX namealgoindex ON tsigkeys(name, algorithm);""")
