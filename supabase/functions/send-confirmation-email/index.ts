// ===============================================
// Edge Function: send-confirmation-email
// Descrição: Envia email de confirmação de pedido
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
    const { orderId } = await req.json()

    if (!orderId) {
      throw new Error('orderId is required')
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

    // Buscar dados do pedido
    const { data: order, error: orderError } = await supabaseClient
      .from('orders')
      .select(`
        id,
        status,
        total,
        created_at,
        profiles:profile_id (
          full_name,
          email
        )
      `)
      .eq('id', orderId)
      .single()

    if (orderError) throw orderError

    // Aqui você integraria com um serviço de email (SendGrid, Resend, etc)
    // Por enquanto, apenas logamos
    console.log('📧 Sending confirmation email to:', order.profiles.email)
    console.log('Order details:', {
      orderId: order.id,
      customerName: order.profiles.full_name,
      total: order.total,
      status: order.status,
    })

    // Simular envio de email
    const emailData = {
      to: order.profiles.email,
      subject: `Confirmação de Pedido #${order.id.substring(0, 8)}`,
      body: `
        Olá ${order.profiles.full_name},
        
        Seu pedido foi confirmado com sucesso!
        
        Número do pedido: ${order.id}
        Total: R$ ${order.total}
        Status: ${order.status}
        Data: ${new Date(order.created_at).toLocaleDateString('pt-BR')}
        
        Obrigado pela sua compra!
      `
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Email de confirmação enviado com sucesso',
        emailData,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
  2. Run `supabase functions serve send-confirmation-email`
  3. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/send-confirmation-email' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"orderId":"seu-uuid-aqui"}'

*/
