--liquibase formatted sql
--changeset yakauleu:1 runonchange:true splitStatements:false

CREATE OR REPLACE VIEW kp_api_ui.role AS
SELECT *
FROM auth.user u
where user_kind_id = 2;

GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE kp_api_ui.role TO web_user;

CREATE OR REPLACE FUNCTION kp_api_ui.crud_role() RETURNS TRIGGER
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
BEGIN
    PERFORM kp_api_ui.ui_dml_before();

    IF (tg_op = 'INSERT') THEN
        INSERT INTO auth.user(enabled, user_name, user_kind_id)
        VALUES (new.enabled, new.user_name, 2)
        RETURNING user_id INTO new.user_id;

    ELSIF (tg_op = 'UPDATE') THEN
        UPDATE auth.user
        SET enabled      = new.enabled,
            user_name    = new.user_name
        WHERE user_id = old.user_id;

    ELSIF (tg_op = 'DELETE') THEN
        DELETE FROM auth.user WHERE user_id = old.user_id;
    END IF;

    RETURN CASE tg_op WHEN 'DELETE' THEN old ELSE new END;
END
$$;

REVOKE ALL ON FUNCTION kp_api_ui.crud_user_() FROM PUBLIC;

DROP TRIGGER IF EXISTS crud_role ON kp_api_ui.role;
CREATE TRIGGER crud_role
    INSTEAD OF INSERT OR UPDATE OR DELETE
    ON kp_api_ui.role
    FOR EACH ROW
EXECUTE FUNCTION kp_api_ui.crud_role();