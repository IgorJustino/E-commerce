-- ===============================================
-- Migration: add_triggers_and_indexes
-- Descrição: Criação de índices e triggers para otimização e automação
-- Data: 15/10/2025
-- ===============================================

-- ===============================================
-- FUNÇÃO: Atualizar campo updated_at automaticamente
-- ===============================================
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ===============================================
-- ÍNDICES para otimização de performance
-- ===============================================

-- Profiles
create index idx_profiles_email on profiles(email);
create index idx_profiles_role on profiles(role);

-- Products
create index idx_products_category on products(category);
create index idx_products_active on products(active);
create index idx_products_category_active on products(category, active);

-- Addresses
create index idx_addresses_profile_id on addresses(profile_id);
create index idx_addresses_city_state on addresses(city, state);

-- Orders
create index idx_orders_profile_id on orders(profile_id);
create index idx_orders_status on orders(status);
create index idx_orders_created_at on orders(created_at desc);
create index idx_orders_profile_status on orders(profile_id, status);

-- Order Items
create index idx_order_items_order_id on order_items(order_id);
create index idx_order_items_product_id on order_items(product_id);

-- Payments
create index idx_payments_order_id on payments(order_id);
create index idx_payments_status on payments(status);
create index idx_payments_transaction_code on payments(transaction_code);

-- ===============================================
-- TRIGGERS para atualização automática de timestamps
-- ===============================================

create trigger update_profiles_updated_at
  before update on profiles
  for each row
  execute function update_updated_at_column();

create trigger update_products_updated_at
  before update on products
  for each row
  execute function update_updated_at_column();

create trigger update_orders_updated_at
  before update on orders
  for each row
  execute function update_updated_at_column();
