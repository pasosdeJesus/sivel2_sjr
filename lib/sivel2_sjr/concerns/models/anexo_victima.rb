# encoding: UTF-8

module Sivel2Sjr
  module Concerns
    module Models
      module AnexoVictima
        extend ActiveSupport::Concern

        included do
          include Sip::Localizacion
          include Sip::FormatoFechaHelper

          belongs_to :victima, foreign_key: "id_victima", validate: true, 
            class_name: "Sivel2Gen::Victima", inverse_of: :anexo_victima
          belongs_to :sip_anexo, foreign_key: "id_anexo", validate: true, 
            class_name: "Sip::Anexo"
          accepts_nested_attributes_for :sip_anexo, reject_if: :all_blank
          

          campofecha_localizado :fecha

          validates :victima, presence: true
          validates :sip_anexo, presence: true
          validates :fecha, presence: true
        end

      end
    end
  end
end

