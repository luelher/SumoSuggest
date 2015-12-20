class HomeController < ApplicationController


  def index
    
  end

  def search
    if permit_params.permitted?
      
    else
      render status: :bad_request
    end
  end

private
  def permit_params
    params.require(:category, :country, :search_text)
  end

end
