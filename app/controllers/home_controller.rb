class HomeController < ApplicationController


  def index
    
  end

  def search
    if params[:keyword_text].to_s!='' && params[:country].to_s!='' && params[:category]!=''
      
      # seed_file = Rails.root.join('db', 'seeds', 'table_example.yml')
      # data = YAML::load_file(seed_file)

      # render json: data
      render json: KeywordSearch::get_keyword_ideas(params[:keyword_text], params[:country], params[:category])
    else
      render json: {}
    end
  end

end
