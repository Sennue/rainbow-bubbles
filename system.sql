----------------------------------------------------------------
-- Schema
----------------------------------------------------------------

-- Dummy Table
DROP TABLE IF EXISTS dummy;
CREATE TABLE IF NOT EXISTS dummy (
  id     INTEGER,
  name   VARCHAR ( 16 ),
  amount INTEGER DEFAULT  1,
  PRIMARY KEY ( id, name )
);

-- Dummy View
DROP VIEW IF EXISTS dummy_view;
CREATE VIEW IF NOT EXISTS dummy_view AS
  SELECT MAX ( id ) + 1 AS next_id FROM dummy;


----------------------------------------------------------------
-- Data
----------------------------------------------------------------

INSERT INTO dummy ( id, name, amount ) VALUES ( 1, "a", 1 );
INSERT INTO dummy ( id, name, amount ) VALUES ( 2, "b", 2 );
INSERT INTO dummy ( id, name, amount ) VALUES ( 3, "c", 3 );

