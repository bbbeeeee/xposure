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
set :bind, '0.0.0.0'
set :public, 'public'
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
	property :desc, Text
	property :propic, String, :length => 256

	has n, :availsession
	has n, :ongoingsession
	has n, :request
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
#
class Request
	include DataMapper::Resource

	property :id, Serial
	property :customer_email, String, :length => 256
	property :location, String, :length => 256

	belongs_to :photographer
end
class Availsession
	include DataMapper::Resource

	property :id,	Serial
	#property :start_time, DateTime
	#property :end_time, DateTime
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
	opts = {total_amount: total_amount, tax_amount: '0', process_complete_url: 'http://mako.local:4567/transaction_completed', return_url: 'yahoo.com', :invoice => 'Yahooooo'}
	payment_id = $client.initialize_payment(opts)[:initialize_payment_response][:initialize_payment_result][:payment_id]
	db_pay = Payment.new(:amount => total_amount, :paid => false, :ongoingsession => ongoingsession, :payment_token => payment_id)
	db_pay.save
	return db_pay
end
def setPaymentCompleted(payment) 
	payment.update(:paid => true)
end

test_pg = Photographer.create(:first_name => "Kevin Tu", :email => "pascoej@murri.ca", :facebook_id => "kevin", :propic => "img/kevin.jpg", :desc => "Houston, TX Native")
test_pg2 = Photographer.create(:first_name => "Max Wang", :email => "pascoej@murri.ca", :facebook_id => "kevin", :propic => "/img/max.jpg", :desc => "I love kanye west")
Photographer.create(:first_name => "Latane Bullock", :email => "pascoej@murri.ca", :facebook_id => "kevin", :propic => "img/brandon.jpg", :desc => "Nice to meet you")

#test_ogs = Ongoingsession.new(:location => "22.0,22.0", :customer_email=>"pascoej@murri.ca", :time => Time.now, :completed => false, :photographer => test_pg)
#test_ogs.save
#puts 1
#db_pay = createTransaction(5.0, 'Payment for photos', test_ogs)
#puts 2
#db_pay.save
#puts 3
Availsession.create(:active => true, :location => "51.5033630,-0.1276250", :photographer => test_pg)
Availsession.create(:active => true, :location => "51.1,-.11", :photographer => test_pg2)

#Ongoingsession.create(:location =>"51.5033630,-0.127625", :customer_email => "me@brandontruong.com",:completed => false, :photographer => test_pg)


get '/request_payment' do
	active_session_id = params[:active_session_id]
	session = Ongoingsession.get(active_session_id.to_i)
	if (session[:completed])
		return "Already paid"
	end
	session.update(:completed => true)
	photographer = session.photographer
	amount = params[:amount]
	payment = createTransaction(amount, "Payment for photos taken by " + photographer[:first_name], session)
	send_request_payment_email(payment)
	return "0"
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


get '/list_active_photographers' do
	all = Availsession.all(:active => true)
	profiles = Array.new
	all.each do |as|
		photographer_id = as.photographer[:id]
		availsession_id = as[:id]
		location = as[:location]
		profilephoto = as.photographer[:propic]
		first_name = as.photographer[:first_name]
		desc = as.photographer[:desc]

		profile = {:photographer_id => photographer_id, :availsession_id => availsession_id, :location => location, :profilephoto => profilephoto, :first_name => first_name, :desc => desc}
		profiles.push(profile)
	end
	return profiles.to_json
end



get '/request_photographer' do
	session_id = params[:session_id]
	customer_email = params[:email]
	location = params[:location]

	availsession = Availsession.get(session_id.to_i)
	
	photographer = availsession.photographer
	request = Request.new(:photographer => photographer, :customer_email => customer_email, :location => location)
	request.save
	send_request_email(request)
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
get '/active_sessions' do
	photographer_id = params[:photographer_id]
	photographer = Photographer.get(photographer_id.to_i)
	sessions = Ongoingsession.all
	all_payments = Array.new
	sessions.each do |ses| 
		puts ses.inspect
		payment = Payment.first(:ongoingsession => ses)
		payc = false
		if payment != nil && payment[:paid]
			payc = true
		end
		apay = {:customer_email => ses[:customer_email], :paid => payc}
		all_payments.push(apay)
	end
	return all_payments.to_json
end
get '/accept_request' do
	request_id = params[:request_id]
	request = Request.get(request_id.to_i)

	puts request.inspect
	Ongoingsession.create(:location => request[:location], :customer_email => request[:customer_email], :time => Time.now, :completed => false, :photographer => request.photographer)
	send_accept_email(request)

	return "Request accepted."
end

def send_accept_email request
	customer_email = request[:customer_email]
	photographer = request.photographer
	photographer_email = photographer[:email]
	photographer_name = photographer[:first_name]
	replacements = {"{{photographer-name}}" => photographer_name, "{{photographer-email}}" => photographer_email}
	send_email(customer_email, replacements, photographer_name + " has accepted your request", "./lib/request_accepted")
end

def send_request_email request 
	photographer = request.photographer
	photographer_name = photographer[:first_name]
	c_email = request[:customer_email]
	photographer_email = photographer[:email]
	location = request[:location]

	google_maps_link = "https://www.google.com/maps?q="+location+"&z=17"
	accept_link = "http://mako.local:4567/accept_request?request_id=" + request[:id].to_s
	subject = "" +c_email + " has requested that you take photos for them"


	replacements = {"{{photographer-name}}"=>photographer_name, "{{customer-email}}"=>c_email,"{{google-maps-link}}"=>google_maps_link,"{{accept-link}}"=> accept_link}
	send_email(photographer_email,replacements,subject, "./lib/request_email.txt")
end

def send_request_payment_email payment 
	amount = "%.2f" % payment[:amount]
	session = payment.ongoingsession
	photographer = session.photographer
	photographer_email = photographer[:email]
	photographer_name = photographer[:first_name]
	pay_link = "http://mako.local:4567/pay?payment_id=" + payment[:payment_token].to_s
	customer_email = session[:customer_email]

	replacements = {"{{pay-link}}"=>pay_link,"{{customer-email}}" => customer_email, "{{payment-amount}}" => "$" + amount.to_s, "{{photographer-name}}" => photographer_name, "{{photographer-email}}" => photographer_email}
	send_email(customer_email,replacements,photographer_name + " has requested payment", "./lib/payment_request")
end

def send_payment_emails payment 
	amount = "%.2f" % payment[:amount]
	session = payment.ongoingsession
	photographer = session.photographer
	photographer_email = photographer[:email]
	photographer_name = photographer[:first_name]
	payment_token = payment[:payment_token]

	customer_email = session[:customer_email]

	replacements = {"{{customer-email}}" => customer_email, "{{payment-amount}}" => "$" + amount.to_s, "{{photographer-name}}" => photographer_name, "{{photographer-email}}" => photographer_email}
	send_email(photographer_email,replacements,"Your payment from " + customer_email + " has been completed.", "./lib/payment_complete_photographer")
	send_email(customer_email,replacements,"Your payment to " + photographer_name + " has been completed.", "./lib/payment_complete_customer")
end