# encoding: UTF-8

require 'sivel2_gen/concerns/models/presponsable'

module Sivel2Sjr
  module Concerns
    module Models
      module Presponsable
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Presponsable

        included do
          has_many :actosjr, class_name: 'Sivel2Sjr::Actosjr',
            through: :acto
        end

        module ClassMethods
        end

      end
    end
  end
end
