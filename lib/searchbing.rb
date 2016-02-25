require 'json'
require 'open-uri'
require 'net/http'

# The Bing Class provides the ability to connect to the bing search api hosted on the windows azure marketplace.
# Before proceeding you will need an account key, which can be obtained by registering an accout at http://windows.microsoft.com/en-US/windows-live/sign-in-what-is-microsoft-account
class Bing
	# Create a new object of the bing class
	#   >> bing_image = Bing.new('your_account_key_goes_here', 10, 'Image', {:Adult => 'Strict'}) 
	#   => #<Bing:0x9d9b9f4 @account_key="your_account_key", @num_results=10, @type="Image", @params={:Adult => 'Strict'}>
	# Arguments:
	#   account_key: (String)
	#   num_results: (Integer)
	#   type: 	   (String)
	#   params: 	   (Hash)

	def initialize(account_key, num_results, type, market, params = {})

		@account_key = account_key
		@num_results = num_results
		@type = type
		@params = params
		@market = market


	end

	attr_accessor :account_key, :num_results, :type, :params, :market

	# Search for a term, the result is an array of hashes with the result data
	#   >> bing_image.search("puffin", 25)
	#   => [{"__metadata"=>{"uri"=>"https://api.datamarket.azure.com/Data.ashx/Bing/Search/Image?Query='puffin'&$skip=25&$top=1", "type"=>"Image
	# Arguments:
	#   search_term: (String)
	#   offset: (Integer)

	def search(search_term, offset = 0)

		user = ''
		sources_portion = URI.encode_www_form_component('\'' + @type + '\'')
		query_string = '$format=json&Query='
		query_portion = URI.encode_www_form_component('\'' + search_term + '\'')
		params = "&$top=#{@num_results}&$skip=#{offset}&Market='#{@market}'"
		@params.each do |k,v|
			params << "&#{k.to_s}=\'#{v.to_s}\'"
		end
		if type=='WebOnly'
		  web_search_url = "https://api.datamarket.azure.com/Bing/SearchWeb/v1/Web?"
		  full_address = web_search_url + query_string + query_portion + params
		else
		  web_search_url = "https://api.datamarket.azure.com/Bing/Search/v1/Composite?Sources="
		  full_address = web_search_url + sources_portion + '&' + query_string + query_portion + params
		end

# byebug

		uri = URI(full_address)
		req = Net::HTTP::Get.new(uri.request_uri)
		req.basic_auth user, account_key

		res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https'){|http|
			http.request(req)
		}

		begin
			body = JSON.parse(res.body, :symbolize_names => true)
			result_set = body[:d][:results]		
		rescue
			result_set = {}
		end

	end	
end
