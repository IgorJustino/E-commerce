-- View para Resumo dos pedidos com dados do cliente
create or replace view order_summary_view as
select
  o.id as order_id,
  p.full_name as customer_name,
  p.email as customer_email,
  o.status,
  o.total,
  o.created_at as order_date
from orders o
join profiles p on o.profile_id = p.id;

-- View para Detalhes do pedido com produtos e quantidades
create or replace view order_details_view as
select
  o.id as order_id,
  p.full_name as customer_name,
  pr.name as product_name,
  oi.quantity,
  oi.unit_price,
  oi.line_total,
  o.total as order_total,
  o.status,
  o.created_at as order_date
from orders o
join profiles p on o.profile_id = p.id
join order_items oi on oi.order_id = o.id
join products pr on pr.id = oi.product_id;

-- View  ara Produtos mais vendidos (relatório de vendas)
create or replace view top_selling_products_view as
select
  pr.id as product_id,
  pr.sku,
  pr.name as product_name,
  pr.category,
  pr.price,
  sum(oi.quantity) as total_quantity_sold,
  count(distinct oi.order_id) as total_orders,
  sum(oi.line_total) as total_revenue
from products pr
join order_items oi on oi.product_id = pr.id
join orders o on o.id = oi.order_id
where o.status in ('paid', 'shipped', 'delivered')
group by pr.id, pr.sku, pr.name, pr.category, pr.price
order by total_quantity_sold desc;
