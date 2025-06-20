-- before going further check if therir is any duplicate in the primary key
select cst_id, count(*) from (
select 
ci.cst_id,
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,	
ci.cst_marital_status,
ci.cst_gender,
ci.cst_create_date,
ca.bdate,
ca.GEN,
la.CNTRY
from silver_crm_cust_info as ci
left join silver_erp_cust_az12 as ca
on ci.cst_key = ca.cid
left join silver_erp_loc_a101 as la
on ci.cst_key = la.CID) as t
group by cst_id
having count(*) > 1;



-- Data integration on gold_dim_customers

select distinct
ci.cst_gender,
ca.GEN,
case 
	when ci.cst_gender != 'N/A' then ci.cst_gender -- CRM is the master for gender info
	else coalesce(ca.GEN, 'N/A')
end as new_gen
from silver_crm_cust_info as ci
left join silver_erp_cust_az12 as ca
on ci.cst_key = ca.cid
left join silver_erp_loc_a101 as la
on ci.cst_key = la.CID
order by 1,2;




-- before going further check if therir is any duplicate in the primary key
select prd_key, count(*) from (
select 
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_name,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pn.prd_end_dt,
pc.cat,
pc.SUBCAT,
pc.MAINTENANCE
from silver_crm_prd_info as pn
left join silver_erp_px_cat_g1v2 as pc
on pn.cat_id = pc.id
where prd_end_dt is null -- filter out all historical data
) as t
group by prd_key
having count(*) > 1;  




-- after building fact table check if all dimension table can succefully join to the fact table
select * from gold_fact_sales f
left join gold_dim_customers c 
on c.customer_key = f.customer_key
left join gold_dim_products p
on p.product_key = f.product_key
where p.product_key is  null;
