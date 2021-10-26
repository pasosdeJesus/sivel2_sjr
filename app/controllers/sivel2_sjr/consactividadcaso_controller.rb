require 'sivel2_sjr/concerns/controllers/consactividadcaso_controller'

module Sivel2Sjr
  class ConsactividadcasoController < Heb412Gen::ModelosController

    load_and_authorize_resource class: Sivel2Sjr::Consactividadcaso

    include Sivel2Sjr::Concerns::Controllers::ConsactividadcasoController

  end
end
