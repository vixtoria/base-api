class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  protect_from_forgery unless: -> { request.format.json? }
  protect_from_forgery with: :exception, if: :verify_api
  before_action :configure_permitted_parameters, if: :devise_controller?

  def verify_api
    params[:controller].split('/')[0] != 'devise_token_auth'
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:name, :email, :password, :password_confirmation, :uid]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end