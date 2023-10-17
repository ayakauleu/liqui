CREATE OR REPLACE FUNCTION kp_core.verify_password(p_login character varying, p_pass character varying, p_new_pass character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_record  RECORD;
    --v_isdigit BOOLEAN;
    --v_ischar  BOOLEAN;
    --v_ispunct BOOLEAN;
    --v_m       INTEGER;
    --v_differ  INTEGER;
    v_ph      RECORD;
    v_rec_id  INTEGER;
BEGIN
    FOR v_record IN SELECT *
                    FROM kp_core.password_property t
                    WHERE t.property_name IN (
                                              'differcount',
                                              'interval_change_password',
                                              'digitarray',
                                              'minlength',
                                              'simplewordarray',
                                              'chararray',
                                              'can_as_name',
                                              'punctarray',
                                              'password_reuse_max')
        LOOP
            /*IF v_record.property_name = 'differcount' AND v_record.property_value IS NOT NULL THEN
                -- Check if the password differs from the previous password by at least
                -- 3 letters
                IF p_pass IS NOT NULL THEN
                    v_differ := LENGTH(p_pass) - LENGTH(p_new_pass);

                    IF ABS(v_differ) < v_record.property_value::INTEGER THEN
                        IF LENGTH(p_new_pass) < LENGTH(p_pass) THEN
                            v_m := LENGTH(p_new_pass);
                        ELSE
                            v_m := LENGTH(p_pass);
                        END IF;

                        v_differ := ABS(v_differ);
                        FOR i IN 1 .. v_m LOOP
                            IF SUBSTR(p_new_pass, i, 1) != SUBSTR(p_pass, i, 1) THEN
                                v_differ := v_differ + 1;
                            END IF;
                        END LOOP;

                        IF v_differ < COALESCE(v_record.property_value::INTEGER, 0) THEN
                            RAISE EXCEPTION 'Новый пароль должен отличаться от старого как минимум на % знака.', v_record.property_value;
                        END IF;
                    END IF;
                END IF;
            ELSIF v_record.property_name = 'interval_change_password' AND v_record.property_value IS NOT NULL THEN
                NULL;
            ELSIF v_record.property_name = 'digitarray' AND v_record.property_value IS NOT NULL THEN
                -- Check if the password contains at least one letter, one digit and one
                -- punctuation mark.
                -- 1. Check for the digit
                v_isdigit := FALSE;
                v_m := LENGTH(p_new_pass);
                FOR i IN 1 .. 10 LOOP
                    FOR j IN 1 .. v_m LOOP
                        IF SUBSTR(p_new_pass, j, 1) = SUBSTR(v_record.property_value, i, 1) THEN
                            v_isdigit := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                    IF v_isdigit THEN
                        EXIT;
                    END IF;
                END LOOP;
                IF v_isdigit = FALSE THEN
                    RAISE EXCEPTION 'Пароль должен содержать как минимум одну цифру.';
                END IF;
            ELSIF v_record.property_name = 'minlength' AND v_record.property_value IS NOT NULL THEN
                -- Check for the minimum length of the password
                IF v_record.property_value::INTEGER > 0 AND LENGTH(p_new_pass) < v_record.property_value::INTEGER THEN
                    RAISE EXCEPTION 'Длина пароля должна быть не меньше %', v_record.property_value;
                END IF;
            ELSIF v_record.property_name = 'simplewordarray' AND v_record.property_value IS NOT NULL THEN
                IF instr(v_record.property_value, '''' || LOWER(p_new_pass) || '''') > 0
                THEN
                    RAISE EXCEPTION 'Очень простой пароль.';
                END IF;
            ELSIF v_record.property_name = 'chararray' AND v_record.property_value IS NOT NULL THEN
                -- 2. Check for the character
                v_ischar := FALSE;
                v_m := LENGTH(p_new_pass);
                FOR i IN 1 .. LENGTH(v_record.property_value) LOOP
                    FOR j IN 1 .. v_m LOOP
                        IF SUBSTR(p_new_pass, j, 1) = SUBSTR(v_record.property_value, i, 1) THEN
                            v_ischar := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                    IF v_ischar THEN
                        EXIT;
                    END IF;
                END LOOP;

                IF v_ischar = FALSE THEN
                    RAISE EXCEPTION 'Пароль должен содержать как минимум один символ латинского алфавита.';
                END IF;
            ELSIF v_record.property_name = 'can_as_name' AND v_record.property_value IS NOT NULL THEN
                -- Check if the password is same as the username
                IF COALESCE(v_record.property_value::INTEGER, 0) = 0 AND
                   LOWER(TRIM(p_login)) = LOWER(TRIM(p_new_pass)) THEN
                    RAISE EXCEPTION 'Пароль не должен быть таким же как имя.';
                END IF;
            ELSIF v_record.property_name = 'punctarray' AND v_record.property_value IS NOT NULL THEN
                -- 3. Check for the punctuation
                v_ispunct := FALSE;
                v_m := LENGTH(p_new_pass);
                FOR i IN 1 .. LENGTH(v_record.property_value) LOOP
                    FOR j IN 1 .. v_m LOOP
                        IF SUBSTR(p_new_pass, j, 1) = SUBSTR(v_record.property_value, i, 1) THEN
                            v_ispunct := TRUE;
                            EXIT;
                        END IF;
                    END LOOP;
                    IF v_ispunct THEN
                        EXIT;
                    END IF;
                END LOOP;

                IF v_ispunct = FALSE THEN
                    RAISE EXCEPTION 'Пароль должен содержать как минимум один из символов %.', v_record.property_value;
                END IF;
            ELSIF v_record.property_name = 'password_reuse_max' AND v_record.property_value IS NOT NULL THEN
                v_rec_id := 0;
                FOR v_ph IN SELECT t.password, crypt(p_new_pass, t.password) new_pass
                            FROM kp_core.user_password_history t,
                                 kp_core.user_ c
                            WHERE t.user_id = c.user_id
                              AND LOWER(c.login) = LOWER(p_login)
                            ORDER BY t.cancellation_date DESC NULLS FIRST
                    LOOP
                        IF v_ph.password = v_ph.new_pass AND v_rec_id >= v_record.property_value::INTEGER THEN
                            RAISE EXCEPTION 'Такой пароль уже был';
                        END IF;
                        v_rec_id := v_rec_id + 1;
                    END LOOP;
            END IF;*/
            IF v_record.property_name = 'password_reuse_max' AND v_record.property_value IS NOT NULL THEN
                v_rec_id := 0;
                FOR v_ph IN SELECT LOWER(t.password) AS pass, LOWER(p_new_pass) new_pass
                            FROM kp_core.user_password_history t,
                                 kp_core.user_ c
                            WHERE t.user_id = c.user_id
                              AND LOWER(c.login) = LOWER(p_login)
                            ORDER BY t.cancellation_date DESC NULLS FIRST
                    LOOP
                        IF v_ph.pass = v_ph.new_pass AND v_rec_id >= v_record.property_value::INTEGER THEN
                            RAISE EXCEPTION 'Такой пароль уже был';
                        END IF;
                        v_rec_id := v_rec_id + 1;
                    END LOOP;
            END IF;
        END LOOP;
    RETURN TRUE;
END ;
$$;

ALTER FUNCTION kp_core.verify_password(p_login character varying, p_pass character varying, p_new_pass character varying) OWNER TO postgres;

REVOKE ALL ON FUNCTION kp_core.verify_password(p_login character varying, p_pass character varying, p_new_pass character varying) FROM PUBLIC;
