require 'adwords_api'
require File.join(Rails.root, 'lib/searchbing.rb')
require File.join(Rails.root, 'lib/oauth_util.rb')

class KeywordSearch

  API_VERSION = :v201509
  PAGE_SIZE = 20

  ADDITIONAL_CRITERIAS = ["", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "ñ", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  def self.get_keyword_ideas(keyword_text, country, category, from_index, result_count)

    result_all = []
    count = 0
    while (result_all.size < result_count || count == 10) && from_index < ADDITIONAL_CRITERIAS.size do
      from_letter = KeywordSearch::ADDITIONAL_CRITERIAS[from_index]
      result_all = KeywordSearch.get_keywords_by_criteria((keyword_text+" #{from_letter}").strip, country, category, result_all)  
      from_index+=1
      count+=1
    end

    return sort_results(result_all), from_index
  end

  def self.get_keywords_by_criteria(keyword_text, country, category, another_results)

    result_bing = KeywordSearch.bing(keyword_text, country, category)

    result_boss = KeywordSearch.boss(keyword_text, country, category)    

    result_adwords = KeywordSearch.adwords(keyword_text, country, category)

    result_all = result_adwords + result_bing + result_boss + another_results

    return clean_results(result_all)
  end

  def self.bing(keyword_text, country, category)
    
    result_all = []

    # Bing API
    config_bing = YAML::load_file(File.join(Rails.root, 'config', 'bing.yml'))
    unless config_bing['config'].nil?
        unless config_bing['config']['account'].nil?

            bing_obj = Bing.new(config_bing['config']['account'], PAGE_SIZE, 'RelatedSearch', country)
            
            if true

              result_a = []
              result_b = []
              case category
                when 'search'
                  bing_result = bing_obj.search(keyword_text)
                  if bing_result.length > 0
                    result_a = bing_result.last[:RelatedSearch]
                  end
                when 'video'
                  bing_result = bing_obj.search("YouTube #{keyword_text}")
                  if bing_result.length > 0
                    result_a = bing_result.last[:RelatedSearch]
                    result_a.each do |r|
                      r[:Title] = r[:Title].gsub("YouTube", "").strip
                    end
                  end
                when 'course'
                  bing_result = bing_obj.search("Udemy #{keyword_text}")
                  if bing_result.length > 0
                    result_a = bing_result.last[:RelatedSearch]
                    result_a.each do |r|
                      r[:Title] = r[:Title].gsub("Udemy", "").strip
                    end
                  end
                when 'store'
                  bing_result = bing_obj.search("Android #{keyword_text}")
                  if bing_result.length > 0
                    result_a = bing_result.last[:RelatedSearch]
                    result_a.each do |r|
                      r[:Title] = r[:Title].gsub("Android", "").strip
                    end
                  end

                  bing_result = bing_obj.search("iOS #{keyword_text}")
                  if bing_result.length > 0
                    result_b = bing_result.last[:RelatedSearch]
                    result_b.each do |r|
                      r[:Title] = r[:Title].gsub("iOS", "").strip
                    end
                  end
                when 'qa'
                  bing_result = bing_obj.search("Quora #{keyword_text}")
                  if bing_result.length > 0
                    result_a = bing_result.last[:RelatedSearch]
                    result_a.each do |r|
                      r[:Title] = r[:Title].gsub("Quora", "").strip
                    end
                  end
                else
                  result_a = bing_obj.search(keyword_text).last[:RelatedSearch]
              end
              
              result_a.each_with_index do |r, index|
                result_all << {:keywords => r[:Title], :volumen => 0, :cpc => "0.0", :competitions => 0, :id => index+100, :from => 'bing', :criteria => keyword_text}
              end

              result_b.each_with_index do |r, index|
                result_all << {:keywords => r[:Title], :volumen => 0, :cpc => "0.0", :competitions => 0, :id => index+100, :from => 'bing', :criteria => keyword_text}
              end

            end

        end
    end
    
    return result_all

  end


  def self.adwords(keyword_text, country, category)

    backup_keyword_text = keyword_text
    config_filename = File.join(Rails.root, 'config', 'adwords_api.yml')
    adwords = AdwordsApi::Api.new(config_filename)

    # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
    # the configuration file or provide your own logger:
    # adwords.logger = Logger.new('adwords_xml.log')

    targeting_idea_srv = adwords.service(:TargetingIdeaService, API_VERSION)


    case category
      when 'video'
        keyword_text = "YouTube #{keyword_text}"
      when 'course'
        keyword_text = "Udemy #{keyword_text}"
      when 'store'
        keyword_text = "Android #{keyword_text}"
        keyword_text = "iOS #{keyword_text}"
      when 'qa'
        keyword_text = "Quora #{keyword_text}"
    end

    country_arr = country.split('-')
    if country_arr.length==2
        language = { :id => LANGUAGES[country_arr[0]][0] }    
        location = { :id => COUNTRIES[country_arr[1]][0] }
    else
        language = { :id => 1000 } # English
        location = { :id => 2840 } # EEUU
    end

    # Construct selector object.
    selector = {
      :idea_type => 'KEYWORD',
      :request_type => 'IDEAS',
      :requested_attribute_types =>
          ['KEYWORD_TEXT', 'SEARCH_VOLUME', 'AVERAGE_CPC', 'COMPETITION'],
      :search_parameters => [
        {
          # The 'xsi_type' field allows you to specify the xsi:type of the object
          # being created. It's only necessary when you must provide an explicit
          # type that the client library can't infer.
          :xsi_type => 'RelatedToQuerySearchParameter',
          :queries => [keyword_text]
        },
        {
          # Language setting (optional).
          # The ID can be found in the documentation:
          #  https://developers.google.com/adwords/api/docs/appendix/languagecodes
          # Only one LanguageSearchParameter is allowed per request.
          :xsi_type => 'LanguageSearchParameter',
          :languages => [language]
        },
        {
          :xsi_type => "LocationSearchParameter",
          :locations => [location]
        }        
      ],
      :paging => {
        :start_index => 0,
        :number_results => PAGE_SIZE
      }
    }

    # Define initial values.
    offset = 0
    results = []
    result_all = []

    begin
      # Perform request.
      page = targeting_idea_srv.get(selector)
      results += page[:entries] if page and page[:entries]

    # Authorization error.
    rescue AdsCommon::Errors::OAuth2VerificationRequired => e
      puts "Authorization credentials are not valid. Edit adwords_api.yml for " +
          "OAuth2 client ID and secret and run misc/setup_oauth2.rb example " +
          "to retrieve and store OAuth2 tokens."
      puts "See this wiki page for more details:\n\n  " +
          'https://github.com/googleads/google-api-ads-ruby/wiki/OAuth2'

    # HTTP errors.
    rescue AdsCommon::Errors::HttpError => e
      puts "HTTP Error: %s" % e

    # API errors.
    rescue AdwordsApi::Errors::ApiException => e
      puts "Message: %s" % e.message
      puts 'Errors:'
      e.errors.each_with_index do |error, index|
        puts "\tError [%d]:" % (index + 1)
        error.each do |field, value|
          puts "\t\t%s: %s" % [field, value]
        end
      end

    rescue Exception => e
      puts "Message: %s" % e.message      
    end

    # Display results.
    results.each_with_index do |result, index|

      data = result[:data]

      keyword = data['KEYWORD_TEXT'][:value]
      volumen = data['SEARCH_VOLUME'][:value]
      cpc = data['AVERAGE_CPC'][:value][:micro_amount]
      competition = data['COMPETITION'][:value]

      if cpc
        cpc = (cpc / 1000000)
      end
      if competition
        competition = "%0.2f" % competition
      end

      result_all << {:keywords => keyword, :volumen => volumen, :cpc => cpc, :competitions => competition, :id => index, :from => 'adwords', :criteria => backup_keyword_text}

    end
    
    return result_all

  end

  def self.boss(keyword_text, country, category)

    result_all = []

    # Bing API
    config_boss = YAML::load_file(File.join(Rails.root, 'config', 'boss.yml'))
    unless config_boss['config'].nil?

        unless config_boss['config']['key'].nil? or config_boss['config']['secret'].nil?


            YBoss::Config.instance.oauth_key = config_boss['config']['key']
            YBoss::Config.instance.oauth_secret = config_boss['config']['secret']

            case category
              when 'video'
                sites_a = "youtube.com"
              when 'course'
                sites_a = "udemy.com"
              when 'store'
                sites_a = "play.google.com"
                sites_b = "itunes.apple.com"
              when 'qa'
                sites_a = "quora.com"
            end

            begin
              response = YBoss.related('q' => keyword_text, 'format' => 'json', 'market' => country.downcase, 'sites' => sites_a, 'start' => '0')

              response.items.each_with_index do |value, index|
                result_all << {:keywords => value.suggestion, :volumen => 0, :cpc => "0.0", :competitions => 0, :id => index+500, :from => 'boss', :criteria => keyword_text}
                #index += 1
              end
            rescue YBoss::FetchError => e
            end
            return result_all

        end
    end
  end


  def self.clean_results(results)

    cleans = []

    results.each do |r|
        search_result = cleans.select { |h| h[:keywords] == r[:keywords] }.count
        if search_result == 0
            cleans << r
        end
    end

    return cleans
  end

  def self.sort_results(results)
    return results.sort_by { |hsh| hsh[:criteria] }
  end

end