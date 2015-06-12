# encoding: UTF-8

require 'sip/concerns/models/oficina'

module Sivel2Sjr
  module Concerns
    module Models
      module Oficina
        extend ActiveSupport::Concern
        include Sip::Concerns::Models::Oficina

        included do
          has_many :casosjr, class_name: 'Sivel2Sjr::Casosjr',
            foreign_key: "oficina_id", validate: true
        end

        module ClassMethods
        end

      end
    end
  end
end
