CREATE or replace FUNCTION user_right(p_app_id         INTEGER,
                           p_user_id        INTEGER,
                           p_entity_type_id INTEGER,
                           p_entity_id      INTEGER DEFAULT NULL::INTEGER)
    RETURNS TABLE
            (
                action_id          INTEGER,
                action_name        TEXT,
                action_type_id     INTEGER,
                action_type_name   TEXT,
                action_method_id   INTEGER,
                action_method_name TEXT
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        WITH RECURSIVE users (user_id, role_id) AS (
            --user2role
            SELECT user_id, role_id, user_name, role_name, 1 ulevel, user_name path
            FROM (SELECT * FROM auth.v_user2role ur WHERE ur.user_id = p_user_id AND user_enabled AND role_enabled) t1
            UNION
            SELECT t1.user_id, t1.role_id, t1.user_name, t1.role_name, ulevel + 1, t1.user_name || '>' || path
            FROM users u
                     JOIN (SELECT * FROM auth.v_user2role ur WHERE user_enabled AND role_enabled) t1
                          ON u.role_id = t1.user_id)
        SELECT DISTINCT a.action_id, e.entity_name, t.type_id, t.type_name, m.method_id, m.method_name
        FROM (SELECT role_id FROM users ur UNION SELECT p_user_id) ur
                 JOIN auth.action2user au ON au.user_id = ur.role_id
                 JOIN auth.action a ON a.action_id = au.action_id
                 JOIN auth.entity_ref e ON e.entity_id = a.entity_id
                 JOIN auth.action_method m ON a.method_id = m.method_id
                 JOIN auth.action_type t ON a.action_type_id = t.type_id
                 JOIN auth.app ON app.app_id = a.app_id
        WHERE app.enabled
          AND a.enabled
          AND app.app_id = p_app_id
          AND a.entity_id = COALESCE(p_entity_id, a.entity_id)
          AND e.type_id = COALESCE(p_entity_type_id, e.type_id);
END
$$;
