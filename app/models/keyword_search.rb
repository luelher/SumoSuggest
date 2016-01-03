require 'adwords_api'
require File.join(Rails.root, 'lib/searchbing.rb')

class KeywordSearch

  API_VERSION = :v201509
  PAGE_SIZE = 40

  def self.get_keyword_ideas(keyword_text, country, category)
    
    # Bing API
    config_bing = YAML::load_file(File.join(Rails.root, 'config', 'bing.yml'))
    bing_obj = Bing.new(config_bing['config']['account'], PAGE_SIZE, 'RelatedSearch', country)
    
    result_all = []
    result_a = []
    result_b = []
    case category
      when 'search'
        result_a = bing_obj.search(keyword_text).last[:RelatedSearch]
      when 'video'
        result_a = bing_obj.search("YouTube #{keyword_text}").last[:RelatedSearch]
      when 'course'
        result_a = bing_obj.search("Udemy #{keyword_text}").last[:RelatedSearch]
      when 'store'
        result_a = bing_obj.search("Android #{keyword_text}").last[:RelatedSearch]
        result_b = bing_obj.search("iOS #{keyword_text}").last[:RelatedSearch]
      when 'qa'
        result_a = bing_obj.search("Quora #{keyword_text}").last[:RelatedSearch]
      else
        result_a = bing_obj.search(keyword_text).last[:RelatedSearch]
    end
    
    result_a.each do |r|
      result_all << {:keywords => r[:Title], :volumen => 0, :cpc => "0.0 $", :competitions => 20, :id => r[:ID]}
    end

    result_b.each do |r|
      result_all << {:keywords => r[:Title], :volumen => 0, :cpc => "0.0 $", :competitions => 20, :id => r[:ID]}
    end

    
    return result_all

    # config_filename = File.join(Rails.root, 'config', 'adwords_api.yml')
    # adwords = AdwordsApi::Api.new(config_filename)

    # # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
    # # the configuration file or provide your own logger:
    # # adwords.logger = Logger.new('adwords_xml.log')

    # targeting_idea_srv = adwords.service(:TargetingIdeaService, API_VERSION)

    # # Construct selector object.
    # selector = {
    #   :idea_type => 'KEYWORD',
    #   :request_type => 'IDEAS',
    #   :requested_attribute_types =>
    #       ['KEYWORD_TEXT', 'SEARCH_VOLUME', 'CATEGORY_PRODUCTS_AND_SERVICES'],
    #   :search_parameters => [
    #     {
    #       # The 'xsi_type' field allows you to specify the xsi:type of the object
    #       # being created. It's only necessary when you must provide an explicit
    #       # type that the client library can't infer.
    #       :xsi_type => 'RelatedToQuerySearchParameter',
    #       :queries => [keyword_text]
    #     },
    #     {
    #       # Language setting (optional).
    #       # The ID can be found in the documentation:
    #       #  https://developers.google.com/adwords/api/docs/appendix/languagecodes
    #       # Only one LanguageSearchParameter is allowed per request.
    #       :xsi_type => 'LanguageSearchParameter',
    #       :languages => [{:id => 1000}]
    #     }
    #   ],
    #   :paging => {
    #     :start_index => 0,
    #     :number_results => PAGE_SIZE
    #   }
    # }

    # # Define initial values.
    # offset = 0
    # results = []

    # begin
    #   # Perform request.
    #   page = targeting_idea_srv.get(selector)
    #   results += page[:entries] if page and page[:entries]

    #   # Prepare next page request.
    #   offset += PAGE_SIZE
    #   selector[:paging][:start_index] = offset

    # # Authorization error.
    # rescue AdsCommon::Errors::OAuth2VerificationRequired => e
    #   puts "Authorization credentials are not valid. Edit adwords_api.yml for " +
    #       "OAuth2 client ID and secret and run misc/setup_oauth2.rb example " +
    #       "to retrieve and store OAuth2 tokens."
    #   puts "See this wiki page for more details:\n\n  " +
    #       'https://github.com/googleads/google-api-ads-ruby/wiki/OAuth2'

    # # HTTP errors.
    # rescue AdsCommon::Errors::HttpError => e
    #   puts "HTTP Error: %s" % e

    # # API errors.
    # rescue AdwordsApi::Errors::ApiException => e
    #   puts "Message: %s" % e.message
    #   puts 'Errors:'
    #   e.errors.each_with_index do |error, index|
    #     puts "\tError [%d]:" % (index + 1)
    #     error.each do |field, value|
    #       puts "\t\t%s: %s" % [field, value]
    #     end
    #   end
    
    # end while offset < page[:total_num_entries]

    # # Display results.
    # results.each do |result|
    #   data = result[:data]
    #   keyword = data['KEYWORD_TEXT'][:value]
    #   puts "Found keyword with text '%s'" % keyword
    #   products_and_services = data['CATEGORY_PRODUCTS_AND_SERVICES'][:value]
    #   if products_and_services
    #     puts "\tWith Products and Services categories: [%s]" %
    #         products_and_services.join(', ')
    #   end
    #   average_monthly_searches = data['SEARCH_VOLUME'][:value]
    #   if average_monthly_searches
    #     puts "\tand average monthly search volume: %d" % average_monthly_searches
    #   end
    # end
    # puts "Total keywords related to '%s': %d." % [keyword_text, results.length]
  end


end