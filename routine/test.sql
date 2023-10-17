--liquibase formatted sql
--changeset andrei:2 runOnChange:true splitStatements:false

CREATE OR REPLACE FUNCTION auth.access_token_check_test() RETURNS VOID
    LANGUAGE plpgsql
    SECURITY DEFINER
--commented
AS
$$
DECLARE
    v_app_name   TEXT;
    v_ip_address TEXT;
    v_app_user   TEXT;
    v_user_id    BIGINT;
BEGIN
    -- Get client ip-address
    v_ip_address := COALESCE(CURRENT_SETTING('request.headers', TRUE)::json ->> 'x-forwarded-for',
                             NULLIF(HOST(INET_CLIENT_ADDR()), '::1'), '127.0.0.1')::TEXT;
    -- Get user login
    v_app_user := (CURRENT_SETTING('request.jwt.claims', TRUE)::jsonb)->>'app_user';

    IF NULLIF(v_app_user, '') IS NOT NULL THEN
        v_user_id := auth.user_check(v_app_user);
        v_app_name := 'kp_api_ui_' || v_app_user || '/' || v_ip_address;
        --       CALL dbms_application_info.set_action(v_app_name);
        PERFORM SET_CONFIG('kp_context.ip_address', v_ip_address, FALSE);
        PERFORM SET_CONFIG('kp_context.user_id', v_user_id, FALSE);
        PERFORM SET_CONFIG('kp_context.app_name', '������ �����������������', FALSE);
        PERFORM SET_CONFIG('kp_context.app_id', '1', FALSE);
    END IF;

END
$$;