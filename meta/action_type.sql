CREATE TABLE auth.action_type (
	type_id integer NOT NULL,
	type_name text
);

ALTER TABLE auth.action_type OWNER TO postgres;

--------------------------------------------------------------------------------

ALTER TABLE auth.action_type
	ADD CONSTRAINT action_type_type_name_key UNIQUE (type_name);

--------------------------------------------------------------------------------

ALTER TABLE auth.action_type
	ADD CONSTRAINT action_type_pkey PRIMARY KEY (type_id);
