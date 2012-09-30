----------------------------------------------------------------
--
--  system.sql
--  The schema for all the read only data in the game.
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

-- Splash Screens
DROP TABLE IF EXISTS splash_screens;
CREATE TABLE IF NOT EXISTS splash_screens (
  resolution   INTEGER,
  portrait     INTEGER,
  priority     INTEGER,
  image        VARCHAR ( 32 ),
  display_time REAL,
  fade_time    REAL,
  PRIMARY KEY ( priority, portrait, resolution )
);

-- Supported Screen Resolutions
DROP TABLE IF EXISTS texture_resolution_list;
CREATE TABLE IF NOT EXISTS texture_resolution_list (
  resolution INTEGER,
  PRIMARY KEY ( resolution )
);
DROP VIEW IF EXISTS max_texture_resolution;
CREATE VIEW IF NOT EXISTS max_texture_resolution AS
        SELECT MAX ( resolution ) AS resolution FROM texture_resolution_list;
DROP VIEW IF EXISTS min_texture_resolution;
CREATE VIEW IF NOT EXISTS min_texture_resolution AS
        SELECT MIN ( resolution ) AS resolution FROM texture_resolution_list;

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

-- Splash Screens
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 2048, 0, 0, "fade.png",                          0.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 2048, 0, 1, "splash_sennue_horizontal@2048.png", 2.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 2048, 0, 2, "splash_moai_horizontal@2048.png",   2.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 2048, 0, 9, "fade.png",                          0.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 2048, 1, 0, "fade.png",                          0.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 2048, 1, 1, "splash_sennue_vertical@2048.png",   2.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 2048, 1, 2, "splash_moai_vertical@2048.png",     2.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 2048, 1, 9, "fade.png",                          0.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 1024, 1, 0, "fade.png",                          0.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 1024, 1, 1, "splash_sennue_vertical@2048.png",   2.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 1024, 1, 2, "splash_moai_vertical@2048.png",     2.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES ( 1024, 1, 9, "fade.png",                          0.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES (  512, 1, 0, "fade.png",                          0.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES (  512, 1, 1, "splash_sennue_vertical@2048.png",   2.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES (  512, 1, 2, "splash_moai_vertical@2048.png",     2.00, 0.50 );
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time ) VALUES (  512, 1, 9, "fade.png",                          0.00, 0.50 );

-- List of Texture Resolutions
INSERT INTO texture_resolution_list ( resolution ) VALUES (  512 );
INSERT INTO texture_resolution_list ( resolution ) VALUES ( 1024 );
INSERT INTO texture_resolution_list ( resolution ) VALUES ( 2048 );

