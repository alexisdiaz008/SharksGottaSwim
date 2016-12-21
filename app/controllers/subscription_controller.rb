class SubscriptionController < ApplicationController

  def create
    # Amount in cents
    @amount = 500

    # Create Customer
    customer = Stripe::Customer.create(
    :email => 'customer@example.com',
    :source  => params[:stripeToken]
    )

    Stripe::Subscription.create(
    :customer => customer.id,
    :plan => "basic"
    )

    flash[:notice] = "Subscription successfully made!"
    redirect_to root

  end
end
