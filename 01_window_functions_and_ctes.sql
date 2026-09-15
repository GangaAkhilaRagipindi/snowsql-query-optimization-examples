WITH CustomerSales AS (
    SELECT 
        c.customer_id,
        c.region,
        s.sale_amount,
        s.sale_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.region 
            ORDER BY s.sale_amount DESC
        ) AS sales_rank
    FROM DEMO_DB.PUBLIC.CUSTOMERS c
    JOIN DEMO_DB.PUBLIC.SALES s 
      ON c.customer_id = s.customer_id
    WHERE s.sale_date >= DATEADD('month', -6, CURRENT_DATE())
)
SELECT region, customer_id, sale_amount, sale_date
FROM CustomerSales
WHERE sales_rank <= 3
ORDER BY region, sales_rank;
