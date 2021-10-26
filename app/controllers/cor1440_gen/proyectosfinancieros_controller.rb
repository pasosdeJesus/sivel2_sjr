require_dependency 'sivel2_sjr/concerns/controllers/proyectosfinancieros_controller'

module Cor1440Gen
  class ProyectosfinancierosController < Sip::ModelosController

    load_and_authorize_resource  class: Cor1440Gen::Proyectofinanciero,
      only: [:new, :create, :destroy, :edit, :update, :index, :show,
             :objetivospf]
    include Sivel2Sjr::Concerns::Controllers::ProyectosfinancierosController

  end
end
