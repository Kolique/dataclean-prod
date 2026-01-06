// api/stripe-webhook.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const sig = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    // Vercel passe le body en Buffer, on doit le convertir
    const rawBody = req.body;
    event = stripe.webhooks.constructEvent(rawBody, sig, webhookSecret);
  } catch (err) {
    console.error('❌ Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  console.log('✅ Webhook event received:', event.type);

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const { userId, month, monthLabel } = session.metadata;
    const amount = session.amount_total / 100;

    console.log(`💰 Payment received: ${amount}€ for ${monthLabel} (User: ${userId})`);

    try {
      // Créer ou mettre à jour l'abonnement
      const { data, error } = await supabase
        .from('subscriptions')
        .upsert({
          user_id: userId,
          month: month,
          status: 'available',
          payment_method: 'stripe',
          paid_at: new Date().toISOString(),
          amount: amount,
          stripe_payment_id: session.payment_intent,
          is_first_free: false
        }, {
          onConflict: 'user_id,month'
        });

      if (error) {
        console.error('❌ Supabase error:', error);
        throw error;
      }

      console.log(`✅ Subscription created/updated in Supabase for ${monthLabel}`);

    } catch (error) {
      console.error('❌ Error creating subscription:', error);
      return res.status(500).json({ error: 'Failed to create subscription' });
    }
  }

  res.status(200).json({ received: true });
};
