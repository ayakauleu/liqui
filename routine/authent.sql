CREATE OR REPLACE FUNCTION auth.token(p_client_id     INTEGER,
                                      p_grant_type    TEXT,
                                      p_user_name     TEXT,
                                      p_password      TEXT,
                                      p_refresh_token TEXT) RETURNS json
AS
$$
DECLARE
    v_access_exp                TIMESTAMP := core.current_server_timestamp() + INTERVAL '15 minutes';
    v_refresh_exp               TIMESTAMP := core.current_server_timestamp() + INTERVAL '105 days';
    v_secret                    TEXT      := CURRENT_SETTING('app.settings.jwt_secret');
    v_user_id                   BIGINT;
    v_type_id                   BIGINT;
    v_access_token              json;
    v_refresh_token             json;
    v_access_signed             TEXT;
    v_refresh_signed            TEXT;
    v_refresh_stored            TEXT;
    v_refresh_stored_payload    jsonb;
    v_refresh_stored_expiration BIGINT;
    v_refresh_stored_valid      BOOLEAN;
BEGIN
    IF LOWER(p_grant_type) = 'password' THEN
        SELECT user_id
        INTO v_user_id
        FROM auth.user_
        WHERE LOWER(login) = LOWER(p_user_name)
          AND p_password = password;
        IF v_user_id IS NULL THEN
            RAISE 'Ќеверный логин или пароль';
        END IF;
    ELSE
        SELECT payload, valid
        INTO v_refresh_stored_payload, v_refresh_stored_valid
        FROM verify(p_refresh_token, v_secret);
        IF NOT v_refresh_stored_valid THEN
            RAISE 'Refresh token is not valid';
        END IF;

        v_user_id := v_refresh_stored_payload['user_id']::BIGINT;
        SELECT t.token INTO v_refresh_stored FROM auth.refresh_token t WHERE user_id = v_user_id;

        IF p_refresh_token != v_refresh_stored THEN
            RAISE 'Refresh token sent and refresh token stored are not equal';
        END IF;

        v_refresh_stored_expiration := v_refresh_stored_payload['exp']::BIGINT;
        IF v_refresh_stored_expiration < EXTRACT(EPOCH FROM core.current_server_timestamp())::INTEGER THEN
            RAISE 'Refresh token expired';
        END IF;
    END IF;

    PERFORM auth.user_check(v_user_id);

    SELECT type_id
    INTO v_type_id
    FROM auth.user_
    WHERE user_id = v_user_id;
    IF v_type_id <> p_client_id THEN
        RAISE 'ѕользователю этой роли недоступно это приложение';
    END IF;

    v_access_token := auth.access_token_compose(v_user_id, v_access_exp);
    v_refresh_token := auth.refresh_token_compose(v_user_id, v_refresh_exp);

    v_access_signed := SIGN(v_access_token, v_secret);
    v_refresh_signed := SIGN(v_refresh_token, v_secret);

    INSERT INTO auth.refresh_token(user_id, token, expiration)
    VALUES (v_user_id, v_refresh_signed, v_access_exp)
    ON CONFLICT(user_id) DO UPDATE SET token = v_refresh_signed, expiration = v_access_exp;

    RETURN JSON_BUILD_OBJECT('access_token', v_access_signed, 'refresh_token', v_refresh_signed, 'expires_in',
                             EXTRACT(EPOCH FROM v_access_exp)::INTEGER);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ui.token(client_id     INTEGER,
                                    grant_type    TEXT,
                                    user_name     TEXT DEFAULT NULL,
                                    password      TEXT DEFAULT NULL,
                                    refresh_token TEXT DEFAULT NULL) RETURNS json
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    RETURN auth.token(client_id, grant_type, user_name, password, refresh_token);
EXCEPTION
    WHEN OTHERS THEN RETURN JSON_BUILD_OBJECT('error_code', 404, 'error_text', sqlerrm);
END;
$$;