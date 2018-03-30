-- Print out all available periods
select distinct period from comtrade 

-- Print out all available comcodes
select distinct commodity from comtrade 

-- Print out all available reporters
select distinct reporter from comtrade WHERE period = 201401

-- Search period range
select max(period), min(period) from comtrade 

-- 
SELECT partner, partner_code, partner_iso FROM comtrade WHERE period = 201401 limit 200

-- Example grouping partners
SELECT partner, partner_code, count(*) FROM comtrade WHERE period = 201401
group by  partner, partner_code
order by  partner, partner_code

-- Alex test case
SELECT partner, partner_code, partner_iso FROM comtrade WHERE 
partner_code in (710,724,757,276) 
AND 
period in (201401,201401,201501,201501) 
AND reporter_code = 826

-- Get the first 100 rows containing everything
select * from comtrade limit 100

select partner_code , sum(trade_value_usd) from comtrade
where partner_code in (710,724,757,276) 
group by partner_code

SELECT substring(period from 1 for 4) ,count(*) FROM comtrade 
group by  substring(period from 1 for 4)


SELECT partner, netweight_kg, trade_value_usd, period, commodity_code FROM comtrade WHERE
            partner_code = 762
            AND period  BETWEEN 201401 AND 201612
            --AND CAST(commodity_code as TEXT) = '0201'
            AND commodity_code in ('0201','0201')
            AND reporter_code = 826
