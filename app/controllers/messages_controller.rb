class MessagesController < ApplicationController
	require 'net/http'
  require "rexml/document"
  include ReplyWeixinMessageHelper
   skip_before_action :verify_authenticity_token
   
   before_action do
	@wechat_info=WechatInfo.first
   end

   def receive
   		puts params
   end
end
