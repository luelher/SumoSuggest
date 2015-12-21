class HomeController < ApplicationController


  def index
    
  end

  def search
    if true # permit_params.permitted?
      
      seed_file = Rails.root.join('db', 'seeds', 'table_example.yml')
      data = YAML::load_file(seed_file)

      render json: data
      # render KeywordSearch(permit_params[:keyword_text], permit_params[:country], permit_params[:category])
    else
      render status: :bad_request
    end
  end

private
  def permit_params
    params.require(:category, :country, :search_text)
  end

end
