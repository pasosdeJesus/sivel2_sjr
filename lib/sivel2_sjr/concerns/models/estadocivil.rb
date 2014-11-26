# encoding: UTF-8

require 'sivel2_gen/concerns/models/estadocivil'

module Sivel2Sjr
  module Concerns
    module Models
      module Estadocivil
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Estadocivil

        included do
          validates :nombre, presence: true, allow_blank: false
          validates :fechacreacion, presence: true, allow_blank: false
        end

        module ClassMethods
        end

      end
    end
  end
end
