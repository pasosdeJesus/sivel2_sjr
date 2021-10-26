require_dependency 'sivel2_sjr/concerns/controllers/respuestas_controller'

module Sivel2Sjr
  class RespuestasController < ApplicationController

    load_and_authorize_resource class: Sivel2Sjr::Respuesta

    include Sivel2Sjr::Concerns::Controllers::RespuestasController

  end
end
