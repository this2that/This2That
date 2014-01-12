class MarkdownToHTML < ConversionJob
	def action
		begin
			destination_file.write(Kramdown::Document.new(source_file.contents).to_html)
			completed()
		rescue Exception => e
			failed()
		end
	end
end
