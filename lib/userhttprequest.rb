require 'curb'
require 'cgi'

class UserHttpReqeust

	@@default_configuration = nil

	class << self
		def default_configuration
			@@default_configuration
		end

		def default_configuration=(config)
			@@default_configuration = config
		end
	end


	class Request5xxException  < Exception
		attr_reader :response
		def initialize(response)
			super
			@response = response
		end
	end

	attr_accessor :method
	attr_accessor :configuration
	attr_accessor :path
	attr_reader :headers
	attr_accessor :req_params
	attr_accessor :req_body
	attr_accessor :curl_instance

	def initialize(verb, path, params=nil, hdrs=nil, body=nil, configuration=nil)
		@method = verb
		@path = path
		@req_params = params || {}
		@headers = hdrs || {}
		req_id = Thread.current[:request_hash][:id] rescue nil
		req_id = Thread.current[:common_log_info][:req_id] if !req_id and Thread.current[:common_log_info]
		@headers['X-Request-Id'] = req_id unless req_id.nil?
		@req_body = body || ""
		@configuration = configuration || UserHttpReqeust.default_configuration
		@curl_instance = Curl::Easy.new
	end

	def perform_sleep(sec)
		sleep(sec)
	end

	# This prepares the curb request and then performs it. Users of this API will not directly call this method
	def perform_request
		# If this is set within the begin block, it will reset 'retries' with every retry
		sleep_sec = 1
		begin
			# Can we check if configuration is a valid object of class OzRequestConfiguration?
			url = "localhost:3000/v1.0"+path
			curl_instance.url = url
			curl_instance.headers = {}.merge!(headers)
			#configuration.config_request(self)

			case method
				when :get
					curl_instance.http_get
				when :head
					curl_instance.http_head
				when :put
					curl_instance.http_put(req_body)
				when :post
					curl_instance.http_post(req_body)
				when :delete
					curl_instance.http_delete
				else
					raise NotImplementedError.new("Unsupported http method #{method}")
			end

			response = UserHTTPResponse.new(curl_instance)
			#configuration.config_response(response)

			#raise OzRequest::Request5xxException.new(response) if response.code.to_s =~ /^5[0-9]{2}/

			response
		rescue NotImplementedError => e
			raise e
		rescue Curl::Err::TimeoutError, Curl::Err::GotNothingError, Curl::Err::HostResolutionError, Request5xxException => e
			if retries > 0
				perform_sleep(sleep_sec)
				retries -= 1
				sleep_sec *= 2
				retry
			end

			# If we have a real 500, return it to the caller instead of raising an exception
			return e.response if e.class == OzRequest::Request5xxException
			raise e
		rescue Exception => e
			raise configuration.api_error_class.new({exception: e.inspect})
		end
	end

	private
	def build_path_with_query
		res_url = "#{configuration.base_url}#{path}"
		query = OzRequest.url_encode_params(req_params,"&",true)
		separator = res_url.index('?') ? '&' : '?'
		res_url += separator + query if query.length > 0
		res_url
	end

	class << self
		def get(path, params=nil, hdrs=nil, config=nil)
			request = UserHttpReqeust.new(:get, path, params, hdrs, nil, config)
			request.perform_request
		end
		def put_json(path, params=nil, hdrs=nil, body=nil, config=nil)
			hdrs = fix_content_type_hdr_for_json(hdrs)
			body ||= {}
			request = UserHttpReqeust.new(:put, path, params, hdrs, body.to_json, config)
			request.perform_request
		end
		def post_json(path, params=nil, hdrs=nil, body=nil, config=nil)
			hdrs = fix_content_type_hdr_for_json(hdrs)
			body ||= {}
			request = UserHttpReqeust.new(:post, path, params, hdrs, body.to_json, config)
			request.perform_request
		end
		private
		def fix_content_type_hdr_for_json(hdrs)
			fix_content_type_hdr(hdrs, 'application/json')
		end
		def fix_content_type_hdr(hdrs, content_type)
			hdrs ||= {}
			hdrs.merge('Content-Type' => content_type)
		end
	end
end