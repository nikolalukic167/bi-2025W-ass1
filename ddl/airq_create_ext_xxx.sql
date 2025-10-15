-- please remember to give a meaningful name to both Table X (instead of tb_x) and TableY (instead of tb_y)

-- Make the A1's stg_xxx schema the default for this session
SET search_path TO stg_xxx;

-- -------------------------------
-- 2) DROP TABLE before attempting to create OLTP snapshot tables
-- -------------------------------
DROP TABLE IF EXISTS tb_y;
DROP TABLE IF EXISTS tb_x;

-- give a meaningful name and create Table X
CREATE TABLE tb_x (
    id INT NOT NULL PRIMARY KEY
    -- the other columns here
);

-- give a meaningful name and create Table Y
CREATE TABLE tb_y (
    id INT NOT NULL PRIMARY KEY
    -- the other columns here
	-- remember to implement foreign keys correctly
);


