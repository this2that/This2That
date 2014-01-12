FORMATS = ['markdown2html']
App.helpers do
	def format_exists
		return FORMATS.include?("#{params[:this]}2#{params[:that]}")
	end

	def format_map
		return "#{params[:this]}2#{params[:that]}"
	end
end
