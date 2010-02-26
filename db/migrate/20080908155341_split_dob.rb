class SplitDob < ActiveRecord::Migration
  def self.up
    add_column :personas, :dob_day, :integer, :limit => 2
    add_column :personas, :dob_month, :integer, :limit => 2
    add_column :personas, :dob_year, :integer, :limit => 4
    
    Persona.all.each do |persona|
      persona.dob_day   = persona.dob? ? persona.dob.day   : nil
      persona.dob_month = persona.dob? ? persona.dob.month : nil
      persona.dob_year  = persona.dob? ? persona.dob.year  : nil
      persona.save
    end
    
    remove_column :personas, :dob
  end

  def self.down
    remove_column :personas, :dob_day
    remove_column :personas, :dob_month
    remove_column :personas, :dob_year
    add_column :personas, :dob, :date
  end
end
