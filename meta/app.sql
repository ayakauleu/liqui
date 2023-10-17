CREATE TABLE auth.app (
	app_id integer NOT NULL,
	app_name text NOT NULL,
	enabled boolean NOT NULL
);

ALTER TABLE auth.app OWNER TO postgres;

--------------------------------------------------------------------------------

ALTER TABLE auth.app
	ADD CONSTRAINT app_pkey PRIMARY KEY (app_id);
