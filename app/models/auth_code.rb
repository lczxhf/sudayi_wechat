class AuthCode
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields
	has_one :gzh_info,:dependent=>:delete
	field :code,:type=>String
	field :token,:type=>String
	field :refresh_token,:type=>String
	field :appid,:type=>String
	field :func_info,:type=>Array,:default=>[]
end
