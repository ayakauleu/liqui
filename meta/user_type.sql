CREATE TABLE auth.user_type
(
    type_id   BIGINT       NOT NULL
        CONSTRAINT pk_user_type_id
            PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL,
    db_role   VARCHAR(255)
);

COMMENT ON TABLE auth.user_type IS 'Типы клиентов';
COMMENT ON COLUMN auth.user_type.type_id IS 'ID типа (1-администратор / 2 - пользователь)';
COMMENT ON COLUMN auth.user_type.type_name IS 'Наименование типа';
COMMENT ON COLUMN auth.user_type.db_role IS 'Описание';