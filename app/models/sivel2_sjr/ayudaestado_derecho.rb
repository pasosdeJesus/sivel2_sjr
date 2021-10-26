module Sivel2Sjr
  class AyudaestadoDerecho < ActiveRecord::Base
    belongs_to :ayudaestado, class_name: "Sivel2Sjr::Ayudaestado", 
      foreign_key: "ayudaestado_id", validate: true
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", validate: true
  end
end
