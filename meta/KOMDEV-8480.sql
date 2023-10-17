ALTER TABLE core.request_search_payment
    ADD terminal_id   TEXT,
    ADD terminal_dept INTEGER,
    ADD auth_type     INTEGER;

ALTER TABLE core.request_search_payment_data
    ADD card_number   TEXT;

ALTER TABLE base_x.payment
    ADD auth_type INTEGER;

SELECT DISTINCT r.routine_schema, r.routine_name, r.routine_type, r.routine_definition
FROM information_schema.routines r
WHERE routine_definition ILIKE '%core.request_search_payment%'
ORDER BY r.routine_name;

CREATE or replace FUNCTION core.search_payment(p_id uuid) RETURNS boolean
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_request core.request_search_payment%ROWTYPE;
    v_offset  BIGINT;
BEGIN
    --    perform pg_sleep(15); -- Для разработке и отладке интерфейса. Убрать после тестирования
    SELECT *
    INTO v_request
    FROM core.request_search_payment
    WHERE id = p_id
      AND (date_response IS NULL OR error_text IS NOT NULL);
    v_offset := COALESCE(v_request.idx_on_second, 0);
    --v_request.row_limit := v_request.row_limit + v_offset;
    INSERT
    INTO core.request_search_payment_data
    SELECT p_id,
           source_id,
           archive_id,
           part_id,
           idx,
           payment_id,
           status,
           external_system_supplier_id,
           supplier_id,
           supplier_name,
           supplier_account,
           supplier_unp,
           external_system_service_code,
           service_code,
           service_name,
           service_shortname,
           budget_code,
           external_system_payer_id,
           payer_full_name,
           payer_doc,
           payer_address,
           payer_account,
           pay_date,
           pay_sum,
           pay_direction,
           penalty_sum,
           external_system_payment_id,
           external_system_name,
           terminal_id,
           terminal_dept,
           dept_filial,
           terminal_location,
           consolidated_doc_id,
           consolidated_doc_date,
           consolidated_doc_pay_string,
           consolidated_export_file_name,
           bank_bik,
           bank_name,
           payer_in,
           full_name_depositor,
           depositor_address,
           commission_sum,
           region,
           receipt_no,
           ROW_NUMBER() OVER (PARTITION BY pay_date ORDER BY payment_add_id),
           consolidated_doc_sum,
           currency
    FROM core.search_payment_remote(
            v_request.source_id, v_request.date_from, v_request.date_to,
            v_request.payment_id, v_request.payer_full_name, v_request.payer_in, v_request.payer_doc,
            v_request.payer_address, v_request.payer_account, v_request.supplier_name,
            v_request.supplier_account, v_request.bik, v_request.supplier_unp,
            v_request.budget_code, v_request.service_name, v_request.pay_sum_min,
            v_request.pay_sum_max, v_request.receipt_no, v_request.external_system_payment_id,
            v_request.prev_source_id, v_request.prev_date, v_request.row_limit,
            v_request.terminal_id, v_request.terminal_dept, v_request.auth_type)
    ORDER BY pay_date, payment_add_id
    OFFSET v_offset LIMIT v_request.row_limit;
    UPDATE core.request_search_payment
    SET date_response=core.current_server_timestamp(),
        error_text   = NULL
    WHERE id = p_id;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        UPDATE core.request_search_payment
        SET error_text   = sqlerrm,
            date_response=core.current_server_timestamp()
        WHERE id = p_id;
        RETURN FALSE;
END;
$$;

CREATE or replace FUNCTION core.search_payment_remote(p_source_id integer, p_date_from timestamp without time zone, p_date_to timestamp without time zone, p_payment_id bigint, p_payer_full_name text, p_payer_in text, p_payer_doc text, p_payer_address text, p_payer_account text, p_supplier_name text, p_supplier_account text, p_bik text, p_supplier_unp text, p_budget_code integer, p_service_name text, p_pay_sum_min numeric, p_pay_sum_max numeric, p_receipt_no text, p_external_system_payment_id text, p_prev_source_id integer, p_prev_date timestamp without time zone, p_limit integer, p_terminal_id text, p_terminal_dept integer, p_auth_type integer)
    RETURNS TABLE(source_id integer, archive_id bigint, part_id bigint, idx bigint, payment_id bigint, status integer, external_system_supplier_id bigint, supplier_id bigint, supplier_name text, supplier_account text, supplier_unp text, external_system_service_code text, service_code bigint, service_name text, service_shortname text, budget_code integer, external_system_payer_id bigint, payer_full_name text, payer_doc text, payer_address text, payer_account text, pay_date timestamp without time zone, pay_sum numeric, pay_direction integer, penalty_sum numeric, external_system_payment_id text, external_system_name text, terminal_id text, terminal_dept integer, dept_filial integer, terminal_location text, consolidated_doc_id bigint, consolidated_doc_date date, consolidated_doc_pay_string text, consolidated_export_file_name text, bank_bik text, bank_name text, payer_in text, full_name_depositor text, depositor_address text, commission_sum numeric, region text, receipt_no text, consolidated_doc_sum numeric, currency integer, payment_add_id bigint, card_number text)
    LANGUAGE plproxy
AS
$$
CLUSTER plproxy.map_cluster(p_source_id);
run on all;
target base_x.search_payment_set;
$$;



GRANT EXECUTE ON FUNCTION core.search_payment_remote TO handler_search;
revoke EXECUTE ON FUNCTION ui.search_payment from handler_search;

