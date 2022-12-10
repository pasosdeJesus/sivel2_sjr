require 'sivel2_sjr/concerns/controllers/personas_controller'

module Msip
  class PersonasController < Heb412Gen::ModelosController

    load_and_authorize_resource class: Msip::Persona
    include Sivel2Sjr::Concerns::Controllers::PersonasController

  end
end
