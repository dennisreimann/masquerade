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
      sregreq.policy_url = "http://www.policy-url.com"
      sregreq.request_fields(['nickname', 'email'], true) # required fields
      sregreq.request_fields(['fullname', 'dob'], false)   # optional fields
      oidreq.add_extension(sregreq)
      oidreq.return_to_args['did_sreg'] = 'y'
    end
    if params[:use_pape]
      papereq = OpenID::PAPE::Request.new
      papereq.add_policy_uri(OpenID::PAPE::AUTH_PHISHING_RESISTANT)
      papereq.max_auth_age = 2*60*60
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
    when OpenID::Consumer::FAILURE
      flash[:error] = oidresp.display_identifier ?
        "Verification of #{oidresp.display_identifier} failed: #{oidresp.message}" :
        "Verification failed: #{oidresp.message}"
    when OpenID::Consumer::SUCCESS
      flash[:notice] = ("Verification of #{oidresp.display_identifier} succeeded.")
      if params[:did_sreg]
        sreg_resp = OpenID::SReg::Response.from_success_response(oidresp)
        sreg_message = "Simple Registration data was requested"
        if sreg_resp.empty?
          sreg_message << ", but none was returned."
        else
          sreg_message << ". The following data were sent:"
          sreg_resp.data.each { |k,v| sreg_message << "<br/><b>#{k}</b>: #{v}" }
        end
        flash[:sreg_results] = sreg_message
      end
      if params[:did_pape]
        pape_resp = OpenID::PAPE::Response.from_success_response(oidresp)
        pape_message = "A phishing resistant authentication method was requested"
        if pape_resp.auth_policies.member? OpenID::PAPE::AUTH_PHISHING_RESISTANT
          pape_message << ", and the server reported one."
        else
          pape_message << ", but the server did not report one."
        end
        pape_message << "<br><b>Authentication age:</b> #{pape_resp.auth_age} seconds" if pape_resp.auth_age
        pape_message << "<br><b>NIST Auth Level:</b> #{pape_resp.nist_auth_level}" if pape_resp.nist_auth_level
        flash[:pape_results] = pape_message
      end
    when OpenID::Consumer::SETUP_NEEDED
      flash[:error] = "Immediate request failed - Setup Needed"
    when OpenID::Consumer::CANCEL
      flash[:error] = "OpenID transaction cancelled."
    end
    redirect_to :action => 'index'
  end
  
  private
  
  # OpenID-Consumer Singleton Accessor, wird für Zugriffe
  # auf den Consumer im Controller verwendet 
  def openid_consumer
    @openid_consumer ||= OpenID::Consumer.new(session, ActiveRecordStore.new)
  end
  
end
