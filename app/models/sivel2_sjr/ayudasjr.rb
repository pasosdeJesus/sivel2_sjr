module Sivel2Sjr
  class Ayudasjr < ActiveRecord::Base
    include Msip::Basica
  
  	has_many :ayudasjr_respuesta, class_name: "Sivel2Sjr::AyudasjrRespuesta", 
      foreign_key: "id_ayudasjr", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :ayudasjr_respuesta

    has_and_belongs_to_many :derecho,
      class_name: 'Sivel2Sjr::Derecho',
      foreign_key: 'ayudasjr_id',
      association_foreign_key: 'derecho_id',
      join_table: 'sivel2_sjr_ayudasjr_derecho'

    before_destroy :confirmar_ayudasjr_derecho

    private

    # No ha operado
    def confirmar_ayudasjr_derecho
      if Sivel2Sjr::AyudasjrRespuesta.where(id_ayudasjr: id).take 
        errors.add(:base, "hay respuestas con esta ayuda humanitaria")
        return false
      end
      return true
    end

  end
end
