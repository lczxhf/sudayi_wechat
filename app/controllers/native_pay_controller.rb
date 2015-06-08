class NativePayController < ApplicationController
	require 'nokogiri'
	skip_before_action :verify_authenticity_token
	
	def callback
		input=Nokogiri::Slop request.body.read
		puts params
		redirect_to :controller=>:test_pay,:action=>:pay,:openid=>input.xml.openid.content,:type=>"qrcode",:product_id=>input.xml.product_id.content
	
	end
	
	def pay_result
		puts params
		puts request.body.read
		render xml: "<xml><return_code><![CDATA[SUCCESS]]></return_code></xml>"
	end
end
