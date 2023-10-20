CREATE SEQUENCE auth.user_user_id_seq;

CREATE TABLE auth.user_ (
	user_id integer DEFAULT nextval('auth.user_user_id_seq'::regclass) NOT NULL,
	user_name text NOT NULL,
	user_kind_id integer NOT NULL,
	enabled boolean NOT NULL,
	type_id BIGINT REFERENCES auth.user_type (type_id)
);

ALTER TABLE auth.user_	ADD CONSTRAINT user_user_name_key UNIQUE (user_name);
ALTER TABLE auth.user_	ADD CONSTRAINT user_pkey PRIMARY KEY (user_id);

create or replace view ui.user_ as select u.*, t.type_name from auth.user_ u join auth.user_type t on t.type_id = u.type_id;
create or REPLACE view ui.user_type as select type_id, type_name from auth.user_type;