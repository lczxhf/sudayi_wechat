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
                result=Wechat.sent_to_wechat(url,body)
		puts result
        end
        render nothing: true
  end
   

	def authorize
		if params[:appid]
			gzh=AuthCode.where(appid:params[:appid]).first
			wechater_code=WechaterCode.new(auth_code:params[:code])	
			wechater_code.auth_code=gzh
			url="https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{gzh.appid}&code=#{params[:code]}&grant_type=authorization_code&component_appid=#{@wechat_info.appid}&component_access_token="+@wechat_info.access_token
			body=""
			result=JSON.parse(Wechat.sent_to_wechat(url,body))
			puts result
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
		render plain: 'ok'
	end
end
