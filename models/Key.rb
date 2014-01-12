class Key
	attribute_accessor :generate_key

	## 
	# Keys
	#
	key :access_id, String
	key :secret_key, String

	##
	# Associations
	#
	belongs_to :account

	##
	# Callbacks
	#
	before_create :generate_keys, :if => :generate_key_required?

	def generate_key_required?
		return true if @generate_key
		return true if self[:access_id].blank?
		return true unless self[:access_id]
	end

	def generate_keys
		length = 24
		self[:access_id]  = (36**(length-1) + rand(36**length - 36**(length-1))).to_s(36)
		self[:secret_key] = ApiAuth.generate_secret_key
	end
end
