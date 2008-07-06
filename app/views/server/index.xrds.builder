xml.instruct!
xml.xrds(:XRDS,
  'xmlns:openid' => OpenID::OPENID_1_0_NS,
  'xmlns:xrds' => 'xri://$xrds',
  'xmlns' => 'xri://$xrd*($v*2.0)') do
	xml.XRD do
    xml.Service(:priority => 1) do
      xml.Type OpenID::OPENID_IDP_2_0_TYPE
      xml.Type OpenID::SReg::NS_URI_1_1
      xml.Type OpenID::SReg::NS_URI_1_0
      xml.Type OpenID::AX::AXMessage::NS_URI
      xml.Type OpenID::PAPE::NS_URI
  		xml.URI endpoint_url
    end
  end
end