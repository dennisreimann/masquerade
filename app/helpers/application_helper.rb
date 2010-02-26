module ApplicationHelper
  
  def page_title
    @page_title ? "#{@page_title} | #{APP_CONFIG['name']}" : APP_CONFIG['name']
  end
  
  def label_tag(field, text = nil, options = {})
    content_tag :label, text ? text : field.to_s.humanize, options.reverse_merge(:for => field.to_s)
  end
  
  # Is the current page an identity page? This is used to display
  # further information (like the endoint url) in the <head>
  def identity_page?
    active_page? 'accounts' => ['show']
  end
  
  # Is the current page the home page? This is used to display
  # further information (like the endoint url) in the <head>
  def home_page?
    active_page? 'info' => ['index']
  end
  
  # Custom label names for request properties (like SReg data)
  def property_label_text(property)
    case property.to_sym
    when :image_default then t(:image_url)
    when :web_default then t(:website_url)
    when :web_blog then t(:blog_url)
    else t(property.to_sym)
    end
  end
  
  def property_label_text_for_type_uri(type_uri)
    property = Persona.attribute_name_for_type_uri(type_uri)
    property ? property_label_text(property) : type_uri
  end
  
  # Renders a navigation element and marks it as active where
  # appropriate. See active_page? for details
  def nav(name, url, pages = nil, active = false)
    content_tag :li, link_to(name, url), :class => (active || (pages && active_page?(pages)) ? 'act' : nil)
  end
  
  # Takes a hash with pages and tells whether the current page is among them.
  # The keys must be controller names and their value must be an array of
  # action names. If the array is empty, every action is supposed to be valid. 
  def active_page?(pages = {})
    is_active = pages.include?(params[:controller])
    is_active = pages[params[:controller]].include?(params[:action]) if is_active && !pages[params[:controller]].empty?
    is_active
  end
  
end