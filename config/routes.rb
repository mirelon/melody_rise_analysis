Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  ActiveAdmin.routes(self)
  post '/pacient' => 'pacient#create'
  post '/nahravka' => 'nahravka#create'
  get '/nahravka/:id' => 'nahravka#show'
  post '/home/upload' => 'home#upload'
  root to: 'home#index'
end
