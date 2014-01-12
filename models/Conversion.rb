class Conversion
	include MongoMapper::Document
	@@price_per_conversion == 6 # In cents

	##
	# Keys
	#
	key :status, Symbol, default: :not_started # failed, completed, not_started, or running

	belongs_to :key
	belongs_to :account
	has_one :source_file,      :class => 'File'
	has_one :destination_file, :class => 'File'

	def completed
		self[:status] = :completed
		redis.publish self.key.channel, self.to_event.to_json
	end

	def failed
		self[:status] = :failed
		redis.publish self.key.channel, self.to_event.to_json
	end

	def completed!
		self.completed()
		self.save()
	end

	def failed!
		self.failed()
		self.save()
	end

	def to_event
		{event_type: 'markdowntohtml', status: self.status, id: self.id}
	end
end
