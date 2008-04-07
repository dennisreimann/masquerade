xml.instruct!
xml.xrds(:XRDS, 'xmlns:xrds' => 'xri://$xrds', 'xmlns' => 'xri://$xrd*($v*2.0)') do
	xml.XRD do
    xml.Service(:priority => 1) do
      @types.each { |type| xml.Type type }
  		xml.URI server_url
    end
  end
end