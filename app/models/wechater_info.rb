class WechaterInfo
  include Mongoid::Document
  include Mongoid::Timestamps
	belongs_to :wechater_code
	
	field :nick_name,:type=>String
	field :sex,:type=>Boolean
	field :province,:type=>String
	field :city,:type=>String
	field :country,:type=>String
	field :head_image,:type=>String
	field :privilege,:type=>Array
	field :unionid,:type=>String
end
