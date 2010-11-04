# Configure generators values. Many other options are available, be sure to check the documentation.
Rails.application.config.generators do |g|
  g.orm             :active_record
  g.template_engine :erb
  g.test_framework  :test_unit, :fixture => true
end
