// api/stripe-webhook.js
// Webhook Stripe pour confirmer les paiements

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY // ⚠️ Service key, pas anon key
);

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const sig = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    // Vérifier la signature Stripe
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Gérer l'événement
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;

    // Récupérer les métadonnées
    const { userId, month, monthLabel } = session.metadata;
    const amount = session.amount_total / 100; // Convertir centimes en euros

    console.log(`✅ Paiement reçu : ${amount}€ pour ${monthLabel} (User: ${userId})`);

    try {
      // Créer l'abonnement dans Supabase
      const { data, error } = await supabase
        .from('subscriptions')
        .insert({
          user_id: userId,
          month: month,
          status: 'available',
          payment_method: 'stripe',
          paid_at: new Date().toISOString(),
          amount: amount,
          stripe_payment_id: session.payment_intent,
          is_first_free: false
        });

      if (error) {
        console.error('Supabase error:', error);
        throw error;
      }

      console.log(`✅ Subscription créée dans Supabase pour ${monthLabel}`);

      // Optionnel : Envoyer un email de confirmation
      // await sendConfirmationEmail(userEmail, monthLabel);

    } catch (error) {
      console.error('Error creating subscription:', error);
      return res.status(500).json({ error: 'Failed to create subscription' });
    }
  }

  res.status(200).json({ received: true });
};
