CREATE TABLE auth.entity_ref (
	entity_id integer NOT NULL,
	entity_schema text,
	entity_name text,
	entity_caption text,
	type_id integer DEFAULT 1
);

ALTER TABLE auth.entity_ref OWNER TO postgres;

--------------------------------------------------------------------------------

ALTER TABLE auth.entity_ref
	ADD CONSTRAINT entity_ref_pkey PRIMARY KEY (entity_id);
