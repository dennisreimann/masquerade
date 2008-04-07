module ServerHelper
  
  def sreg_request_for_field(field_name)
    if required_sreg_fields.include?(field_name)
      "required"
    elsif optional_sreg_fields.include?(field_name)
      "optional"
    end
  end
  
end