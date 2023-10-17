CREATE OR REPLACE FUNCTION kp_core.user_reset_password(p_login TEXT) RETURNS BOOLEAN
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_user_id      NUMERIC(19);
    v_email        TEXT;
    v_personal     VARCHAR(255);
    v_new_pass     TEXT := kp_core.gen_password();
    v_user_type_id kp_core.user_.type_id%TYPE;
    v_error_text   TEXT;
    v_send_success BOOLEAN;
BEGIN
    SELECT user_id, email, type_id, personal_num
    INTO v_user_id, v_email, v_user_type_id, v_personal
    FROM kp_core.user_
    WHERE LOWER(login) = LOWER(p_login);
    UPDATE kp_core.user_ SET password = crypto_mgr.sha256(v_new_pass) WHERE user_id = v_user_id;
    PERFORM obj_mgr.audit(13, FORMAT('Пользователю %s был сброшен пароль', p_login));
    BEGIN
        SELECT p_error_text, result
        INTO v_error_text, v_send_success
        FROM utl_notify.send_password_to_email(FALSE, v_user_type_id::INTEGER, v_email, p_login, v_new_pass);
        CALL obj_mgr.audit_action(13, v_user_id::VARCHAR, NULL::xml, NULL::xml, 'user_', 0, NULL::BIGINT,
                                  'Сообщение о регистрации отправлено пользователю на адрес электронной почты ' ||
                                  v_email, p_supplier_id := v_personal::BIGINT);
    EXCEPTION
        WHEN OTHERS THEN
            CALL obj_mgr.audit_action(11, v_user_id::VARCHAR, NULL::xml, NULL::xml, 'user_', 1, NULL::BIGINT,
                                      sqlerrm, p_supplier_id := v_personal::BIGINT);
    END;
    RETURN TRUE;
END;
$$;

ALTER FUNCTION kp_core.user_reset_password(p_login TEXT) OWNER TO postgres;

REVOKE ALL ON FUNCTION kp_core.user_reset_password(p_login TEXT) FROM PUBLIC;
