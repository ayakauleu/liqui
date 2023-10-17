CREATE OR REPLACE FUNCTION kp_core.failed_login_atx(p_login character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_max_failed_login VARCHAR(256);
BEGIN
    SELECT pp.property_value
    INTO v_max_failed_login
    FROM kp_core.password_property pp
    WHERE pp.property_name = 'max_failed_login';

    UPDATE kp_core.user_
    SET failed_login = CASE
                           WHEN coalesce(failed_login, 0) + 1 >= v_max_failed_login::INTEGER THEN failed_login
                           ELSE coalesce(failed_login, 0) + 1 END,
        blocked      = CASE
                           WHEN coalesce(failed_login, 0) + 1 >= v_max_failed_login::INTEGER AND coalesce(blocked, false) <> true THEN true
                           ELSE blocked END
    WHERE login = p_login;
    RETURN 0;
END ;
$$;

ALTER FUNCTION kp_core.failed_login_atx(p_login character varying) OWNER TO postgres;

REVOKE ALL ON FUNCTION kp_core.failed_login_atx(p_login character varying) FROM PUBLIC;
