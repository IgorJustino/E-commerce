// ===============================================
// Edge Function: export-order-csv
// Descrição: Exporta pedidos de um cliente em formato CSV
// ===============================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { profileId } = await req.json()

    if (!profileId) {
      throw new Error('profileId is required')
    }

    // Criar cliente Supabase
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Buscar pedidos do cliente com detalhes
    const { data: orders, error } = await supabaseClient
      .from('order_details_view')
      .select('*')
      .eq('customer_name', profileId)

    if (error) throw error

    if (!orders || orders.length === 0) {
      throw new Error('Nenhum pedido encontrado para este cliente')
    }

    // Gerar CSV
    const headers = [
      'ID do Pedido',
      'Nome do Cliente',
      'Produto',
      'Quantidade',
      'Preço Unitário',
      'Subtotal',
      'Total do Pedido',
      'Status',
      'Data do Pedido'
    ]

    const csvRows = [
      headers.join(','),
      ...orders.map(order => [
        order.order_id,
        order.customer_name,
        `"${order.product_name}"`,
        order.quantity,
        order.unit_price,
        order.line_total,
        order.order_total,
        order.status,
        new Date(order.order_date).toLocaleDateString('pt-BR')
      ].join(','))
    ]

    const csvContent = csvRows.join('\n')

    return new Response(
      csvContent,
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'text/csv',
          'Content-Disposition': `attachment; filename="pedidos-${profileId.substring(0, 8)}-${Date.now()}.csv"`,
        },
        status: 200,
      },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      },
    )
  }
})

/* To invoke locally:

  1. Run `supabase start`
  2. Run `supabase functions serve export-order-csv`
  3. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/export-order-csv' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"profileId":"uuid-do-cliente"}'

*/
