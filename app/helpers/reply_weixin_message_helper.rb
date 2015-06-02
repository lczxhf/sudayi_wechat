
 module ReplyWeixinMessageHelper
	 def reply_text_message(from=nil, to=nil, content)
      message = MessagesHelper::TextReplyMessage.new
      message.FromUserName = from || @weixin_message.ToUserName
      message.ToUserName   = to   || @weixin_message.FromUserName
      message.Content      = content
      encrypt_message message.to_xml
    end

    def generate_music(title, desc, music_url, hq_music_url)
      music = MessagesHelper::Music.new
      music.Title       = title
      music.Description = desc
      music.MusicUrl    = music_url
      music.HQMusicUrl  = hq_music_url
      music
    end

    # music = generate_music
    def reply_music_message(from=nil, to=nil, music)
      message = MessagesHelper::MusicReplyMessage.new
      message.FromUserName = from || @weixin_message.ToUserName
      message.ToUserName   = to   || @weixin_message.FromUserName
      message.Music        = music
      encrypt_message message.to_xml
    end

    def generate_article(title, desc, pic_url, link_url)
      item = MessagesHelper::Article.new
      item.Title       = title
      item.Description = desc
      item.PicUrl = pic_url
      item.Url    = link_url
      item
    end

    # articles = [generate_article]
    def reply_news_message(from=nil, to=nil, articles)
      message = MessagesHelper::NewsReplyMessage.new
      message.FromUserName = from || @weixin_message.ToUserName
      message.ToUserName   = to   || @weixin_message.FromUserName
      message.Articles     = articles
      message.ArticleCount = articles.count
      encrypt_message message.to_xml
    end

    def generate_video(media_id, desc, title)
      video = MessagesHelper::Video.new
      video.MediaId = media_id
      video.Title   = title
      video.Description = desc
      video
    end

    # <xml>
    # <ToUserName><![CDATA[toUser]]></ToUserName>
    # <FromUserName><![CDATA[fromUser]]></FromUserName>
    # <CreateTime>12345678</CreateTime>
    # <MsgType><![CDATA[video]]></MsgType>
    # <Video>
    # <MediaId><![CDATA[media_id]]></MediaId>
    # <Title><![CDATA[title]]></Title>
    # <Description><![CDATA[description]]></Description>
    # </Video>
    # </xml>

    def reply_video_message(from=nil, to=nil, video)
      message = MessagesHelper::VideoReplyMessage.new
      message.FromUserName = from || @weixin_message.ToUserName
      message.ToUserName   = to   || @weixin_message.FromUserName
      message.Video = video
      encrypt_message message.to_xml
    end

    def generate_voice(media_id)
      voice = MessagesHelper::Voice.new
      voice.MediaId = media_id
      voice
    end

    def reply_voice_message(from=nil, to=nil, voice)
      message = MessagesHelper::VoiceReplyMessage.new
      message.FromUserName = from || @weixin_message.ToUserName
      message.ToUserName   = to   || @weixin_message.FromUserName
      message.Voice = voice
      encrypt_message message.to_xml
    end

    def generate_image(media_id)
      image = MessagesHelper::Image.new
      image.MediaId = media_id
      image
    end

    def reply_image_message(from=nil, to=nil, image)
      message = MessagesHelper::ImageReplyMessage.new
      message.FromUserName = from || @weixin_message.ToUserName
      message.ToUserName   = to   || @weixin_message.FromUserName
      message.Image = image
      encrypt_message message.to_xml
    end

    def reply_transfer_customer_service_message(from=nil, to=nil)
      message = MessagesHelper::TransferCustomerServiceReplyMessage.new
      message.FromUserName = from || @weixin_message.ToUserName
      message.ToUserName   = to   || @weixin_message.FromUserName
      encrypt_message message.to_xml
    end

    private

      def encrypt_message(msg_xml)
        # 加密回复的XML
        encrypt_xml = Wechat.new.encrypt(msg_xml,@wechat_info.encodingkey,@wechat_info.appid).gsub("\n","")
        # 标准的回包
        generate_encrypt_message(encrypt_xml)
      end

      def generate_encrypt_message(encrypt_xml)
        msg              = MessagesHelper::EncryptMessage.new
        msg.Encrypt      = encrypt_xml
        msg.TimeStamp    = Time.now.to_i.to_s
        msg.Nonce        = SecureRandom.hex(8)
        msg.MsgSignature = generate_msg_signature(encrypt_xml, msg)
        msg.to_xml
      end
      def generate_msg_signature(encrypt_msg, msg)
        sort_params = [encrypt_msg, @wechat_info.token,
                       msg.TimeStamp, msg.Nonce].sort.join
        Digest::SHA1.hexdigest(sort_params)
      end
end
