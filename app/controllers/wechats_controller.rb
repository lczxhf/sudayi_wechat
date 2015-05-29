class WechatsController < ApplicationController
	require 'nokogiri'
	require 'net/http/post/multipart'
   skip_before_action :verify_authenticity_token
   
   before_action do
	@wechat_info=WechatInfo.first
   end

 def home 
	@url="https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{@wechat_info.appid}&pre_auth_code=#{@wechat_info.pre_auth_code}&redirect_uri=http://shop.29mins.com/wechats/auth_code"
	
 end
 def test
	auth_code=AuthCode.first
	url = URI.parse('https://api.weixin.qq.com/cgi-bin/media/upload?access_token='+auth_code.token+'&type=image')
	req = Net::HTTP::Post::Multipart.new url.path,
  	"file1" =>UploadIO.new(params[:url], "image/jpeg", "image.jpg")
	res = Net::HTTP.start(url.host, url.port,:use_ssl => url.scheme == 'https') do |http|
  	http.request(req)
	puts 'aa'
end
	puts req.inspect
	render nothing: true
 end

 def test2
	auth_code=AuthCode.first
	url='https://api.weixin.qq.com/cgi-bin/material/get_materialcount?access_token='+auth_code.token
	puts url
	result=JSON.parse(Wechat.get_to_wechat(url))
	puts result
 end 
 def receive
       puts params
	str=request.body.read
	puts str
	doc=Nokogiri::Slop str
	ticket=doc.xml.Encrypt.content	
	
	if Wechat.check_info(@wechat_info.token,params[:timestamp],params[:nonce],ticket,params[:msg_signature])
		result=Wechat.new.decrypt(ticket.to_s,@wechat_info.encodingkey,@wechat_info.appid)
		puts result
		xml=Nokogiri::Slop result
		if xml.xml.InfoType.content.to_s=='component_verify_ticket'
		   verify_ticket=xml.xml.ComponentVerifyTicket.content
		   @wechat_info.ticket=verify_ticket.to_s
		   url='https://api.weixin.qq.com/cgi-bin/component/api_component_token'
		   body='{"component_appid":"'+@wechat_info.appid+'","component_appsecret":"'+@wechat_info.appsecret+'","component_verify_ticket":"'+@wechat_info.ticket+'"}'
		   @wechat_info.access_token=JSON.parse(Wechat.sent_to_wechat(url,body))['component_access_token']
		   url='https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token='+@wechat_info.access_token
		   body='{"component_appid":"'+@wechat_info.appid+'"}'
		   @wechat_info.pre_auth_code=JSON.parse(Wechat.sent_to_wechat(url,body))['pre_auth_code']
		   @wechat_info.save
		else
		   appid=xml_root.get_elements('AuthorizerAppid')[0][0].to_s
		   AuthCode.where(appid:appid).first.delete
		end
	else
		puts 'error'
	end
	render plain:'success'
 end


 def auth_code 
	puts params
	
	url='https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token='+@wechat_info.access_token
	body='{"component_appid":"'+@wechat_info.appid+'"," authorization_code": "'+params[:auth_code]+'"}'
	puts body
	result=Wechat.sent_to_wechat(url,body)
	auth_code=AuthCode.create(code:params[:auth_code])
	puts result.to_json
	redirect_to :action=>'gzh_parameter',:auth_code_id=>auth_code._id
 end

 def gzh_parameter 
	auth_code=AuthCode.find(params[:auth_code_id])
	url='https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token='+@wechat_info.access_token
        body='{"component_appid":"'+@wechat_info.appid+'","authorization_code":"'+auth_code.code+'"}'
        result=Wechat.sent_to_wechat(url,body)
	puts result.to_json
	json=JSON.parse(result)
	auth_code.token=json['authorization_info']['authorizer_access_token']
	auth_code.appid=json['authorization_info']['authorizer_appid']
	auth_code.refresh_token=json['authorization_info']['authorizer_refresh_token']
	arr=[]
	json['authorization_info']['func_info'].each do |a|
		arr<<a['funcscope_category']['id']
	end
	auth_code.func_info=arr
	auth_code.save
	redirect_to :action=>'gzh_info',auth_code_id:auth_code._id
 end

 def gzh_info 
	auth_code=AuthCode.find(params[:auth_code_id])
	if auth_code.gzh_info
	   gzh_info=auth_code.gzh_info
	else
	   gzh_info=GzhInfo.new
	   gzh_info.auth_code=auth_code
	end
	url='https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_info?component_access_token='+@wechat_info.access_token
	body='{"component_appid":"'+@wechat_info.appid+'","authorizer_appid":"'+auth_code.appid+'"}'
	result=JSON.parse(Wechat.sent_to_wechat(url,body))['authorizer_info']
	gzh_info.nick_name=result['nick_name']
	gzh_info.head_image=result['head_img']
	gzh_info.service_type=result['service_type_info']['id']
	gzh_info.verify_type=result['verify_type_info']['id']
	gzh_info.user_name=result['user_name']
	gzh_info.alias=result['alias']
	gzh_info.qrcode_url=result['qrcode_url']
	gzh_info.save
	redirect_to :action=>'option_info',auth_code_id:auth_code._id
 end

 def option_info 
	auth_code=AuthCode.find(params[:auth_code_id])
	option=['location_report','voice_recognize','customer_service']
	url='https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_option?component_access_token='+@wechat_info.access_token
	option.each do |a|
	  body='{"component_appid":"'+@wechat_info.appid+'","authorizer_appid":"'+auth_code.appid+'","option_name":"'+a+'"}'
	  result=JSON.parse(Wechat.sent_to_wechat(url,body))['option_value']
	  auth_code.gzh_info.send(a+'=',result)
	end
	auth_code.gzh_info.save
	render plain:'ok'
  end
end
