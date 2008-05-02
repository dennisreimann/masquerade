xml.instruct!
xml.personaConfig(:serverIdentifier => endpoint_url, :version => '1.0') do
	xml.persona(identifier(current_account)) if logged_in?
end