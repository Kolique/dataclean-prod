// api/create-checkout.js
// Fonction Vercel pour créer une session Stripe Checkout

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

module.exports = async (req, res) => {
  // Permettre CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { userId, month, monthLabel, userEmail, laverieName } = req.body;

    if (!userId || !month || !monthLabel) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Créer la session Stripe Checkout
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'eur',
            product_data: {
              name: `Dashboard Data Clean - ${monthLabel}`,
              description: `Accès au dashboard pour ${monthLabel}`,
              images: ['https://your-logo-url.com/logo.png'], // Optionnel
            },
            unit_amount: 9900, // 99.00 EUR en centimes
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: `${process.env.FRONTEND_URL}/success.html?session_id={CHECKOUT_SESSION_ID}&month=${month}`,
      cancel_url: `${process.env.FRONTEND_URL}/dashboard.html?canceled=true`,
      customer_email: userEmail,
      metadata: {
        userId: userId,
        month: month,
        monthLabel: monthLabel,
        laverieName: laverieName
      },
    });

    return res.status(200).json({ sessionId: session.id });

  } catch (error) {
    console.error('Stripe error:', error);
    return res.status(500).json({ error: error.message });
  }
};
