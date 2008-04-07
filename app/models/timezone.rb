class Timezone < ActiveRecord::Base
  validates_presence_of :name
end
