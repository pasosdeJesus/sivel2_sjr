require_dependency 'sivel2_sjr/concerns/controllers/mindicadorespf_controller'

module Cor1440Gen
  class MindicadorespfController < Msip::ModelosController


    load_and_authorize_resource class: Cor1440Gen::Mindicadorpf
    include Sivel2Sjr::Concerns::Controllers::MindicadorespfController

  end
end
