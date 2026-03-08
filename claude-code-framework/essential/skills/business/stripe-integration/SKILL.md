---
name: stripe-integration
description: Implement Stripe payments including checkout, subscriptions, webhooks, and customer portal. Use when adding payments to any web app. Triggers on "Stripe", "payment", "checkout", "subscription", "billing", "webhook", "customer portal".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: business
  source: community-contributed
  license: MIT
---

# Stripe Integration

Production-ready Stripe payment patterns for Next.js applications — checkout, subscriptions, webhooks, and the customer portal.

## Instructions

### Pattern 1: One-Time Checkout

```typescript
// app/api/checkout/route.ts
import { NextRequest, NextResponse } from 'next/server'
import Stripe from 'stripe'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(request: NextRequest) {
  const { priceId, customerEmail } = await request.json()

  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    payment_method_types: ['card'],
    customer_email: customerEmail,
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.NEXT_PUBLIC_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.NEXT_PUBLIC_URL}/pricing`,
    metadata: {
      source: 'website',
    },
  })

  return NextResponse.json({ url: session.url })
}
```

### Pattern 2: Subscription Checkout

```typescript
// app/api/subscribe/route.ts
export async function POST(request: NextRequest) {
  const { priceId, customerId } = await request.json()

  const session = await stripe.checkout.sessions.create({
    mode: 'subscription',
    customer: customerId, // Existing Stripe customer ID
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.NEXT_PUBLIC_URL}/dashboard?subscribed=true`,
    cancel_url: `${process.env.NEXT_PUBLIC_URL}/pricing`,
    subscription_data: {
      trial_period_days: 14,
      metadata: { plan: 'pro' },
    },
  })

  return NextResponse.json({ url: session.url })
}
```

### Pattern 3: Webhook Handler (Critical)

```typescript
// app/api/webhooks/stripe/route.ts
import { headers } from 'next/headers'
import Stripe from 'stripe'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(request: NextRequest) {
  const body = await request.text()
  const signature = headers().get('stripe-signature')!

  let event: Stripe.Event

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err) {
    console.error('Webhook signature verification failed:', err)
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 })
  }

  switch (event.type) {
    case 'checkout.session.completed': {
      const session = event.data.object as Stripe.Checkout.Session
      // Provision access — update database, send welcome email
      await handleCheckoutComplete(session)
      break
    }
    case 'customer.subscription.updated': {
      const subscription = event.data.object as Stripe.Subscription
      // Update subscription status in database
      await handleSubscriptionUpdate(subscription)
      break
    }
    case 'customer.subscription.deleted': {
      const subscription = event.data.object as Stripe.Subscription
      // Revoke access
      await handleSubscriptionCanceled(subscription)
      break
    }
    case 'invoice.payment_failed': {
      const invoice = event.data.object as Stripe.Invoice
      // Notify user, trigger dunning flow
      await handlePaymentFailed(invoice)
      break
    }
  }

  return NextResponse.json({ received: true })
}
```

### Pattern 4: Customer Portal

```typescript
// app/api/portal/route.ts
export async function POST(request: NextRequest) {
  const { customerId } = await request.json()

  const session = await stripe.billingPortal.sessions.create({
    customer: customerId,
    return_url: `${process.env.NEXT_PUBLIC_URL}/dashboard`,
  })

  return NextResponse.json({ url: session.url })
}
```

### Environment Variables

```env
STRIPE_SECRET_KEY=sk_live_...        # Never expose this client-side
STRIPE_PUBLISHABLE_KEY=pk_live_...   # Safe for client-side
STRIPE_WEBHOOK_SECRET=whsec_...      # From Stripe Dashboard → Webhooks
NEXT_PUBLIC_URL=https://yourdomain.com
```

### Testing Checklist

```markdown
- [ ] Checkout flow completes (use Stripe test card: 4242 4242 4242 4242)
- [ ] Webhook receives events (use `stripe listen --forward-to localhost:3000/api/webhooks/stripe`)
- [ ] Subscription creates correctly
- [ ] Cancellation revokes access
- [ ] Failed payment triggers notification
- [ ] Customer portal loads and lets user manage subscription
- [ ] No secret keys in client-side code
- [ ] Webhook signature verification works (reject tampered events)
```

## When to Use This Skill

✅ Use stripe-integration when:
- Adding payments to a web app
- Setting up subscription billing
- Building a SaaS pricing page
- Client project needs payment processing

❌ Don't use for:
- Crypto payments (different flow entirely)
- Invoice generation (Stripe handles this)
- Tax calculation (use Stripe Tax or separate service)
