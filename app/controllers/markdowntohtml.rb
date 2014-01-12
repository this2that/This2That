App.controllers :api do	
	before do
		@key = Key.find_by_access_id(ApiAuth.access_id(request))
		respond :not_found, "Access id not found" unless @key
	end

	post :this2that, map: "/:this/to/:that" do
		respond :not_found unless format_exists

		begin
			@conversion = "#{format_map}".constantize.create(account: @key.account, key: @key, source_file: request.body.read)
		rescue Exception => e
			respond :failed, "Failed to create a conversion job for this. Please try again"
		end

		begin
	    rest_request = RestClient::Request.new(
	    	url:    "https://#{format_map}.#{env['DOMAIN']}", 
	    	params: {conversion_id: @conversion.id}, 
	    	method: :post)

	    signed_request = ApiAuth.sign!(rest_request, env['APPS_ACCESS_ID'], env['APPS_SECRET_KEY'])
	    signed_request.execute()

	    respond :processing, "Should be done in a moment. Check your dash for status."
		rescue Exception => e
			respond :failed, "Something went wrong"
		end		
	end
end
