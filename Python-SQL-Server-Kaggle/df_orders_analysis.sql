SELECT *
FROM dbo.df_orders;

---- Q.1) Find top 10 highest revenue generating products
select top 10 product_id,
       SUM(sale_price) as sales
 from dbo.df_orders
 group by product_id
 order by sales desc; --order by runs after select & top 5,10 would run at the end

---- Q.2) Find top 5 highest selling products in each region
with cte as 
       (select region,
               product_id,
               SUM(sale_price) as sales
         from dbo.df_orders
         group by region, product_id)
 select * 
   from (
         select *, 
                ROW_NUMBER() over(partition by region order by sales desc) as rn
          from cte) A
   where rn <= 5;

--- Q.3) Find month over month growth comparison for 2022 & 2023 sales, eg: jan 2022 vs jan 2023
with cte as (
   select YEAR(order_date) as order_year,
          MONTH(order_date)as order_month,
          sum(sale_price) as sales
    from df_orders
    group by YEAR(order_date), MONTH(order_date)
  -- order by YEAR(order_date), MONTH(order_date) as in cte order by is not allowed
         )
select order_month,
       sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
       sum(case when order_year = 2023 then sales else 0 end) as sales_2023     
 from cte
 group by order_month
 order by order_month

--- Q.4) Find for each category which month had highest sales

with cte as ( 
             select category,
                    FORMAT(order_date, 'yyyyMM') as order_year_month, --helps to merge as per mentioned format
                    sum(sale_price) as sales
              from df_orders
              group by category, FORMAT(order_date, 'yyyyMM')
              --order by category, FORMAT(order_date, 'yyyyMM')
             )
select * 
 from ( 
        select *,
               row_number() over(partition by category order by sales desc) as rn
         from cte
      )a 
 where rn=1

--Q.5) Which sub-category had highest growth by profit in 2023 compared to 2022
with cte as (
   select sub_category,
          YEAR(order_date) as order_year,
          sum(sale_price) as sales
    from df_orders
    group by sub_category, YEAR(order_date)
  -- order by YEAR(order_date), MONTH(order_date) as in cte order by is not allowed
            )
select top 1 *,
       ((sales_2023 - sales_2022)/sales_2022)*100 as growth
 from (
        select sub_category,
               sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
               sum(case when order_year = 2023 then sales else 0 end) as sales_2023
         from cte
         group by sub_category
       ) a
 order by growth desc


 

 







       

    



