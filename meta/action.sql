CREATE TABLE auth.action (
	action_id integer DEFAULT nextval('auth.action_action_id_seq'::regclass) NOT NULL,
	action_name text NOT NULL,
	action_type_id integer,
	app_id integer,
	enabled boolean,
	method_id integer,
	entity_id integer
);

ALTER TABLE auth.action OWNER TO postgres;

--------------------------------------------------------------------------------

ALTER TABLE auth.action
	ADD CONSTRAINT action_method_id_fkey FOREIGN KEY (method_id) REFERENCES auth.action_method(method_id);

--------------------------------------------------------------------------------

ALTER TABLE auth.action
	ADD CONSTRAINT action_pkey PRIMARY KEY (action_id);
