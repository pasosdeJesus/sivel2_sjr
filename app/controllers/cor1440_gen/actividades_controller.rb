# encoding: UTF-8

require_dependency 'sivel2_sjr/concerns/controllers/actividades_controller'

module Cor1440Gen
  class ActividadesController < Heb412Gen::ModelosController

    include Sivel2Sjr::Concerns::Controllers::ActividadesController

    before_action :set_actividad, 
      only: [:show, :edit, :update, :destroy],
      exclude: [:contar]
    load_and_authorize_resource class: Cor1440Gen::Actividad

  end
end
