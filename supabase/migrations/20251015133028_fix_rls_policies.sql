-- ===============================================
-- Migration: fix_rls_policies
-- Descrição: Corrigir recursão infinita nas policies RLS
-- Data: 15/10/2025
-- ===============================================

-- Remover todas as policies antigas que causam recursão
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can manage their own addresses" ON addresses;
DROP POLICY IF EXISTS "Admins can view all addresses" ON addresses;
DROP POLICY IF EXISTS "Users can view their own orders" ON orders;
DROP POLICY IF EXISTS "Admins can manage all orders" ON orders;
DROP POLICY IF EXISTS "Users can view their own order items" ON order_items;
DROP POLICY IF EXISTS "Admins can manage all order items" ON order_items;
DROP POLICY IF EXISTS "Users can view their own payments" ON payments;
DROP POLICY IF EXISTS "Admins can manage all payments" ON payments;

-- ===============================================
-- POLÍTICAS SIMPLIFICADAS (sem recursão)
-- ===============================================

-- PROFILES: Usuários veem apenas seu próprio perfil
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- ADDRESSES: Usuários gerenciam apenas seus endereços
CREATE POLICY "Users can manage own addresses"
  ON addresses FOR ALL
  USING (auth.uid() = profile_id)
  WITH CHECK (auth.uid() = profile_id);

-- ORDERS: Usuários veem apenas seus pedidos
CREATE POLICY "Users can view own orders"
  ON orders FOR SELECT
  USING (auth.uid() = profile_id);

CREATE POLICY "Users can create own orders"
  ON orders FOR INSERT
  WITH CHECK (auth.uid() = profile_id);

-- ORDER_ITEMS: Usuários veem itens de seus próprios pedidos
CREATE POLICY "Users can view own order items"
  ON order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
        AND orders.profile_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own order items"
  ON order_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
        AND orders.profile_id = auth.uid()
    )
  );

-- PAYMENTS: Usuários veem pagamentos de seus pedidos
CREATE POLICY "Users can view own payments"
  ON payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = payments.order_id
        AND orders.profile_id = auth.uid()
    )
  );

-- PRODUCTS: Todos podem ver produtos ativos (sem autenticação necessária)
CREATE POLICY "Anyone can view active products"
  ON products FOR SELECT
  USING (active = true);

-- ===============================================
-- COMENTÁRIOS
-- ===============================================
COMMENT ON POLICY "Users can view own profile" ON profiles IS 
  'Permite que usuários vejam apenas seu próprio perfil';

COMMENT ON POLICY "Users can manage own addresses" ON addresses IS 
  'Permite que usuários gerenciem apenas seus próprios endereços';

COMMENT ON POLICY "Users can view own orders" ON orders IS 
  'Permite que usuários vejam apenas seus próprios pedidos';
