module UserManagementWebapp
  class App < Padrino::Application
	  use ActiveRecord::ConnectionAdapters::ConnectionManagement
	  register Padrino::Rendering
	  register Padrino::Mailer
	  register Padrino::Helpers
	  enable :show_exceptions, :dump_errors, :raise_errors, :flash, :protection, :x_cascade

	  enable :sessions

	  register Padrino::Sprockets
	  sprockets :minify => (Padrino.env == :production)

	  configure :development do
		  use BetterErrors::Middleware
		  BetterErrors.application_root = PADRINO_ROOT
		  #set :protect_from_csrf, except: %r{/__better_errors/\d+/\w+\z}
		  set :protect_from_csrf, false

		  set :delivery_method, :test
	  end

	  protected

	  error do
		  view_obj = {}

		  if $!.respond_to?(:build_view_object)
			  view_obj = $!.build_view_object
			  http_status = $!.status_code
		  end

		  content_type :json
		  error http_status, "while (1) {}\n" + view_obj.to_json
	  end

	  ##
	  # Caching support
	  #
	  # register Padrino::Cache
	  # enable :caching
	  #
	  # You can customize caching store engines:
	  #
	  #   set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
	  #   set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
	  #   set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
	  #   set :cache, Padrino::Cache::Store::Memory.new(50)
	  #   set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
	  #

	  ##
	  # Application configuration options
	  #
	  # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
	  # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
	  # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
	  # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
	  # set :public_folder, "foo/bar" # Location for static assets (default root/public)
	  # set :reload, false            # Reload application files (default in development)
	  # set :default_builder, "foo"   # Set a custom form builder (default 'StandardFormBuilder')
	  # set :locale_path, "bar"       # Set path for I18n translations (default your_app/locales)
	  # disable :sessions             # Disabled sessions by default (enable if needed)
	  # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
	  # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
	  #

	  ##
	  # You can configure for a specified environment like:
	  #
	  #   configure :development do
	  #     set :foo, :bar
	  #     disable :asset_stamp # no asset timestamping for dev
	  #   end
	  #

	  ##
	  # You can manage errors like:
	  #
	  #   error 404 do
	  #     render 'errors/404'
	  #   end
	  #
	  #   error 505 do
	  #     render 'errors/505'
	  #   end
	  #
  end
end
