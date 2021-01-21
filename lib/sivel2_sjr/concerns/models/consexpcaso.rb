# encoding: UTF-8

require 'sivel2_gen/concerns/models/consexpcaso'

module Sivel2Sjr
  module Concerns
    module Models
      module Consexpcaso 
        extend ActiveSupport::Concern

        include Sivel2Gen::Concerns::Models::Consexpcaso

        included do

          belongs_to :casosjr, class_name: 'Sivel2Sjr::Casosjr',
            primary_key: 'id_caso', foreign_key: 'caso_id'

          has_many :victimasjr, through: :casosjr,
            class_name: 'Sivel2Sjr::Victimasjr'

        end # included

        module ClassMethods

          def consulta_consexpcaso 
            "SELECT conscaso.*
             FROM public.sivel2_gen_conscaso AS conscaso"
          end
        end # ClassMethods

      end
    end
  end
end

