CREATE OR REPLACE FUNCTION kp_api_ui.reset_password(p_login text) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_reset boolean;
    v_result text;
BEGIN
    v_reset := kp_core.user_reset_password(p_login);
    v_result := case when v_reset then 'Success' else 'Error' end;
    RETURN JSON_BUILD_OBJECT('Result', v_result);
END;
$$;

ALTER FUNCTION kp_api_ui.reset_password(p_login text) OWNER TO postgres;

REVOKE ALL ON FUNCTION kp_api_ui.reset_password(p_login text) FROM PUBLIC;
GRANT ALL ON FUNCTION kp_api_ui.reset_password(p_login text) TO anon_user;
GRANT ALL ON FUNCTION kp_api_ui.reset_password(p_login text) TO web_user;
