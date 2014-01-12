class ConversionJob < CommandWithErrors
	include Resque::Plugins::Status
  attribute :conversion_id, ::BSON::ObjectId

  def self.create(*args)
    options  = args.extract_options!
    uuid     = super(options)

    return uuid
	end

	def conversion
		@conversion ||= Conversion.find_by_id(@conversion_id)
		return @conversion
	end

	def destination_file
		return @conversion.destination_file
	end
	
	def source_file
		return @conversion.source_file
	end

	def completed
		conversion.completed!
	end

	def failed
		conversion.failed!
	end
end
