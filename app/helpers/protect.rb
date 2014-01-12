App.helpers do
	def self.protect(protected)
		condition do
			@key = Key.find_by_access_id(ApiAuth.access_id(request))
	    halt 403, "We could not verify your request as authentic" unless @key 

	    unless ApiAuth.authentic?(request, @key.secret_key)
	    	halt 403, "We could not verify your request as authentic"
	    end
		end
	end
end
