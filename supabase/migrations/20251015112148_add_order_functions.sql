-- ===============================================
-- Migration: add_order_functions
-- Descrição: Criação de funções para automatizar processos de pedidos
-- Data: 15/10/2025
-- ===============================================

-- ===============================================
-- FUNÇÃO: Recalcular total do pedido automaticamente
-- ===============================================

create or replace function recompute_order_total()
returns trigger as $$
begin
  update orders
  set total = (
    select coalesce(sum(line_total), 0)
    from order_items
    where order_id = coalesce(new.order_id, old.order_id)
  ),
  updated_at = now()
  where id = coalesce(new.order_id, old.order_id);
  return new;
end;
$$ language plpgsql;

-- Trigger associado
create trigger trg_recompute_order_total
after insert or update or delete on order_items
for each row
execute function recompute_order_total();

-- ===============================================
-- FUNÇÃO: Atualizar status de pedido manualmente
-- ===============================================

create or replace function set_order_status(p_order_id uuid, p_status text)
returns void as $$
begin
  update orders
  set status = p_status, updated_at = now()
  where id = p_order_id;
end;
$$ language plpgsql;
