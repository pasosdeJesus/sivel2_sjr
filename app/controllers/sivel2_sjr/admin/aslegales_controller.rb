# encoding: UTF-8

require  'sivel2_sjr/concerns/controllers/aslegales_controller'

module Sivel2Sjr
  module Admin
    class AslegalesController < Sip::Admin::BasicasController

      include Sivel2Sjr::Concerns::Controllers::AslegalesController

    end
  end
end
