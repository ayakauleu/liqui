CREATE SEQUENCE auth.action_action_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE auth.action_action_id_seq OWNER TO postgres;

ALTER SEQUENCE auth.action_action_id_seq
	OWNED BY auth.action.action_id;
