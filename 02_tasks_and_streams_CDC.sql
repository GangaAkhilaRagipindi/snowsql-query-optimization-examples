CREATE OR REPLACE STREAM customer_changes_strm 
ON TABLE DEMO_DB.PUBLIC.CUSTOMERS;

CREATE OR REPLACE TASK process_customer_cdc_tsk
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = '15 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('customer_changes_strm')
AS
  MERGE INTO DEMO_DB.ANALYTICS.DIM_CUSTOMERS target
  USING customer_changes_strm source
    ON target.customer_id = source.customer_id
  WHEN MATCHED AND source.metadata$action = 'DELETE' THEN 
    DELETE
  WHEN MATCHED AND source.metadata$action = 'INSERT' AND source.metadata$isupdate THEN 
    UPDATE SET target.first_name = source.first_name, target.last_name = source.last_name
  WHEN NOT MATCHED AND source.metadata$action = 'INSERT' THEN 
    INSERT (customer_id, first_name, last_name, status) 
    VALUES (source.customer_id, source.first_name, source.last_name, source.status);

ALTER TASK process_customer_cdc_tsk RESUME;
