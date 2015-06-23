class GzhManagesController < ApplicationController
	 require 'net/http'
  require "nokogiri"
   skip_before_action :verify_authenticity_token	
	before_action do
	  @wechat_info=WechatInfo.first
	end
	def set_menu
        gzhs=AuthCode.all
        gzhs.each do |gzh|
                if Time.now-gzh.updated_at>=7200
                        result=JSON.parse(Wechat.refresh_gzh_token(@wechat_info.access_token,@wechat_info.appid,gzh.appid,gzh.refresh_token))
                        gzh.refresh_token=result['authorizer_refresh_token']
                        gzh.token=result['authorizer_access_token']
                        gzh.save
                end
                 url='https://api.weixin.qq.com/cgi-bin/menu/create?access_token='+gzh.token
		body='{"button":[{"name":"扫码","sub_button":[{"type":"scancode_waitmsg","name":"扫码带提示","key":"rselfmenu_0_0","sub_button":[]},{"type":"scancode_push","name":"扫码推事件","key":"rselfmenu_0_1","sub_button":[]}]},{"name":"发图","sub_button":[{"type":"pic_sysphoto","name":"系统拍照发图","key":"rselfmenu_1_0","sub_button":[]},{"type":"pic_photo_or_album","name":"拍照或者相册发图","key":"rselfmenu_1_1","sub_button":[]},{"type":"pic_weixin","name":"微信相册发图","key":"rselfmenu_1_2","sub_button":[]}]},{"name":"发送位置","type":"location_select","key":"rselfmenu_2_0"}]}'
		#body='{"button":[{"name":"发图","sub_button":[{"type":"pic_sysphoto","name":"系统拍照发图","key":"rselfmenu_1_0","sub_button":[]},{"type":"pic_photo_or_album","name":"拍照或者相册发图","key":"rselfmenu_1_1","sub_button":[]},{"type":"pic_weixin","name":"微信相册发图","key":"rselfmenu_1_2","sub_button":[]}]},{"type":"media_id","name":"图片","media_id":"MEDIA_ID1"},{"type":"view_limited","name":"图文消息","media_id":"MEDIA_ID2"}]}'
                result=Wechat.sent_to_wechat(url,body)
		puts result
        end
        render nothing: true
  end
   

	def authorize
		if params[:appid]
			
			gzh=AuthCode.where(appid:params[:appid]).first
			wechater_code=WechaterCode.new(code:params[:code])	
			wechater_code.auth_code=gzh
			url="https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{gzh.appid}&code=#{params[:code]}&grant_type=authorization_code&component_appid=#{@wechat_info.appid}&component_access_token="+@wechat_info.access_token
			body=""
			result=JSON.parse(Wechat.sent_to_wechat(url,body))
			puts result
			if previous=WechaterCode.where(openid:result['openid'],auth_code_id:gzh._id).first
			   previous.delete
			end
			wechater_code.token=result['access_token']
			wechater_code.refresh_token=result['refresh_token']
			wechater_code.openid=result['openid']
			wechater_code.scope<<result['scope']
			wechater_code.save
			redirect_to :action=>'get_info',:id=>wechater_code._id
		end
	end
	
	def get_info
		wechater_code=WechaterCode.find(params[:id])
		if Time.now-wechater_code.updated_at>=7200
		     result=JSON.parse(Gzh.refresh_token(wechater_code.auth_code.appid,wechater_code.refresh_token,@wechat_info.appid,@wechat_info.access_token))
		    wechater_code.token=result['access_token']
		    wechater_code.refresh_token=result['refresh_token']
		    wechater_code.openid=result['openid']
		    wechater_code.scope=[result['scope']]
		    wechater_code.save
		end
		url="https://api.weixin.qq.com/sns/userinfo?access_token=#{wechater_code.token}&openid=#{wechater_code.openid}&lang=zh_CN"
		info=JSON.parse(Wechat.get_to_wechat(url)) 
		puts info
		wechater_info=WechaterInfo.new
		wechater_info.nick_name=info['nickname']
		wechater_info.sex=info['sex']=='1'?true:false
		wechater_info.province=info['province']
		wechater_info.city=info['city']
		wechater_info.country=info['country']
		wechater_info.head_image=info['headimgurl']
		wechater_info.privilege=info['privilege']
		wechater_info.unionid=info['unionid']
		wechater_info.wechater_code=wechater_code
		wechater_info.save
		hash={}
		hash['first']='恭喜你成为速达易会员'
		hash['keyword1']=info['nickname']
		hash['keyword2']=(Time.now+1.year).strftime('%Y%m%d').to_s
		hash['remark']='更多详情请关注速达易'
		 Gzh.sent_template_message(wechater_code.auth_code.token,wechater_code.openid,"E3PgD8slAbZ03ZvYVtD_S5y-ekdTKpSXs64docm8Ojc","http://shop.29mins.com/wechats/home",hash)

		render plain: 'ok'
	end
	
	def test
		result=Gzh.fetch_qrcode('gQFR8DoAAAAAAAAAASxodHRwOi8vd2VpeGluLnFxLmNvbS9xL1JIV1B6akRsVUdBcDlWZ0MybHNLAAIENtFmVQMEgDoJAA==')
		image=MiniMagick::Image.read(result)	
		path=File.join( Rails.root.to_s, 'public','abc.jpg')
		image.write path
		FileUtils.chmod("+r",path)
		render nothing: true
	end

	def sent_message_to_one
	   auth_code=AuthCode.last
           result=JSON.parse(Gzh.sentall_preview(auth_code.token,'oE_fQskOrf3LhUAdargG_UPHVVDo','image',['media_id','V1Bf1tN4j23yM3gWznsgPC5LOOJMqMe754A3lrDMX6Dl1bFVjLo94cGLAqoMRJNq','abc','lzh']))
	end
end
