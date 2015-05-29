class WechatImage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message,:type=>String
  field :code,:type=>String
  field :url,:type=>String
  field :media_id,:type=>String
  field :is_forever,:type=>Boolean
  mount_uploader :url,ImageAvatarUploader
end
