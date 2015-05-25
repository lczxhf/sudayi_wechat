class GzhInfo
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields
	belongs_to :auth_code

	field :nick_name,:type=>String
	field :head_image,:type=>String
	field :service_type,:type=>String
	field :verify_type,:type=>String
	field :alias,:type=>String
	field :user_name,:type=>String
	field :qrcode_url,:type=>String
	field :location_report,:type=>String
	field :voice_recognize,:type=>String
	field :customer_service,:type=>String
end
