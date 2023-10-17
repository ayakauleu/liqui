CREATE OR REPLACE FUNCTION kp_api_ui.logout_user() RETURNS json
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    PERFORM obj_mgr.audit(5, '');
    RETURN JSON_BUILD_OBJECT('Success', TRUE);
END
$$;

REVOKE ALL ON FUNCTION kp_api_ui.logout_user FROM PUBLIC;
GRANT  ALL ON FUNCTION kp_api_ui.logout_user TO web_user;