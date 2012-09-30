----------------------------------------------------------------
--
--  user.sql
--  The schema for all the read / write user data in the game.
--
--  Written in 2012 by Brendan A R Sechter <bsechter@sennue.com>
--
--  To the extent possible under law, the author(s) have
--  dedicated all copyright and related and neighboring rights
--  to this software to the public domain worldwide. This
--  software is distributed without any warranty.
--
--  You should have received a copy of the CC0 Public Domain
--  Dedication along with this software. If not, see
--  <http://creativecommons.org/publicdomain/zero/1.0/>.
--
----------------------------------------------------------------

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
  SELECT MAX ( id ) + 1 AS id FROM dummy;


----------------------------------------------------------------
-- Data
----------------------------------------------------------------

INSERT INTO dummy ( id, name, amount ) VALUES ( 1, "a", 1 );
INSERT INTO dummy ( id, name, amount ) VALUES ( 2, "b", 2 );
INSERT INTO dummy ( id, name, amount ) VALUES ( 3, "c", 3 );

