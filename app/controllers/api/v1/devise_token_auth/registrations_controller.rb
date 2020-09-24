class Api::V1::DeviseTokenAuth::RegistrationsController < DeviseTokenAuth::RegistrationsController
  skip_before_action :verify_authenticity_token

  def update
    if @resource
      if @resource.send(resource_update_method, account_update_params)
        yield @resource if block_given?
        if (params.has_key?(:settings))
          params[:settings].each do |id, attrs|
            @resource.settings[id] = attrs
          end
        end
        render_update_success
      else
        render_update_error
      end
    else
      render_update_error_user_not_found
    end
  end

  def destroy
    if @resource
      @resource.discard
      yield @resource if block_given?
      render_destroy_success
    else
      render_destroy_error
    end
  end

  def create
    build_resource

    unless @resource.present?
      raise DeviseTokenAuth::Errors::NoResourceDefinedError,
            "#{self.class.name} #build_resource does not define @resource,"\
              ' execution stopped.'
    end

    # give redirect value from params priority
    @redirect_url = params.fetch(
        :confirm_success_url,
        DeviseTokenAuth.default_confirm_success_url
    )

    # success redirect url is required
    if confirmable_enabled? && !@redirect_url
      return render_create_error_missing_confirm_success_url
    end

    # if whitelist is set, validate redirect_url against whitelist
    return render_create_error_redirect_url_not_allowed if blacklisted_redirect_url?

    # override email confirmation, must be sent manually from ctrl
    resource_class.set_callback('create', :after, :send_on_create_confirmation_instructions)
    resource_class.skip_callback('create', :after, :send_on_create_confirmation_instructions)

    if @resource.respond_to? :skip_confirmation_notification!
      # Fix duplicate e-mails by disabling Devise confirmation e-mail
      @resource.skip_confirmation_notification!
    end

    if @resource.save
      yield @resource if block_given?

      unless @resource.confirmed?
        # user will require email authentication
        @resource.send_confirmation_instructions
      end

      if active_for_authentication?
        # email auth has been bypassed, authenticate user
        @client_id, @token = @resource.create_token
        @resource.save!
        update_auth_header
      end

      render_create_success
    else
      clean_up_passwords @resource
      render_create_error
    end
  end
end

