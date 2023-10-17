CREATE SCHEMA auth;
ALTER SCHEMA auth OWNER TO postgres;

CREATE ROLE anon_user NOLOGIN;
GRANT anon_user TO authenticator;
REVOKE SELECT, INSERT, UPDATE, DELETE ON ui.user_ FROM anon_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ui.user_ TO anon_user;

CREATE ROLE ui_admin NOLOGIN;
GRANT ui_admin TO authenticator;
GRANT USAGE ON SCHEMA ui TO ui_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ui.user_ TO ui_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ui.data_source TO ui_admin;
GRANT SELECT ON ui.user_type TO ui_admin;

CREATE ROLE ui_user NOLOGIN;
GRANT ui_user TO authenticator;
GRANT USAGE ON SCHEMA ui TO ui_user;

CREATE ROLE ui_auth_viewer NOLOGIN;
GRANT ui_auth_viewer TO authenticator;
GRANT USAGE ON SCHEMA ui TO ui_auth_viewer;
GRANT USAGE ON SCHEMA auth TO ui_auth_viewer;
GRANT SELECT ON ui.user_ TO ui_auth_viewer;