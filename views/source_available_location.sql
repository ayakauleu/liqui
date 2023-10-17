drop view ui.source_available_location;

CREATE or REPLACE VIEW ui.source_available_location AS
SELECT s2l.source_id, l.*
FROM core.source_available_location s2l
    join core.data_source s on s.id = s2l.source_id
join core.archive_location l on l.id = s2l.location_id;

GRANT DELETE, INSERT, SELECT, UPDATE ON ui.source_available_location TO ui_admin;

