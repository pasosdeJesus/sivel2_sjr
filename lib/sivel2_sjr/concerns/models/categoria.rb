require 'sivel2_gen/concerns/models/categoria'

module Sivel2Sjr
  module Concerns
    module Models
      module Categoria
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Categoria

        included do

          has_many :actosjr, class_name: 'Sivel2Sjr::Actosjr',
            through: :acto
          has_many :casosjr, foreign_key: "categoriaref", validate: true,
            class_name: 'Sivel2Sjr::Casosjr'

        end

        module ClassMethods
        end

      end
    end
  end
end
