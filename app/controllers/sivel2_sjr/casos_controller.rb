require_dependency 'sivel2_sjr/concerns/controllers/casos_controller'

module Sivel2Sjr
  class CasosController < Heb412Gen::ModelosController

    before_action :set_caso, only: [:show, :edit, :update, :destroy],
      exclude: [:poblacion_sexo_rangoedadac]
    load_and_authorize_resource class: Sivel2Gen::Caso

    include Sivel2Sjr::Concerns::Controllers::CasosController

  end
end
