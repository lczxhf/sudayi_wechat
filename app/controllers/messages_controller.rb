class MessagesController < ApplicationController
	require 'net/http'
  require "nokogiri"
  include ReplyWeixinMessageHelper
   skip_before_action :verify_authenticity_token
   
   before_action do
	@wechat_info=WechatInfo.first
   end
   def receive
		gzh=AuthCode.where(appid:params[:appid]).first
		str=request.body.read
		puts str
		doc=Nokogiri::Slop str
		encrypt=doc.xml.Encrypt.content
		if Wechat.check_info(@wechat_info.token,params[:timestamp],params[:nonce],encrypt,params[:msg_signature])
			result=Wechat.new.decrypt(encrypt,@wechat_info.encodingkey,@wechat_info.appid)		
			puts result
			xml=Nokogiri::Slop result
			hash={}
			xml.xml.css('*').each do |a|
			    hash[a.node_name]=a.content
			end
			@weixin_message=Message.factory hash
			if @weixin_message.MsgType=='event'
			    if @weixin_message.Event=='subscribe'
				render xml: reply_text_message('欢迎')	
			    else
				
			    end
			elsif @weixin_message.MsgType=='text'
				abc='https://open.weixin.qq.com/connect/oauth2/authorize?appid='+gzh.appid+'&redirect_uri=http://shop.29mins.com/gzh_manages/authorize&response_type=code&scope=snsapi_userinfo&state=200&component_appid='+@wechat_info.appid+'#wechat_redirect'
				render xml: reply_text_message(abc)	
			else
			    	render xml: reply_text_message(qrcode['url'])
			end
		end
   end

end
