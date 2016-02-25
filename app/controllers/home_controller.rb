class HomeController < ApplicationController


  def index
    
  end

  def search
    if params[:keyword_text].to_s!='' && params[:country].to_s!='' && params[:category]!=''

      country = ISO3166::Country.new(params[:country])

      if country.languages[0].nil?
        language_country = "en-#{params[:country]}"
      else
        language_country = "#{country.languages[0]}-#{params[:country]}"
      end
      
      render json: KeywordSearch::get_keyword_ideas(params[:keyword_text], language_country, params[:category])
    else
      render json: {}
    end
  end

end
