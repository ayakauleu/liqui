CREATE OR REPLACE FUNCTION kp_api_ui.change_password(app_user text, pass text, pass_new text) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
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
    INTO v_user_id,
        v_user_name,
        v_role,
        v_blocked,
        v_type_id,
        v_failed_login,
        v_password_expire,
        v_date_change_password,
        v_ip_address
    FROM kp_core.user_role(app_user, pass);
    IF v_role IS NULL THEN
        CALL kp_core.failed_login(app_user);
        CALL obj_mgr.audit_user_login('UI',
                                      NULL,
                                      kp_core.get_ip_address_client(),
                                      1,
                                      app_user || '- неверный логин или пароль');
        CALL err_mgr.raise_error('The username or password you entered is incorrect');
    END IF;

    IF v_blocked THEN
        CALL obj_mgr.audit_user_login('UI',
                                      NULL,
                                      kp_core.get_ip_address_client(),
                                      2,
                                      app_user || '- заблокирован');
        CALL err_mgr.raise_error('The user is blocked.');
    END IF;

    IF v_ip_address IS NOT NULL AND v_ip_address <> kp_core.get_ip_address_client() THEN
        CALL obj_mgr.audit_user_login('UI',
                                      NULL,
                                      kp_core.get_ip_address_client(),
                                      2,
                                      app_user || '- неверный IP адрес');
        CALL err_mgr.raise_error('The ip address is incorrect');
    END IF;
    --IF kp_core.verify_password(app_user, pass, pass_new) THEN
    UPDATE kp_core.user_ SET password = pass_new WHERE login = app_user;
    --END IF;
    RETURN JSON_BUILD_OBJECT('Result', 'Success');
--EXCEPTION
--    WHEN OTHERS THEN
--        CALL log_mgr.write_error('change_password', sqlerrm);
--        RAISE;
END;
$$;

ALTER FUNCTION kp_api_ui.change_password(app_user text, pass text, pass_new text) OWNER TO postgres;

REVOKE ALL ON FUNCTION kp_api_ui.change_password(app_user text, pass text, pass_new text) FROM PUBLIC;
GRANT ALL ON FUNCTION kp_api_ui.change_password(app_user text, pass text, pass_new text) TO anon_user;
GRANT ALL ON FUNCTION kp_api_ui.change_password(app_user text, pass text, pass_new text) TO web_user;