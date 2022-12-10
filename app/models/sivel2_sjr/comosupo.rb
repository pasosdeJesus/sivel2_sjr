module Sivel2Sjr
  class Comosupo < ActiveRecord::Base
    include Msip::Basica
  
  	has_many :casosjr, class_name: "Sivel2Sjr::Casosjr"
  end
end
