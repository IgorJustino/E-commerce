
-- Tabela de usuarios
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text unique not null,
  role text not null default 'customer',
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  
  constraint profiles_role_check check (role in ('customer','admin')),
  constraint profiles_email_format check (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Tabela de produtos
create table products (
  id uuid primary key default gen_random_uuid(),
  sku text unique not null,
  name text not null,
  description text,
  price numeric(10,2) not null,
  stock integer not null default 0,
  category text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  
  constraint products_price_positive check (price >= 0),
  constraint products_stock_positive check (stock >= 0),
  constraint products_name_not_empty check (length(trim(name)) > 0)
);

-- Tabela de endereços
create table addresses (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id) on delete cascade,
  label text,
  street text not null,
  number text,
  complement text,
  city text not null,
  state text not null,
  zip text not null,
  country text not null default 'Brasil',
  created_at timestamptz not null default now(),
  
  constraint addresses_zip_format check (zip ~* '^[0-9]{5}-?[0-9]{3}$')
);

-- Tabela de pedidos
create table orders (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id),
  shipping_address_id uuid references addresses(id),
  billing_address_id uuid references addresses(id),
  status text not null default 'pending',
  total numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  
  constraint orders_status_check check (status in ('pending','paid','shipped','delivered','cancelled')),
  constraint orders_total_positive check (total >= 0)
);

-- Itens do pedido
create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  product_id uuid not null references products(id),
  quantity integer not null,
  unit_price numeric(10,2) not null,
  line_total numeric(12,2) generated always as (quantity * unit_price) stored,
  
  constraint order_items_quantity_positive check (quantity > 0),
  constraint order_items_unit_price_positive check (unit_price >= 0)
);

-- Pagamentos
create table payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  provider text not null,
  transaction_code text,
  amount numeric(12,2) not null,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  
  constraint payments_status_check check (status in ('pending','confirmed','failed','refunded')),
  constraint payments_amount_positive check (amount >= 0),
  constraint payments_transaction_code_unique unique (transaction_code)
);

-- obs tabelas (documentação)
comment on table profiles is 'Perfis de usuários do sistema (clientes e administradores)';
comment on table products is 'Catálogo de produtos disponíveis para venda';
comment on table addresses is 'Endereços de entrega e cobrança dos clientes';
comment on table orders is 'Pedidos realizados pelos clientes';
comment on table order_items is 'Itens individuais de cada pedido';
comment on table payments is 'Registros de pagamentos dos pedidos';

comment on column profiles.role is 'Tipo de usuário: customer (cliente) ou admin (administrador)';
comment on column products.sku is 'Código único de identificação do produto (Stock Keeping Unit)';
comment on column products.stock is 'Quantidade disponível em estoque';
comment on column orders.status is 'Status do pedido: pending, paid, shipped, delivered, cancelled';
comment on column order_items.line_total is 'Total da linha (calculado automaticamente: quantidade × preço unitário)';
comment on column payments.status is 'Status do pagamento: pending, confirmed, failed, refunded';

