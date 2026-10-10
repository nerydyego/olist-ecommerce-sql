/* 
 * Consulta total de registros por tabela
 */

select 'orders' as tabela, count(*) as Total_registros from raw.orders
UNION ALL	
select 'customers', count(*) from raw.customers
UNION ALL	
select 'order_items', count(*) from raw.order_items
union all
select 'order_payments', count(*) from raw.order_payments
union all
select 'order_reviews', count(*) from raw.order_reviews
union all
select 'products', count(*) from raw.products
union all
select 'sellers', count(*) from raw.sellers
union all
select 'geolocation', count(*) from raw.geolocation
union all
select 'product_category_name_translation', count(*) from raw.product_category_name_translation order by tabela;
