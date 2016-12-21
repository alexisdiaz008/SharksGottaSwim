require 'sinatra'
require 'pony'
require 'stripe'

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

configure :development do
require 'better_errors'
  use BetterErrors::Middleware
  # you need to set the application root in order to abbreviate filenames
  # within the application:
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/?' do
  # File.read(File.join('layout.erb'))
  erb :index
end

post '/mail' do
  # p request.path_info
  # p request.fullpath 
  # p request.url
	Pony.options = {   
                   :from           => "#{params[:name]}<lexmasta@gmail.com>",
                   :via            => :smtp,
                   :via_options    => {
                     :address        => 'smtp.sendgrid.net',
                     :port           => '587',
                     :user_name      => ENV['SENDGRID_USERNAME'],
                     :password       => ENV['SENDGRID_PASSWORD'],
                     :authentication => :plain, 
                     :domain         => 'heroku.com'
                    }
                 }
  Pony.mail(subject: "A message from #{params[:name]}", to: 'lexmasta@gmail.com', body: "#{params[:name]} #{params[:email]} #{params[:message]}")
	redirect('/?')
end

post '/subscription' do
  # Amount in cents
  @amount = 500

  customer = Stripe::Customer.create(
    :email => 'customer@example.com',
    :source  => params[:stripeToken]
  )

  Stripe::Subscription.create(
    :customer => customer.id,
    :plan => "basic"
  )

  erb :charge
  error Stripe::CardError do
    env['sinatra.error'].message
  end
  redirect to('/')
end


post '/charge' do
  # Amount in cents
  @amount = 500

  customer = Stripe::Customer.create(
    :email => 'customer@example.com',
    :source  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
   :amount      => @amount,
   :description => 'Sinatra Charge',
   :currency    => 'usd',
   :customer    => customer.id
   )

  erb :charge
  error Stripe::CardError do
    env['sinatra.error'].message
  end
  redirect to('/')
end

