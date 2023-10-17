CREATE SEQUENCE auth.user_user_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE auth.user_user_id_seq OWNER TO postgres;

ALTER SEQUENCE auth.user_user_id_seq
	OWNED BY auth."user".user_id;
