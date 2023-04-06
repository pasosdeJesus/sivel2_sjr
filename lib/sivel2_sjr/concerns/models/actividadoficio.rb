require 'sivel2_gen/concerns/models/actividadoficio'

module Sivel2Sjr
  module Concerns
    module Models
      module Actividadoficio
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Actividadoficio

        included do
          has_many :victimasjr, foreign_key: "actividadoficio_id", 
            validate: true, class_name: 'Sivel2Sjr::Victimasjr'
        end

        module ClassMethods
        end

      end
    end
  end
end
