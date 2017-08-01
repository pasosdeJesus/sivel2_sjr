# encoding: UTF-8

require 'sivel2_gen/concerns/models/consexpcaso'

module Sivel2Sjr
  module Concerns
    module Models
      module Consexpcaso 
        extend ActiveSupport::Concern

        include Sivel2Gen::Concerns::Models::Consexpcaso

        included do
        end # included

        module ClassMethods

          def consulta_consexpcaso 
            "SELECT conscaso.*
             FROM sivel2_gen_conscaso AS conscaso"
          end
        end # ClassMethods

      end
    end
  end
end
