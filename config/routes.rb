Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      sessions: 'api/v1/devise_token_auth/sessions',
      registrations: 'api/v1/devise_token_auth/registrations',
      confirmations: 'api/v1/devise_token_auth/confirmations'
  }

  namespace :api do
    namespace :v1 do

    end
  end
end
