CREATE OR REPLACE FUNCTION auth.user_check(p_user_id bigint) RETURNS VOID
    LANGUAGE plpgsql
    STABLE SECURITY DEFINER
AS
$$
DECLARE
    v_user auth.user_;
BEGIN

    SELECT * INTO v_user FROM auth.user_ WHERE user_id = p_user_id;
    IF v_user.user_id IS NULL THEN
        RAISE EXCEPTION 'invalid user';
    END IF;

    IF v_user.blocked THEN
        RAISE EXCEPTION 'user blocked';
    END IF;

    IF v_user.password_expire THEN
        RAISE EXCEPTION 'user password expired';
    END IF;
END;
$$;
