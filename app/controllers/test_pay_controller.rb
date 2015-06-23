class TestPayController < ApplicationController
	include TestPayHelper
	require 'nokogiri'
	require 'net/https'
	require 'rest-client'
	 skip_before_action :verify_authenticity_token
	  WECHATURL='https://api.mch.weixin.qq.com/pay/'
	def pay
		puts params
		url=WECHATURL+'unifiedorder'
		hash={
		   spbill_create_ip: request.remote_ip, 
                   trade_type: params[:type] ? "NATIVE":'JSAPI',
		   #openid: params[:openid],
		   body: '好看的衣服啊',
		   out_trade_no: SecureRandom.hex,
		   total_fee: 1,
		   notify_url: 'http://shop.29mins.com/test_pay/callback'
		}
		if params[:type]=="qrcode"
			hash.merge({product_id: params[:product_id],notify_url:'http://shop.29mins.com/native_pay/pay_result'})
		else
			hash.merge({openid: params[:openid]})
		end
		body=PayXml.get_xml(hash)	
		result=Wechat.sent_to_wechat(url,body)
		doc=Nokogiri::Slop result
		puts doc
		if params[:type]=="qrcode"
			
		#	qr_hash={
		#	   return_code: "SUCCESS",
		#	   prepay_id: doc.xml.prepay_id.content,
		#	   result_code: "SUCCESS",
		#	}
		#	xml=PayXml.get_xml(qr_hash)
		#	puts xml
		#	render xml: xml
			Qrcode.qcode(doc.xml.code_url.content)
			@url1="http://shop.29mins.com/abc.png"
			render action: :my_pay
		#	render location: doc.xml.code_url.content,status: 302
		else
		  hash1={
                     package: "prepay_id=#{doc.xml.prepay_id.content}"
                  }
                  @option=PayXml.get_json(hash1).to_json
                  puts @option
		end
	end
	
	def result
		puts params
	end
	
	def get_order
		url=WECHATURL+'orderquery'
		hash={
		   out_trade_no: '4cefab6e1c2b2d02fb9d240a1afb3e78'
		}	
		 body=PayXml.get_xml(hash)
                result=Wechat.sent_to_wechat(url,body)
                doc=Nokogiri::Slop result
                puts doc
		
	end
	
	def callback
		puts params
		puts request.body.read
		render xml: "<xml><return_code><![CDATA[SUCCESS]]></return_code></xml>"
	end

	def qr_pay
		auth_code=AuthCode.last
		hash={
		  time_stamp: Time.now.to_i.to_s,
		  product_id: '123',
		}
		body=PayXml.get_xml(hash,true)
		 Qrcode.qcode(body)
		 qrcode=File.open(Rails.root.to_s+"/public/abc.png")
		result=JSON.parse(Gzh.upload_media(auth_code.token,qrcode,'image','my_qrcode'))
		puts result
	end
	
	def redbage
		hash={
		  nick_name: 'sudayi',
		  send_name: 'sudayi',
		  re_openid: 'ozn7njomLZVrNlqmRD3L93tEFvCo',
		  total_amount: 100,
		  min_value: 100,
		  max_value: 100,
		  total_num: 1,
		  wishing: 'happy',
		  act_name: 'test',
		  remark: "you are welcome"
		}
		body=Redbage.get_xml(hash)
		url='https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack'
		uri = URI(url)
             	#Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
                #   request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/xml'})
                #  request.body=body
                   p12 = OpenSSL::PKCS12.new(File.open(Rails.root.to_s+"/apiclient_cert.p12","rb").read,"1245225302")
                #   http.cert = OpenSSL::X509::Certificate.new(p12.certificate)
                #   http.key = OpenSSL::PKey::RSA.new(p12.key)
		#   http.ca_file = Rails.root.to_s+"/rootca.pem"
                #   http.verify_mode = OpenSSL::SSL::VERIFY_PEER 
		#   http.ciphers=cipher
		#   response=http.request request
                #   puts response.body
                #end
		response=RestClient::Resource.new(
  			url, 
			  :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(p12.certificate), 
 			 :ssl_client_key   =>  OpenSSL::PKey::RSA.new(p12.key),
 			 :ssl_ca_file      =>  Rails.root.to_s+"/rootca.pem" , 
			  :verify_ssl       =>  OpenSSL::SSL::VERIFY_PEER 
		).post(body)
		puts response.body
		render nothing: true
	end
	end
