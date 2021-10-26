require 'sivel2_gen/concerns/models/escolaridad'

module Sivel2Sjr
  module Concerns
    module Models
      module Escolaridad
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Escolaridad

        included do
          has_many :victimasjr, foreign_key: "id_escolaridad", 
            validate: true, class_name: 'Sivel2Sjr::Victimasjr'
        end

        module ClassMethods
        end

      end
    end
  end
end
