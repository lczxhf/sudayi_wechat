module TestPayHelper
	module Sign
	  require 'digest/md5'
	  def self.generate(params)
             query = params.sort.collect do |key, value|
        	"#{key}=#{value}"
       	     end.join('&')
      	     Digest::MD5.hexdigest("#{query}&key=ed581e944eaa35855262c4eb809da198").upcase
          end

    	  def self.verify?(params)
      		params = params.dup
      		sign = params.delete('sign') || params.delete(:sign)
      		generate(params) == sign
    	  end
	end

	module PayXml
		@auth_code=AuthCode.first
		MACID='1245225302'
		def self.get_xml(params,is_qrcode=false)
			 params = {
        			nonce_str: SecureRandom.uuid.tr('-', ''),
				appid: @auth_code.appid,
                   		mch_id: MACID,
      			 }.merge(params)
		  if is_qrcode
			'weixin://wxpay/bizpayurl?'+params.collect{|k,v| "#{k}=#{v}&"}.join+"sign="+TestPayHelper::Sign.generate(params)
		  else
			"<xml>#{params.collect { |k, v| "<#{k}>#{v}</#{k}>" }.join}<sign>#{TestPayHelper::Sign.generate(params)}</sign></xml>"
		  end
		end

		def self.get_json(params)
		   params={
		      appId: @auth_code.appid,
		      timeStamp: Time.now.to_i.to_s,
		      nonceStr: SecureRandom.uuid.tr('-', ''),
		      signType: 'MD5', 
		   }.merge(params)
		   params.merge({paySign: TestPayHelper::Sign.generate(params)})
		end
	end
	
	module Qrcode
		require 'rqrcode_png'
		def self.qcode(url)
    		#二维码
    		qr=RQRCode::QRCode.new(url,:size=>14,:level=>:h).to_img
		qr.resize(200, 200).save(Rails.root.to_s+"/public/abc.png")

  		end
	end
end
