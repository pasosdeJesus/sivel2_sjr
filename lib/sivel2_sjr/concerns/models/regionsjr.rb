# encoding: UTF-8

require 'sivel2_gen/concerns/models/regionsjr'

module Sivel2Sjr
  module Concerns
    module Models
      module Regionsjr
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Regionsjr

        included do
          has_many :actividad, class_name: 'Sivel2Gen::Actividad'
          has_many :usuario

          validates_presence_of :nombre
          validates_presence_of :fechacreacion
        end

        module ClassMethods
        end

      end
    end
  end
end
