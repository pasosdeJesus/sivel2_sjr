require_dependency 'sivel2_sjr/concerns/controllers/actividades_controller'

module Cor1440Gen
  class ActividadesController < Heb412Gen::ModelosController

    before_action :set_actividad, 
      only: [:show, :edit, :update, :destroy],
      exclude: [:contar, :contar_beneficiarios]
    load_and_authorize_resource class: Cor1440Gen::Actividad

    include Sivel2Sjr::Concerns::Controllers::ActividadesController
  end
end
