# encoding: UTF-8

require 'sip/concerns/models/ubicacionpre'

module Sivel2Sjr
  module Concerns
    module Models
      module Ubicacionpre
        extend ActiveSupport::Concern
        include Sip::Concerns::Models::Ubicacionpre

        included do

          has_many :expulsion, class_name: "Sivel2Sjr::Desplazamiento", 
            foreign_key: "id_expulsion", validate: true, dependent: :destroy
          has_many :llegada, class_name: "Sivel2Sjr::Desplazamiento", 
            foreign_key: "id_llegada", validate: true, dependent: :destroy
        end
      end
    end
  end
end

