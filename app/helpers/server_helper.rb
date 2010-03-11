module ServerHelper
  
  def sreg_request_for_field(field_name)
    if sreg_request.required.include?(field_name)
      t(:required)
    elsif sreg_request.optional.include?(field_name)
      t(:optional)
    end
  end
  
  def ax_request_for_field(ax_attribute)
    ax_attribute.required ? t(:required) : t(:optional)
  end
  
end