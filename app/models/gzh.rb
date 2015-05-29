class Gzh
	require 'net/http/post/multipart'
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
	
	def self.upload_media(token,media,type,content_type,name)
		url = URI.parse('https://api.weixin.qq.com/cgi-bin/media/upload?access_token='+token+'&type='+type)
		req = Net::HTTP::Post::Multipart.new url,
  		"media" =>UploadIO.new(media, content_type,name)
		res = Net::HTTP.start(url.host, url.port,:use_ssl => url.scheme == 'https') do |http|
  		http.request(req)	
	        end
        end
	
	def self.get_media(token,media_id)
		url=URI.parse('https://api.weixin.qq.com/cgi-bin/media/get?access_token='+toekn+'&media_id='+media_id)
		Wechat.get_to_wechat(url)
	end
	
	def self.upload_forever_media(token,type,media,content_type,name,title="",introduction="")
		url=URI.parse('https://api.weixin.qq.com/cgi-bin/material/add_material?access_token='+token)
		   description='{"title":"'+title+'","introduction":"'+introducion+'"}'
		 req = Net::HTTP::Post::Multipart.new url,
                "media" =>UploadIO.new(media, content_type,name),
		"type" =>type,
		"description"=>description
                res = Net::HTTP.start(url.host, url.port,:use_ssl => url.scheme == 'https') do |http|
                http.request(req)        
                end
	end


	def upload_news(token,array)
		url='https://api.weixin.qq.com/cgi-bin/material/add_news?access_token='+token
		body='{"articles":['
		array.each do |content|
		body+='{"title":"'+content['title']+'","thumb_media_id":"'+content['media_id']+'","author":"'+content['author']+'","digest":"'+content['digest']+'","show_cover_pic":"'+content['is_cover']+'","content":"'+content['content']+'","content_source_url":"'+content['url']+'"},'
		end
		body=body[0...body.length-1]+']}'
		Wechat.sent_to_wechat(url,body)
	end
	
	def update_news(token,media_id,index,hash)
		url='https://api.weixin.qq.com/cgi-bin/material/update_news?access_token='+token
		body='{"media_id":"'+media_id+'","index":"'+index+'","articles":{"title":"'+hash['title']+'","thumb_media_id":"'+hash['media_id']+'","author":"'+hash['author']+'","digest":"'+hash['digest']+'","show_cover_pic":"'+hash['is_cover']+'","content":"'+hash['content']+'","content_source_url":"'+hash['url']+'"}}'
		Wechat.sent_to_wechat(url,body)
	end
	
	def get_or_del_forever_media(token,media_id,type='get')
		url='https://api.weixin.qq.com/cgi-bin/material/'+type+'_material?access_token='+token
		body='{"media_id":"'+media_id+'"}'
		Wechat.sent_to_wechat(url,body)
	end
	
	def get_media_sum(token)
		url='https://api.weixin.qq.com/cgi-bin/material/get_materialcount?access_token='+token
		Wechat.get_to_wechat(url)
	end
	
	def get_media_list(token,type,offset,count)
		url='https://api.weixin.qq.com/cgi-bin/material/batchget_material?access_token='+token
		body='{"type":"'+type+'","offset":"'+offset+'","count":"'+count+'"}'
		Wechat.sent_to_wechat(url,body)
	end
end
