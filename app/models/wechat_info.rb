class WechatInfo
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields
	field :appid,:type=>String
	field :appsecret,:type=>String
	field :encodingkey,:type=>String
	field :token,:type=>String
	field :pre_auth_code,:type=>String

	field :access_token,:type=>String
	field :ticket,:type=>String
end
