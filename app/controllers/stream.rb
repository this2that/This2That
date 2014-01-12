conns = Hash.new {|h, k| h[k] = [] }
 
Thread.abort_on_exception = true

Thread.new do
	redis = Redis.connect
	
	redis.subscribe('rubyonrails', 'ruby-lang') do |on|
	  on.message do |channel, msg|
	    data = JSON.parse(msg)

			conns[channel].each do |out|
				out << "data: #{message}\n\n"
			end
	  end
	end
end

App.controllers :stream do
	get :subscribe, map: '/subscribe/:channel' do
		content_type 'text/event-stream'
		 
		stream(:keep_open) do |out|
			channel = params[:channel]
			 
			conns[channel] << out
			 
			out.callback do
				conns[channel].delete(out)
			end
		end
	end
end
