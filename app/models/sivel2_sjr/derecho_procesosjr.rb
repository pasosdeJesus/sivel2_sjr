module Sivel2Sjr
  class DerechoProcesosjr < ActiveRecord::Base
  	belongs_to :procesosjr, class_name: "Sivel2Sjr::Procesosjr", 
      foreign_key: "id_proceso", validate: true, optional: false
  	belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", validate: true, optional: false
  end
end
