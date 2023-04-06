module Sivel2Sjr
  class Rolfamilia < ActiveRecord::Base
    include Msip::Basica
  
  	has_many :victimasjr, class_name: "Sivel2Sjr::Victimasjr", 
      foreign_key: "rolfamilia_id", validate: true
  end
end
