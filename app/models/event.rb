class Event < ActiveRecord::Base
  attr_accessible :event_id, :name, :ratio
  
  validates_uniqueness_of :event_id
  
end
