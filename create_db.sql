-- Requires Sqlite > 3.6.19
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS modules;
CREATE TABLE modules(
    idx INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT
);
DROP INDEX IF EXISTS module_names;
CREATE UNIQUE INDEX module_names ON modules( idx );

DROP TABLE IF EXISTS paths;
CREATE TABLE paths(
    idx INTEGER PRIMARY KEY AUTOINCREMENT,
    module INTEGER NOT NULL REFERENCES modules( idx ) ON UPDATE CASCADE ON DELETE CASCADE,
    path TEXT NOT NULL,
    digest CHARACTER(40) NOT NULL,
    FOREIGN KEY ( module ) REFERENCES modules( idx )
);
DROP INDEX IF EXISTS paths_paths;
CREATE UNIQUE INDEX paths_paths ON paths( path );
DROP INDEX IF EXISTS paths_modules;
CREATE UNIQUE INDEX paths_modules ON paths( module );
DROP INDEX IF EXISTS paths_digest;
CREATE UNIQUE INDEX paths_digest ON paths( digest );

-- INSERT INTO modules ( `name` ) VALUES( "test" );
-- SELECT * FROM modules;
-- This should cause an error, if the foreign_keys are working.
-- INSERT INTO paths (`module`, `path`) VALUES( 5, '/foo/bar' );
-- SELECT * FROM paths;
