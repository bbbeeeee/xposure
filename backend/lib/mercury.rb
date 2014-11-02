require "savon"

class HCMercury
	@@dev_url = "https://hc.mercurydev.net/hcws/hcservice.asmx?WSDL"
	@@prod_url = "https://hc.mercurypay.com/hcws/hcservice.asmx?WSDL"
	
	@@dev_url1 = "https://hc.mercurydev.net/tws/transactionservice.asmx?WSDL"
	@@prod_url1 = "https://hc.mercurypay.com/tws/transactionservice.asmx?WSDL"

	@@test_merchant_id = "013163015566916" #OR "018847445761734" #OR "003503902913105"    
	@@test_password =  "ypBj@f@zt3fJRX,k" 	#OR "Y6@Mepyn!r0LsMNq"   
	@@mode = "dev"

	def initialize merchant_id = nil, merchant_password = nil
		if @@mode == "dev"
			@merchant_id = @@test_merchant_id
			@url = @@dev_url
			@url1 = @@dev_url1 # priti
			@password = @@test_password
		end

		if @@mode == "prod"
			if not merchant_id or not merchant_password
				throw_error "Invalid merchant_id and/or merchant_password"
				return false
			end

			@merchant_id = merchant_id
			@password = merchant_password
			@url = @@prod_url
			@url1 = @@prod_url1
		end

		@client = Savon::Client.new(wsdl:@url)
		@client1 = Savon::Client.new(wsdl:@url1)
		return self
	end

	def throw_error error
		raise error
	end

	def convert_to_xml hash, method
		xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><'+method+' xmlns="http://www.mercurypay.com/"><request>'

		hash.each do |key, val|
			xml = xml + "<#{key}>#{val}</#{key}>"
		end

		xml = xml + "</request></"+method+"></soap:Body></soap:Envelope>"
		return xml
	end

	def check_required_opts required_opts, opts
		missing_opts = []
		has_error = false

		required_opts.each do |opt|
			if not opts[opt]
				has_error = true
				missing_opts << opt
			end
		end

		if has_error
			throw_error("Missing the following options: " + missing_opts.to_s)
			return false
		end
	end

	def check_for_error_response response
		code = nil

		acceptable_response_codes = [:response_code, :ReturnCode]
		acceptable_response_codes.each do |acceptable_code|
			if response[acceptable_code] 
				code = response[acceptable_code]
			end
		end

		if not code
			throw_error "Invalid response. expecting response code. response sent: " + response.to_s
			return false
		end

		case code.to_i
		when 0
			return true
		else
			throw_error "There was an error handling your request. Here is the response: " + response.to_s
			return false
		end
	end

	def initialize_payment opts
		required_opts = [:total_amount, :tax_amount, :process_complete_url, :return_url, :invoice]
		check_required_opts required_opts, opts

		#instore, register, drive thru if true swipe
		# declare defaults. will be overwritten by opts
		defaults = {
			:tran_type => 'Sale',
			:frequency => 'OneTime',
			:memo => 'Bookafy Test v1.0',
			:tax_amount => 0.00,
			:display_style => "Custom",
			:default_swipe => "Swipe"# or Manual
		}

		opts.each do |key, val|
			defaults[:"#{key}"] = val
		end


		# return defaults

		message = {
			:MerchantID => @merchant_id,
			:Password => @password,
			:TranType => defaults[:tran_type],
			:Frequency => defaults[:frequency],
			:Memo => defaults[:memo],
			:TaxAmount => defaults[:tax_amount],
			:TotalAmount => defaults[:total_amount],
			:ProcessCompleteUrl => defaults[:process_complete_url],
			:ReturnUrl => defaults[:return_url],
			:Invoice => defaults[:invoice],
			:DisplayStyle => defaults[:display_style],
			:DefaultSwipe => defaults[:default_swipe]
		}

		# return convert_to_xml message

		begin
			xml_conversion = convert_to_xml(message, "InitializePayment")
			response = @client.call(:initialize_payment, xml: xml_conversion).to_hash
		rescue Exception => e
			throw_error e.message
		end

		response_data = response[:initialize_payment_response][:initialize_payment_result]
		check_for_error_response response_data

		return response
	end




	def verify_payment payment_id
		message = {
			:MerchantID => @merchant_id,
			:PaymentID => payment_id,
			:Password => @password
		}
		begin
			xml_conversion = convert_to_xml(message,"VerifyPayment")
			response = @client.call(:verify_payment, xml: xml_conversion).to_hash
		rescue Exception => e
			throw_error e.message
		end

		# response_data = response[]

		return response
	end

	def initialize_card_info opts
		required_opts = [:process_complete_url, :return_url]
		check_required_opts required_opts, opts

		defaults ={

		}

		opts.each do |key, val|
			defaults[:"#{key}"] = val
		end


		message = {
			:MerchantID => @merchant_id,
			:Password => @password,
			:Frequency => "OneTime",
			:ProcessCompleteUrl => defaults[:process_complete_url],
			:ReturnUrl => defaults[:return_url]
		}

		begin
			xml_conversion = convert_to_xml(message, "InitializeCardInfo" )
			response = @client.call(:initialize_card_info, xml: xml_conversion).to_hash
		rescue Exception => e
			throw_error e.message
		end

		return response
		
	end

	def verify_card_info card_id	

		message = {
			:MerchantID => @merchant_id,
			:Password => @password,
			:CardID => card_id
		}

		begin
			xml_conversion = convert_to_xml(message, "VerifyCardInfo")
			response = @client.call(:verify_card_info, xml: xml_conversion).to_hash
		rescue Exception => e
			throw_error e.message
		end

		return response

	end

	def upload_css css = nil
		default_css = "
						 body.bodyPOSIFrame{font-family:helvetica;}
						 .txtPOS{width:145px; border-color:#d1d1d1; padding-top:0px; font-size:14px; color:#BAC6CC; height:28px; border-radius:5px; margin-left:10px;}\
						 .txtDisabledPOS{width:145px; border-color:transparent; background-color:#6d8293; padding-top:0px; font-size:14px; color:#BAC6CC; height:28px; border-radius:0; margin-left:10px;}\
						 .divTextBoxPOS{width:170px; margin-left:0; margin-top:5px; height:34px;}\
						 #divMainPOSIFrame{white-space: normal; width:100%;}\
						 .divLinePOS{float:left; text-align:left; height:auto; width:96%; padding-left:0; margin-left:2%; margin-bottom:0px; background-color:transparent; border-radius:38px; margin-top:5px;}\
						 .divLabelPOS{float:left; text-align:left; width:106px; background-color:transparent; margin-top:5px; padding-top:4px; padding-bottom:10px;}\
						 #divButtonsPOS{margin-left:0px; float:left; width:100%; margin-top:14px; height:40px;}\
						 .btnDisabledPOS{width:100%; margin-left:0; background-color:#353E47; border-color:transparent; border-radius: 0;color:#C7CFD5; margin-top:0; font-size:16px; padding-top:10px; padding-bottom:10px;}\
						 .btnDefaultIFramePOS{width:auto; margin-left:0; background-color:#005FBE; border-color:transparent; color:white; margin-top:0; font-size:16px; padding-top:7px; padding-bottom:7px; float:right; margin-right:20px; border-radius:3px; cursor:pointer; border-bottom-color: #004C97; border-bottom-style: solid; border-bottom-width: 3px;}\
						 .btnDefaultIFramePOS:hover{width:auto; margin-left:0; background-color:#005FBE; border-color:transparent; color:white; margin-top:0; font-size:16px; padding-top:7px; padding-bottom:7px; float:right; margin-right:20px; border-radius:3px; cursor:pointer; border-bottom-color: #004C97; border-bottom-style: solid; border-bottom-width: 3px;}\
						 .divValidatorsPOS{padding-top:0px;}\
						 #divRadioButtonsPOS{width:300px; margin-left:4px; display:none;}\
						 #divUserInputPOSIFrame{width:100%; height: auto; float:left; margin-top:0px; position:static; background-color:white; padding-bottom:20px; border-radius:10px; padding-top:13px;}\
						 .divTotalPOSIFrameDefault{width:100%; height:157px; padding-left:0; padding-top:40px; padding-bottom:0px; margin-left:0px; text-align:center; background-color:#7BF264; display:none;}\
						 .lblTotalAmountPOS{color:#7bf264; display:none;}\
						 #lblTotalAmountValue{color: #7BF264; font-weight: 200; font-size: 23px; margin-right: 0; display: block; margin-top: 90px; background-color: white; padding-top: 10px; padding-bottom: 10px;}\
						 .lblDefaultPOS{color:#838383; font-size:14px; margin-top:4px; float:right; margin-left:20px;}\

						 .divValidatorsPOS{padding-top: 0px; width: 98%; padding:1%; margin-left: 0px; background-color: #CF6338;}
						 .lblValidationError{font-size: small; color: #923F1F; width: 100%;}
						 "
		css = css ? css : default_css

		message = {
			:MerchantID => @merchant_id,
			:Password => @password,
			:Css => css
		}

		begin
			xml_conversion = convert_to = convert_to_xml(message, "UploadCSS")
			response = @client.call(:upload_css, xml: xml_conversion).to_hash
		rescue Exception => e
			throw_error e.message
		end

		return response
	end

	def download_css css

		message = {
			:MerchantID => @merchant_id,
			:Password => @password,
			:Css => css
		}

		begin
			xml_conversion = convert_to = convert_to_xml(message, "DownloadCSS")
			response = @client.call(:download_css, xml: xml_conversion).to_hash
		rescue Exception => e
			throw_error e.message
		end

		return response
	end

	def remove_css 

		message = {
			:MerchantID => @merchant_id,
			:Password => @password	
		}

		begin
			xml_conversion = convert_to = convert_to_xml(message, "RemoveCSS")
			response = @client.call(:remove_css, xml: xml_conversion).to_hash
		rescue Exception => e
			throw_error e.message
		end

		return response
	end

	def adjust

	end

	def return

	end

	def voice_auth

	end

	def credit_void_sale_token opts

		required_opts = [:token, :purchase_amount, :invoice, :ref_no, :auth_code]
		check_required_opts required_opts, opts

		defaults ={
			:frequency => 'OneTime',
			:memo => 'Bookafy Test v1.0'	
		}


		opts.each do |key, val|
			defaults[:"#{key}"] = val
		end

		message = {
			:MerchantID => @merchant_id,
			:Password => @password,
			:Token => defaults[:token],
			:Frequency => defaults[:frequency],
			:PurchaseAmount => defaults[:purchase_amount],
			:MerchantID => @merchant_id,
			:Password => @password,
			:Invoice => defaults[:invoice],
			:RefNo => defaults[:ref_no],
			:AuthCode => defaults[:auth_code],
			:Memo => defaults[:memo]
			# :TerminalName => defaults[:terminal_name],
			# :OperatorID => defaults[:operator_id],
			# :CardHolderName => defaults[:cardholder_name]
		}

		begin
			xml_conversion = convert_to_xml(message, "CreditVoidSaleToken" )
			response = @client1.call(:credit_void_sale_token, xml: xml_conversion).to_hash
		rescue Exception => e
			throw_error e.message
		end

		return response

	end


	def reversal
		# Reversal (VoidSale + AcqRefData +ProcessData) 

		required_opts = [:invoice_no, :ref_no, :acct_no, :exp_date, :amount, :encrypted_block, :encrypted_key]
		check_required_opts required_opts, opts

		#instore, register, drive thru if true swipe
		# declare defaults. will be overwritten by opts
		defaults = {
			:tran_type => 'Credit',
			:frequency => 'OneTime',
			:partial_auth => 'Allow',
			:tran_code => 'Sale',
			:ref_no => 1,
			:memo => 'Bookafy Test v1.0',
			:encrypted_format => "MagneSafe",
			:account_source => "Swiped",
			:tax_amount => 0.00,
		}

		opts.each do |key, val|
			defaults[:"#{key}"] = val
		end

		# return defaults

		values = {
			:MerchantID => @merchant_id,
			:Password => @password,
			:TranType => defaults[:tran_type],
			:PartialAuth => defaults[:partial_auth],
			:TranCode => defaults[:tran_code],
			:InvoiceNo => defaults[:invoice],
			:Frequency => defaults[:frequency],
			:Memo => defaults[:memo],
			:EncryptedFormat => defaults[:encrypted_format],
			:AccountSource => defaults[:account_source],
			:EncryptedBlock => defaults[:encrypted_block],
			:EncryptedKey => defaults[:encrypted_key],
			:Purchase => defaults[:total_amount],
		}

		xml = 	'<?xml version="1.0"?>
				<TStream>
					<Transaction>
						<MerchantID>'+@merchant_id+'</MerchantID>
						<TranCode>VoidSaleByRecordNo</TranCode>
						<InvoiceNo>38</InvoiceNo>
						<RefNo>38</RefNo>
						<Memo>MPSPOS</Memo>
						<Account>
							<RecordNo>4003000123456781</RecordNo>
						</Account>
						<Amount>
						    <Purchase>3.00</Purchase>
						</Amount>
						<TranInfo>
							<AcqRefData>aNd5</AcqRefData>
							<ProcessData>|14|410100201000</ProcessData>
							<AuthCode>00007</AuthCode>
						</TranInfo>
					</Transaction>
				</TStream>'
	end

	def void_return

	end

	def preauth

	end

	def preauth_capture

	end


end
