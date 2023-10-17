CREATE OR REPLACE VIEW auth.v_user2role AS
SELECT ur.user_id,
       ur.role_id,
       u.user_name,
       r.user_name AS role_name,
       u.enabled   AS user_enabled,
       r.enabled   AS role_enabled
FROM ((auth.user2role ur
    JOIN auth.user_ u ON u.user_id = ur.user_id)
    LEFT JOIN auth.user_ r ON r.user_id = ur.role_id);