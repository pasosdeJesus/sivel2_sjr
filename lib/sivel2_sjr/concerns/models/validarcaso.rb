require 'sivel2_gen/concerns/models/validarcaso'

module Sivel2Sjr
  module Concerns
    module Models
      module Validarcaso
        extend ActiveSupport::Concern
        include Sivel2Gen::Concerns::Models::Validarcaso

        included do
          attr_accessor :oficina_id
        end

      end
    end
  end
end
