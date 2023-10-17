create table auth.refresh_token (
    user_id integer primary key,
    token text NOT NULL UNIQUE,
    expiration timestamp NOT NULL
)