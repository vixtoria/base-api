class Api::V1::UsersController <  Api::V1::ApplicationController
  protect_from_forgery :except => [:delete]

  def delete
    render :json => {:success => false, :message => "Ha ocurrido un error al eliminar el usuario"} and return unless params.has_key?(:user)
    user = User.find(params[:user])
    render :json => {:success => false, :message => "Ha ocurrido un error al eliminar el usuario"} and return unless user.present? && user.discard!
    render :json => {:success => true, :message => "Usuario eliminado con éxito"}
  end

  def update_password
    begin
      @user = User.find(current_user.id)
      if @user.update_with_password(user_params)
        render :json => {:status =>200, :data => @user}
      else
        Rails.logger.info 'user#update :' + user_params.to_json + 'message :' + @user.errors.full_messages.to_s
        render :json => {:status => :unprocessable_entity, :data => @user.errors.full_messages}
      end
    rescue Exception => e
      render :status => 500, :json =>{:msg => e.message} and return
    end
  end

  def valid_password
    render :json => {success: false, message: "Usuario no encontrado."} and return if @user.nil?
    @user = User.find_for_authentication(email: params[:email])
    if @user.valid_password?(params[:password])
      render :json => {success: true}
    else
      render :json => {success: false}
    end
  end

  private
  def user_params
    params.permit(:email, :password, :password_confirmation, :uid, :provider)
  end
end
