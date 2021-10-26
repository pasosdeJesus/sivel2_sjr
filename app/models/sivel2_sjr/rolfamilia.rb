module Sivel2Sjr
  class Rolfamilia < ActiveRecord::Base
    include Sip::Basica
  
  	has_many :victimasjr, class_name: "Sivel2Sjr::Victimasjr", 
      foreign_key: "id_rolfamilia", validate: true
  end
end
