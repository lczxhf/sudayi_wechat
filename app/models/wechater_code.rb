class WechaterCode
  include Mongoid::Document
  include Mongoid::Timestamps
	has_one :wechater_info,:dependent=>:delete
	belongs_to :auth_code
	
	field :auth_code,:type=>String
	field :token,:type=>String
	field :refresh_token,:type=>String
	field :openid,:type=>String
	field :scope,:type=>Array,:default=>[]
end
