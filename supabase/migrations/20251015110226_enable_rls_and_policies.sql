-- ===============================================
-- Migration: enable_rls_and_policies
-- Descrição: Configuração de RLS e políticas de acesso
-- Data: 15/10/2025
-- ===============================================

-- ===============================================
-- HABILITAÇÃO DO RLS (Row-Level Security)
-- ===============================================

alter table profiles enable row level security;
alter table addresses enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table payments enable row level security;

-- ===============================================
-- POLÍTICAS PARA CLIENTES (usuários comuns)
-- ===============================================

-- Perfis: cada usuário vê apenas o próprio perfil
create policy "Users can view their own profile"
on profiles
for select
using (auth.uid() = id);

-- Endereços: usuário vê apenas os próprios
create policy "Users can manage their own addresses"
on addresses
for all
using (auth.uid() = profile_id)
with check (auth.uid() = profile_id);

-- Pedidos: usuário vê apenas seus pedidos
create policy "Users can view their own orders"
on orders
for select
using (auth.uid() = profile_id);

-- Itens do pedido: vinculados ao pedido do usuário
create policy "Users can view their own order items"
on order_items
for select
using (
  exists (
    select 1 from orders o
    where o.id = order_items.order_id
    and o.profile_id = auth.uid()
  )
);

-- Pagamentos: usuário vê apenas os pagamentos de seus pedidos
create policy "Users can view their own payments"
on payments
for select
using (
  exists (
    select 1 from orders o
    where o.id = payments.order_id
    and o.profile_id = auth.uid()
  )
);

-- ===============================================
-- POLÍTICAS PARA ADMINISTRADORES (acesso total)
-- ===============================================

-- Perfis: admins podem ver todos
create policy "Admins can view all profiles"
on profiles
for select
using (
  exists (
    select 1 from profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

-- Pedidos: admins podem gerenciar todos
create policy "Admins can manage all orders"
on orders
for all
using (
  exists (
    select 1 from profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

-- Endereços: admins podem ver todos
create policy "Admins can view all addresses"
on addresses
for select
using (
  exists (
    select 1 from profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

-- Itens do pedido: admins podem gerenciar todos
create policy "Admins can manage all order items"
on order_items
for all
using (
  exists (
    select 1 from profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);

-- Pagamentos: admins podem gerenciar todos
create policy "Admins can manage all payments"
on payments
for all
using (
  exists (
    select 1 from profiles p
    where p.id = auth.uid() and p.role = 'admin'
  )
);
