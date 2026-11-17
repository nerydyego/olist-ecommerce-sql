select product_category_name, 
		count(*) as quantidade
from analytics.product_category_name_translation
group by product_category_name
having count(*) > 1;

select product_id, 
		count(*) as quantidade
from analytics.products
group by product_id
having count(*) > 1;


create view bi.dim_produto as 
select p.product_id,
p.product_category_name,
pcnt.product_category_name_english,
p.product_name_lenght,
p.product_description_lenght,
p.product_photos_qty,
p.product_weight_g,
p.product_length_cm,
p.product_height_cm,
p.product_width_cm
from analytics.products as p
left join analytics.product_category_name_translation as pcnt
on p.product_category_name = pcnt.product_category_name; 

select count(*) as produtos_sem_traducao
from bi.dim_produto
where product_category_name_english is null;


select 
	case 
		when product_category_name is null then 'Sem categoria original'
		else 'Categoria sem tradução'
	end as categoria_existe,
	count(*) as quantidade
from bi.dim_produto 
where product_category_name_english is null
group by 
	case 
		when product_category_name is null then 'Sem categoria original'
		else 'Categoria sem tradução'
	end;
