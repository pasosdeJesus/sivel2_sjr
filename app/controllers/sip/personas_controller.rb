require 'sivel2_sjr/concerns/controllers/personas_controller'

module Sip
  class PersonasController < Heb412Gen::ModelosController

    load_and_authorize_resource class: Sip::Persona
    include Sivel2Sjr::Concerns::Controllers::PersonasController

  end
end
