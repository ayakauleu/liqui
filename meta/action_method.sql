CREATE TABLE auth.action_method (
	method_id integer NOT NULL,
	method_name text
);

ALTER TABLE auth.action_method OWNER TO postgres;

--------------------------------------------------------------------------------

ALTER TABLE auth.action_method
	ADD CONSTRAINT action_method_pkey PRIMARY KEY (method_id);
