class Language < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :code
end
