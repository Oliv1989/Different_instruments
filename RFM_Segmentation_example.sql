CREATE TABLE sandbox.table_1 (
	SEGMENT_DATE DATE NOT NULL,
	PHONE VARCHAR(50) NOT NULL,
	RECENCY BIGINT NULL,
	MONETARY FLOAT NULL,
	FREQUENCY BIGINT NULL,
	R_SCORE FLOAT NULL,
	F_SCORE FLOAT NULL,
	M_SCORE FLOAT NULL,
	RFM_SEGMENT VARCHAR(50) NULL
	)

CREATE table sandbox.table_2 (
	SEGMENT_DATE DATE NOT NULL,
	PHONE VARCHAR(50) NOT NULL,
	RECENCY BIGINT NULL,
	MONETARY FLOAT NULL,
	FREQUENCY BIGINT NULL,
	R_SCORE FLOAT NULL,
	F_SCORE FLOAT NULL,
	M_SCORE FLOAT NULL,
	RFM_SEGMENT VARCHAR(50) NULL,
	RFM_SEGMENT_CHANGING VARCHAR(50) NULL
	)

	
DECLARE @i datetime = cast('12/1/2021' as datetime);

WHILE @i < cast('3/1/2023' as datetime)
BEGIN
    SET @i = DATEADD(MONTH,1,@i);
    
WITH rfm_raw AS (     
    SELECT phone,
          DATEDIFF(day,MAX(DATE_INSERT),@i) AS R,
          COUNT(id) AS F,
          sum(REVENUE) AS M
      FROM prod.sales v
      where v.DATE_INSERT >= '2020-01-01 00:00:00.0000000' and v.DATE_INSERT < @i
      and phone is not null and phone<>''
      and v.sale_channel in ('Channel1','Channel2','Channel3')
      and v.status_id = 'F'
      GROUP BY phone
     ),
     calc_rfm AS (
      SELECT r.*,
             cast(NTILE(5) OVER (ORDER BY R desc,M asc,F asc) as float) as R_S,
             cast(NTILE(5) OVER (ORDER BY F asc,M asc,R desc) as float) as F_S,
             cast(NTILE(5) OVER (ORDER BY M asc,F asc,R desc) as float) as M_S
      FROM rfm_raw r  
     )

INSERT INTO sandbox.table_1
SELECT
@i as SEGMENT_DATE,
rfm.PHONE,
rfm.r as recency,
rfm.m as monetary,
rfm.f as frequency,
rfm.r_s as r_score,
rfm.f_s as f_score,
rfm.m_s as m_score,
       (CASE WHEN rfm.r_s >= 5 AND (rfm.f_s + rfm.m_s)/2>=5 THEN 'Champions'
             WHEN rfm.r_s >= 3 AND (rfm.f_s + rfm.m_s)/2>3 THEN 'Loyal Customers'
       WHEN rfm.r_s >= 4 AND ((rfm.f_s + rfm.m_s)/2>1 and (rfm.f_s + rfm.m_s)/2<=3) THEN 'Potential Loyalist'
       WHEN rfm.r_s >= 5 AND (rfm.f_s + rfm.m_s)/2=1 THEN 'New Customers'
       WHEN rfm.r_s = 4 AND (rfm.f_s + rfm.m_s)/2=1 THEN 'Promising'
       WHEN rfm.r_s = 3 AND  ((rfm.f_s + rfm.m_s)/2>2 and (rfm.f_s + rfm.m_s)/2<=3) THEN 'Need Attention'
       WHEN rfm.r_s = 3 AND  ((rfm.f_s + rfm.m_s)/2>=1 and (rfm.f_s + rfm.m_s)/2<=2) THEN 'About to Sleep'
       WHEN rfm.r_s = 2 AND (rfm.f_s + rfm.m_s)/2=2 THEN 'Hibernating'
       WHEN rfm.r_s <= 2 AND (rfm.f_s + rfm.m_s)/2<=2 THEN 'Lost'
       WHEN rfm.r_s = 1 AND (rfm.f_s + rfm.m_s)/2=5 THEN 'Cant Lose Them'
       WHEN rfm.r_s <= 2 AND (rfm.f_s + rfm.m_s)/2>2 THEN 'At Risk'else 'Unknown' 
       END) as rfm_segment
FROM calc_rfm rfm
END;

INSERT INTO sandbox.table_2
SELECT
t.*,
CONCAT(LAG(RFM_SEGMENT,1) OVER (PARTITION BY PHONE ORDER BY SEGMENT_DATE ASC),' => ',RFM_SEGMENT)
FROM sandbox.table_1 t

