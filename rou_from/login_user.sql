CREATE OR REPLACE FUNCTION kp_api_ui.login_user(app_user TEXT,
                                                pass     TEXT) RETURNS json
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_role                 name;
    v_user_id              NUMERIC(19);
    v_user_name            VARCHAR(255);
    v_blocked              BOOLEAN;
    v_type_id              BIGINT;
    v_failed_login         BIGINT;
    v_password_expire      BOOLEAN;
    v_date_change_password DATE;
    v_ip_address           VARCHAR(15);
    result                 kp_core.jwt_token;
BEGIN
    -- Check email and password
    SELECT user_id,
           user_name,
           db_role,
           is_blocked,
           type_id,
           failed_login,
           password_expire,
           date_change_password,
           ip_address
    INTO v_user_id, v_user_name, v_role, v_blocked, v_type_id,
        v_failed_login, v_password_expire, v_date_change_password, v_ip_address
    FROM kp_core.user_role(app_user, pass);

    PERFORM SET_CONFIG('kp_context.app_id', '1', FALSE);
    PERFORM SET_CONFIG('kp_ui.app_type_id', '1', FALSE);
    IF v_role IS NULL THEN
        CALL kp_core.failed_login(app_user);
        CALL obj_mgr.audit_user_login('Панель администрирования',
                                      NULL,
                                      kp_core.get_ip_address_client(),
                                      1,
                                      app_user || '- invalid user or password',
                                      '1'::VARCHAR);
        CALL err_mgr.raise_error('The username or password you entered is incorrect',
                                 'The username or password you entered is incorrect', 500);
    END IF;

    IF v_type_id NOT IN (1, 2) THEN
        CALL kp_core.failed_login(app_user);
        CALL obj_mgr.audit_user_login('Панель администрирования',
                                      NULL,
                                      kp_core.get_ip_address_client(),
                                      1,
            --app_user || '- access denied in the admin panel',
                                      app_user || '- Доступ запрещен в панели администрирования',
                                      '1'::VARCHAR);
        -- RAISE EXCEPTION 'access denied in the admin panel';
        RAISE EXCEPTION 'Доступ запрещен в панели администрирования';
    END IF;

    IF v_blocked THEN
        CALL obj_mgr.audit_user_login('Панель администрирования',
                                      NULL,
                                      kp_core.get_ip_address_client(),
                                      2,
                                      app_user || '- blocked',
                                      '1'::VARCHAR);
        RAISE EXCEPTION 'user blocked';
    END IF;

    IF v_password_expire THEN
        CALL obj_mgr.audit_user_login('Панель администрирования',
                                      NULL,
                                      kp_core.get_ip_address_client(),
                                      2,
                                      app_user || '- password expire',
                                      '1'::VARCHAR);
        RAISE EXCEPTION 'user blocked';
    END IF;

    IF v_ip_address IS NOT NULL AND v_ip_address <> kp_core.get_ip_address_client() THEN
        CALL obj_mgr.audit_user_login('Панель администрирования',
                                      NULL,
                                      kp_core.get_ip_address_client(),
                                      2,
                                      app_user || '- invalid ip address',
                                      '1'::VARCHAR);
        RAISE EXCEPTION 'invalid ip address';
    END IF;
    -- Create and sign token
    SELECT SIGN(
                   ROW_TO_JSON(r), CURRENT_SETTING('app.settings.jwt_secret')
               ) AS token
    FROM (SELECT v_role                                                AS role,
                 login_user.app_user                                   AS app_user,
                 '1'                                                   AS app_type,
                 v_type_id                                             AS app_user_type_id,
                 EXTRACT(EPOCH FROM NOW())::INTEGER +
                 (kp_core.get_code('jwt_liftime', '60')::INTEGER * 60) AS exp) r
    INTO result;
    CALL obj_mgr.audit_user_login('Панель администрирования'::VARCHAR,
                                  v_user_id::BIGINT,
                                  kp_core.get_ip_address_client()::VARCHAR,
                                  0::INTEGER,
                                  'Ок'::VARCHAR,
                                  '1'::VARCHAR);
    RETURN JSON_BUILD_OBJECT('token', result.token);
END
$$;

ALTER FUNCTION kp_api_ui.login_user(app_user TEXT, pass TEXT) OWNER TO postgres;

REVOKE ALL ON FUNCTION kp_api_ui.login_user(app_user TEXT, pass TEXT) FROM PUBLIC;
GRANT ALL ON FUNCTION kp_api_ui.login_user(app_user TEXT, pass TEXT) TO anon_user;
