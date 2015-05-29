class Gzh
	def self.refresh_token(appid,refresh_token,c_appid,c_token)
		url="https://api.weixin.qq.com/sns/oauth2/component/refresh_token?appid=#{appid}&grant_type=refresh_token&component_appid=#{c_appid}&component_access_token=#{c_token}&refresh_token="+refresh_token
		body=""
		Wechat.sent_to_wechat(url,body)
	end	
	
	def self.sent_template_message(token,openid,template_id,url,hash)
		 template_url='https://api.weixin.qq.com/cgi-bin/message/template/send?access_token='+token
				data=""
		    		hash.each do |key,value|
				    data+='"'+key+'":{"value":"'+value+'","color":"#173177"},'
				end	
				data=data[0...data.length-1]
                                template_body='{"touser":"'+openid+'","template_id":"'+template_id+'","url":"'+url+'","topcolor":"#FF0000","data":{'+data+'}}'
                                template_result=JSON.parse(Wechat.sent_to_wechat(template_url,template_body))
                                puts template_result
	end


	def self.get_qrcode(token,action,expire="",scene_id="",scene_str="")
	url="https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token="+token
		case action
		when 'QR_SCENE' then
		   body='{"expire_seconds":'+expire.to_s+', "action_name": "QR_SCENE", "action_info": {"scene": {"scene_id":'+scene_id.to_s+'}}}'
		when 'QR_LIMIT_SCENE' then
		   if !scene_id.empty?
		      body='{"action_name": "QR_LIMIT_SCENE", "action_info": {"scene": {"scene_id":'+scene_id+'}}}'
		   else
		      body='{"action_name": "QR_LIMIT_SCENE", "action_info": {"scene": {"scene_str":'+scene_str+'}}}'
		   end
		end
                result=JSON.parse(Wechat.sent_to_wechat(url,body))
		result
	end
	
	def self.fetch_qrcode(ticket)
		url='https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket='+ticket
		Wechat.get_to_wechat(url)	
	end
end
