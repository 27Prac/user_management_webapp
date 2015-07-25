require 'json'
require 'curb'

class UserHTTPResponse

	attr_accessor :body
	attr_accessor :code
	attr_accessor :headers
	attr_accessor :content_type
	attr_accessor :json_body
	attr_accessor :original_request_url

	def initialize(curl_instance)
		@body = curl_instance.body_str
		@code = curl_instance.response_code
		@headers = UserHTTPResponse.parse_headers(curl_instance.header_str)
		@content_type = curl_instance.content_type || ""
		@original_request_url = curl_instance.url
		if @content_type.match(/^application\/json/) && !@body.empty? && !@body.nil?
			begin
				@json_body = JSON.parse(@body.gsub(/^while\s*\(1\)\s*\{\s*\}\s*/, ''))
			rescue Exception => e
				this_exception = e.exception(e.to_s + ". The response body was: #{@body}")
				raise this_exception
			end
		else
			@json_body = {}
		end
	end

	private
	def self.parse_headers(header_str)
		headers = {}
		header_str.each_line("\r\n") do |line|
			fields = line.gsub(/\s*$/, '').split(/:\s*/, 2)
			headers[fields[0]] = fields[1] unless fields[0].nil? || fields[1].nil?
		end
		headers
	end
end