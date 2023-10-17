--liquibase formatted sql

--changeset andrei:KOMDEV-7692
--comment Soedinyaya
alter table release.sql add column create_date timestamp DEFAULT kp_core.current_server_timestamp();
--changeset andrei:KOMDEV-7692-NN
alter table release.sql alter column sql_body set not null;

--changeset andrei:KOMDEV-7692-N
alter table release.sql add constraint ch_sql_not_empty CHECK ( trim(sql_body) <> '' );

--changeset andrei:KOMDEV-7692-N
alter table release.sql add customer_id integer REFERENCES release.customer(customer_id);