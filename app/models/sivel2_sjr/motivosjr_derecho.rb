module Sivel2Sjr
  class MotivosjrDerecho < ActiveRecord::Base
    belongs_to :motivosjr, class_name: "Sivel2Sjr::Motivosjr", 
      foreign_key: "motivosjr_id"
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id"
  end
end
