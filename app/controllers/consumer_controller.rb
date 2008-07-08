class ConsumerController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def start
    begin
      oidreq = openid_consumer.begin(params[:openid_identifier])
    rescue OpenID::OpenIDError => e
      flash[:error] = "Discovery failed for #{params[:openid_identifier]}: #{e}"
      redirect_to consumer_path
      return
    end
    if params[:use_sreg]
      sregreq = OpenID::SReg::Request.new
      sregreq.policy_url = 'http://www.policy-url.com'
      sregreq.request_fields(['nickname', 'email'], true) # required
      sregreq.request_fields(['fullname', 'dob'], false) # optional
      oidreq.add_extension(sregreq)
      oidreq.return_to_args['did_sreg'] = 'y'
    end
    if params[:use_ax]
      axreq = OpenID::AX::FetchRequest.new
      requested_attrs = [['http://axschema.org/namePerson/friendly', 'nickname', true],
                         ['http://axschema.org/contact/email', 'email', true],
                         ['http://axschema.org/namePerson', 'fullname'],
                         ['http://axschema.org/contact/web/default', 'website', false, 2],
                         ['http://axschema.org/contact/postalCode/home', 'postcode'],
                         ['http://axschema.org/person/gender', 'gender'],
                         ['http://axschema.org/birthDate', 'birth_date'],
                         ['http://axschema.org/contact/country/home', 'country'],
                         ['http://axschema.org/pref/language', 'language'],
                         ['http://axschema.org/pref/timezone', 'timezone']]
      requested_attrs.each { |a| axreq.add(OpenID::AX::AttrInfo.new(a[0], a[1], a[2] || false, a[3] || 1)) }
      oidreq.add_extension(axreq)
      oidreq.return_to_args['did_ax'] = 'y'
    end
    if params[:use_pape]
      papereq = OpenID::PAPE::Request.new
      papereq.add_policy_uri(OpenID::PAPE::AUTH_PHISHING_RESISTANT)
      papereq.max_auth_age = 60
      oidreq.add_extension(papereq)
      oidreq.return_to_args['did_pape'] = 'y'
    end
    if params[:force_post]
      oidreq.return_to_args['force_post'] = 'x' * 2048
    end
    if oidreq.send_redirect?(consumer_url, consumer_complete_url, params[:immediate])
      redirect_to oidreq.redirect_url(consumer_url, consumer_complete_url, params[:immediate])
    else
      @form_text = oidreq.form_markup(consumer_url, consumer_complete_url, params[:immediate], { 'id' => 'checkid_form' })
    end
  end

  def complete
    parameters = params.reject{ |k,v| request.path_parameters[k] }
    oidresp = openid_consumer.complete(parameters, url_for({}))
    case oidresp.status
    when OpenID::Consumer::SETUP_NEEDED
      flash[:error] = "Immediate request failed - setup needed"
    when OpenID::Consumer::CANCEL
      flash[:error] = "OpenID transaction cancelled."
    when OpenID::Consumer::FAILURE
      flash[:error] = oidresp.display_identifier ?
        "Verification of #{oidresp.display_identifier} failed: #{oidresp.message}" :
        "Verification failed: #{oidresp.message}"
    when OpenID::Consumer::SUCCESS
      flash[:notice] = "Verification of #{oidresp.display_identifier} succeeded."
      if params[:did_sreg]
        sreg_resp = OpenID::SReg::Response.from_success_response(oidresp)
        sreg_message = "\n\nSimple Registration data was requested"
        if sreg_resp.empty?
          sreg_message << ", but none was returned."
        else
          sreg_message << ". The following data were sent:\n"
          sreg_resp.data.each { |k,v| sreg_message << "#{k}: #{v}\n" }
        end
        flash[:notice] += sreg_message
      end
      if params[:did_ax]
        ax_resp = OpenID::AX::FetchResponse.from_success_response(oidresp)
        ax_message = "\n\nAttribute Exchange data was requested"
        unless ax_resp
          ax_message << ", but none was returned."
        else
          ax_message << ". The following data were sent:\n"
          ax_resp.data.each { |k,v| ax_message << "#{k}: #{v}\n" }
        end
        flash[:notice] += ax_message
      end
      if params[:did_pape]
        pape_resp = OpenID::PAPE::Response.from_success_response(oidresp)
        pape_message = "\n\nAuthentication policies were requested"
        unless pape_resp.auth_policies.empty?
          pape_message << ", and the server reported the following:\n"
          pape_resp.auth_policies.each { |p| pape_message << "#{p}\n" }
        else
          pape_message << ", but the server did not report one."
        end
        pape_message << "\nAuthentication time: #{pape_resp.auth_time}" if pape_resp.auth_time
        pape_message << "\nNIST Auth Level: #{pape_resp.nist_auth_level}" if pape_resp.nist_auth_level
        flash[:notice] += pape_message
      end
    end
    redirect_to :action => 'index'
  end
  
  private
  
  # OpenID consumer reader, used to access the consumer functionality
  def openid_consumer
    @openid_consumer ||= OpenID::Consumer.new(session, ActiveRecordStore.new)
  end
  
end
