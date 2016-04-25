Rails.application.routes.draw do
  root 'home#index'

  get 'search' => 'home#search'
  get 'privacity' => 'home#privacity'
  get 'terms' => 'home#terms'

end
