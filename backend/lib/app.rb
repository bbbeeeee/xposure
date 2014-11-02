require 'rubygems'
require 'data_mapper'
require  'dm-migrations'
require 'omniauth-identity/version'
require 'omniauth/identity'
require 'sinatra'
require 'sinatra/reloader'
require "uri"
require "net/http"
#require "lib/overload_hash"
require './lib/mercury.rb'

require 'mail'

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'pascoej.me',
            :user_name            => 'xposurepowered@gmail.com',
            :password             => 'tamsrepresent',
            :authentication       => 'plain',
            :enable_starttls_auto => true  }



Mail.defaults do
  delivery_method :smtp, options
end

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://root:test@localhost/photo_test')

class Photographer
	include DataMapper::Resource

	property :id,	Serial
	property :first_name,	String
	property :email, 	String
	property :facebook_id, String

	has n, :availsession
	has n, :ongoingsession
	#belongs_to :identity
end

#class Identity
#  include DataMapper::Resource
#  include OmniAuth::Identity::Models::DataMapper
#
#  property :id,              Serial
#  property :email,           String
#  property :password_digest, Text
#
#  belongs_to :photographer
#
#  attr_accessor :password_confirmation
#
#end

class Availsession
	include DataMapper::Resource

	property :id,	Serial
	property :start_time, DateTime
	property :end_time, DateTime
	property :location, String
	property :active, Boolean

	belongs_to :photographer
end

class Ongoingsession
	include DataMapper::Resource

	property :id, Serial
	property :location, String
	property :customer_email, String
	property :time, DateTime
	property :completed, Boolean
	property :abandoned, Boolean

	belongs_to :photographer
	has n, :payment
end

class Payment
	include DataMapper::Resource

	property :id, Serial
	property :amount, Decimal
	property :paid, Boolean
	property :payment_token, String,   :length => 128

	belongs_to :ongoingsession
end
DataMapper.auto_migrate!
$client = HCMercury.new('013163015566916', 'ypBj@f@zt3fJRX,k')
def createTransaction (total_amount, invoice, ongoingsession)
	opts = {total_amount: '1', tax_amount: '0', process_complete_url: 'http://localhost:4567/transaction_completed', return_url: 'yahoo.com', :invoice => 'lol'}
	payment_id = $client.initialize_payment(opts)[:initialize_payment_response][:initialize_payment_result][:payment_id]
	db_pay = Payment.new(:amount => 5.0, :paid => false, :ongoingsession => ongoingsession, :payment_token => payment_id)
	db_pay.save
	return db_pay
end
def setPaymentCompleted(payment) 
	payment.update(:paid => true)
end

test_pg = Photographer.new(:first_name => "Kevin Tu", :email => "kevinmdtu@gmail.com", :facebook_id => "kevin")
test_pg.save
test_ogs = Ongoingsession.new(:location => "22.0,22.0", :customer_email=>"pascoej@murri.ca", :time => Time.now, :completed => false, :abandoned => false, :photographer => test_pg)
test_ogs.save
puts 1
db_pay = createTransaction(5.0, 'Payment for photos', test_ogs)
puts 2
db_pay.save
puts 3


get '/create_transaction' do
	createTransaction("test",200,"test")
  #session_id = params[:session_id]
  #amount = params[:amount]


end

get '/pay' do 
	payment_id = params[:payment_id]
  	redirect "https://hc.mercurydev.net/Checkoutiframe.aspx?pid=" + payment_id
end

post '/transaction_completed' do 
	response_code = params["ReturnCode"]
	puts "code:" + response_code
	if response_code != "0" 
		return params["ReturnMessage"]
	end
	payment_id = params["PaymentID"]

	verify_response = $client.verify_payment(payment_id)
	puts verify_response
	verify_response_code = verify_response[:verify_payment_response][:verify_payment_result][:response_code]
	if (verify_response_code != "0")
		return verify_response[:verify_payment_response][:verify_payment_result][:display_message] 
	end

	db_pay = Payment.first(:payment_token => payment_id)
	setPaymentCompleted(db_pay)
	send_payment_emails(db_pay)
	"Transaction Completed!"
end

get '/request_photographer' do

end

def send_email destination, replacements, subject, body_text_name 
	raw_body = File.read(body_text_name)
	replacements.each do |key, value|  
		raw_body = raw_body.gsub(key,value.to_s)
	end

	mail = Mail.new do
  		from     'xposurepowered@gmail.com'
 		to       destination
  		subject  subject
 		body     raw_body
	end
	mail.deliver!
end


def send_payment_emails payment 
	amount = payment[:amount]
	session = payment.ongoingsession
	photographer = session.photographer
	photographer_email = photographer[:email]
	photographer_name = photographer[:first_name]

	customer_email = session[:customer_email]

	replacements = {"{{customer-email}}" => customer_email, "{{payment-amount}}" => amount, "{{photographer-name}}" => photographer_name, "{{photographer-email}}" => photographer_email}
	send_email(photographer_email,replacements,"Your payment from " + customer_email + " has been completed.", "./lib/payment_complete_photographer")
	send_email(customer_email,replacements,"Your payment to " + photographer_name + " has been completed.", "./lib/payment_complete_customer")
end

