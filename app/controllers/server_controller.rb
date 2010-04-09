class ServerController < ApplicationController
  
  # CSRF-protection must be skipped, because incoming
  # OpenID requests lack an authenticity token
  skip_before_filter :verify_authenticity_token
  # Error handling
  rescue_from OpenID::Server::ProtocolError, :with => :render_openid_error
  # Actions other than index require a logged in user
  before_filter :login_required, :except => [:index, :cancel, :seatbelt_config, :seatbelt_login_state]
  before_filter :ensure_valid_checkid_request, :except => [:index, :cancel, :seatbelt_config, :seatbelt_login_state]
  after_filter :clear_checkid_request, :only => [:cancel, :complete]
  # These methods are used to display information about the request to the user
  helper_method :sreg_request, :ax_fetch_request, :ax_store_request
  
  # This is the server endpoint which handles all incoming OpenID requests.
  # Associate and CheckAuth requests are answered directly - functionality
  # therefor is provided by the ruby-openid gem. Handling of CheckId requests
  # dependents on the users login state (see handle_checkid_request).
  # Yadis requests return information about this endpoint.
  def index
    clear_checkid_request
    respond_to do |format|
      format.html do
        if openid_request.is_a?(OpenID::Server::CheckIDRequest)
          handle_checkid_request
        elsif openid_request
          handle_non_checkid_request
        else
          render :text => t(:this_is_openid_not_a_human_ressource)
        end
      end
      format.xrds
    end
  end
  
  # This action decides how to process the current request and serves as
  # dispatcher and re-entry in case the request could not be processed 
  # directly (for instance if the user had to log in first).
  # When the user has already trusted the relying party, the request will
  # be answered based on the users release policy. If the request is immediate
  # (relying party wants no user interaction, used e.g. for ajax requests)
  # the request can only be answered if no further information (like simple 
  # registration data) is requested. Otherwise the user will be redirected
  # to the decision page.
  def proceed
    identity = identifier(current_account)
    if @site = current_account.sites.find_by_url(checkid_request.trust_root)
      resp = checkid_request.answer(true, nil, identity)
      resp = add_sreg(resp, @site.sreg_properties) if sreg_request
      resp = add_ax(resp, @site.ax_properties) if ax_fetch_request
      resp = add_pape(resp, auth_policies, auth_level, auth_time)
      render_response(resp)
    elsif checkid_request.immediate && (sreg_request || ax_store_request || ax_fetch_request)
      render_response(checkid_request.answer(false))
    elsif checkid_request.immediate
      render_response(checkid_request.answer(true, nil, identity))
    else
      redirect_to decide_path
    end
  end
  
  # Displays the decision page on that the user can confirm the request and
  # choose which data should be transfered to the relying party.
  def decide
    @site = current_account.sites.find_or_initialize_by_url(checkid_request.trust_root)
    @site.persona = current_account.personas.find(params[:persona_id] || :first) if sreg_request || ax_store_request || ax_fetch_request
  end
  
  # This action is called by submitting the decision form, the information entered by
  # the user is used to answer the request. If the user decides to always trust the
  # relying party, a new site according to the release policies the will be created.
  def complete
    if params[:cancel]
      cancel
    else  
      resp = checkid_request.answer(true, nil, identifier(current_account))
      if params[:always]
        @site = current_account.sites.find_or_create_by_persona_id_and_url(params[:site][:persona_id], params[:site][:url])
        @site.update_attributes(params[:site])
      elsif sreg_request || ax_fetch_request
        @site = current_account.sites.find_or_initialize_by_persona_id_and_url(params[:site][:persona_id], params[:site][:url])
        @site.attributes = params[:site]
      elsif ax_store_request
        @site = current_account.sites.find_or_initialize_by_persona_id_and_url(params[:site][:persona_id], params[:site][:url])
        not_supported, not_accepted, accepted = [], [], []
        ax_store_request.data.each do |type_uri, values|
          if property = Persona.attribute_name_for_type_uri(type_uri)
            store_attribute = params[:site][:ax_store][property.to_sym]
            if store_attribute && !store_attribute[:value].blank?
              @site.persona.update_attribute(property, values.first)
              accepted << type_uri
            else
              not_accepted << type_uri
            end
          else
            not_supported << type_uri
          end
        end
        ax_store_response = (accepted.count > 0) ? OpenID::AX::StoreResponse.new : OpenID::AX::StoreResponse.new(false, "None of the attributes were accepted.")
        resp.add_extension(ax_store_response)
      end
      resp = add_pape(resp, auth_policies, auth_level, auth_time)
      resp = add_sreg(resp, @site.sreg_properties) if sreg_request && @site.sreg_properties
      resp = add_ax(resp, @site.ax_properties) if ax_fetch_request && @site.ax_properties
      render_response(resp)
    end
  end
  
  # Cancels the current OpenID request
  def cancel
    redirect_to checkid_request.cancel_url
  end
  
  protected
  
  # Decides how to process an incoming checkid request. If the user is
  # already logged in he will be forwarded to the proceed action. If
  # the user is not logged in and the request is immediate, the request
  # cannot be answered successfully. In case the user is not logged in,
  # the request will be stored and the user is asked to log in.
  def handle_checkid_request
    if allow_verification?
      save_checkid_request
      redirect_to proceed_path
    elsif openid_request.immediate
      render_response(openid_request.answer(false))
    else
      request = save_checkid_request
      session[:return_to] = proceed_path
      redirect_to( request.from_trusted_domain? ? login_path : safe_login_path )
    end
  end
  
  # Stores the current OpenID request.
  # Returns the OpenIdRequest
  def save_checkid_request
    clear_checkid_request
    request = OpenIdRequest.create(:parameters => openid_params)
    session[:request_token] = request.token

    request
  end
  
  # Deletes the old request when a new one comes in.
  def clear_checkid_request
    unless session[:request_token].blank?
      OpenIdRequest.destroy_all :token => session[:request_token]
      session[:request_token] = nil
    end
  end
  
  # Use this as before_filter for every CheckID request based action.
  # Loads the current openid request and cancels if none can be found.
  # The user has to log in, if he has not verified his ownership of
  # the identifier, yet.
  def ensure_valid_checkid_request
    self.openid_request = checkid_request
    if !openid_request.is_a?(OpenID::Server::CheckIDRequest)
      flash[:error] = t(:identity_verification_request_invalid)
      redirect_to home_path
    elsif !allow_verification?
      flash[:notice] = logged_in? && !pape_requirements_met?(auth_time) ?
        t(:service_provider_requires_reauthentication_last_login_too_long_ago) :
        t(:login_to_verify_identity)
      session[:return_to] = proceed_path
      redirect_to login_path
    end
  end
  
  # The user must be logged in, he must be the owner of the claimed identifier
  # and the PAPE requirements must be met if applicable.
  def allow_verification?
    logged_in? && correct_identifier? && pape_requirements_met?(auth_time)
  end
  
  # Is the user allowed to verify the claimed identifier? The user
  # must be logged in, so that we know his identifier or the identifier
  # has to be selected by the server (id_select).
  def correct_identifier?
    (openid_request.identity == identifier(current_account) || openid_request.id_select)
  end
  
  # Clears the stored request and answers
  def render_response(resp)
    clear_checkid_request
    render_openid_response(resp)
  end
  
  # Transforms the parameters from the form to valid AX response values
  def transform_ax_data(parameters)
    data = {}
    parameters.each_pair do |key, details|
      if details['value']
        data["type.#{key}"] = details['type']
        data["value.#{key}"] = details['value']
      end
    end
    data
  end
  
  # Renders the exception message as text output
  def render_openid_error(exception)
    error = case exception
    when OpenID::Server::MalformedTrustRoot: "Malformed trust root '#{exception.to_s}'"
    else exception.to_s
    end
    render :text => "Invalid OpenID request: #{error}", :status => 500
  end
  
  private
  
  # The NIST Assurance Level, see:
  # http://openid.net/specs/openid-provider-authentication-policy-extension-1_0-01.html#anchor12
  def auth_level
    if APP_CONFIG['use_ssl']
      current_account.last_authenticated_with_yubikey? ? 3 : 2
    else
      0
    end
  end
  
  def auth_time
    current_account.last_authenticated_at
  end
  
  def auth_policies
    current_account.last_authenticated_with_yubikey? ? 
      [OpenID::PAPE::AUTH_MULTI_FACTOR, OpenID::PAPE::AUTH_PHISHING_RESISTANT] :
      []
  end
  
end
