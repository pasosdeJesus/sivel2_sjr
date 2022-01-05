module Sivel2Sjr
  class ProgestadoDerecho < ActiveRecord::Base
    belongs_to :progestado, class_name: "Sivel2Sjr::Progestado", 
      foreign_key: "progestado_id", validate: true, optional: false
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", validate: true, optional: false
  end
end
