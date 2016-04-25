class HomeController < ApplicationController


  def index
    
  end

  def privacity
  end

  def terms
  end

  def search
    if params[:keyword_text].to_s!='' && params[:country].to_s!='' && params[:category]!=''

      country = ISO3166::Country.new(params[:country])

      if country.languages[0].nil?
        language_country = "en-#{params[:country]}"
      else
        language_country = "#{country.languages[0]}-#{params[:country]}"
      end

      letter = params[:pages][params[:start]].to_i

      data, next_letter = KeywordSearch::get_keyword_ideas(params[:keyword_text], language_country, params[:category], letter, 20)
      
      render json: {start: params[:start], recordsTotal: 100, recordsFiltered: 100, next_letter: next_letter, data: data} 
    else
      render json: {start: params[:start], recordsTotal: 0, recordsFiltered: 0, next_letter: 0, data: []}
    end
  end

end
