CREATE OR REPLACE FUNCTION auth.user_role(p_user_name TEXT)
    RETURNS TABLE
            (   role_id integer,
                role_name TEXT
            )
    LANGUAGE plpgsql
AS
$a$
BEGIN
    RETURN QUERY
        SELECT r.user_id, r.user_name
        FROM auth.user2role ur
                 JOIN auth.user_ r ON r.user_id = ur.role_id
                 JOIN auth.user_ u ON u.user_id = ur.user_id
        WHERE u.user_name = p_user_name;
END
$a$;