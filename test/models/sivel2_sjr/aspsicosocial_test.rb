require_relative '../../test_helper'

module Sivel2Sjr
  class AspsicosocialTest < ActiveSupport::TestCase

    PRUEBA_ASPSICOSOCIAL ={
      nombre: "A",
      fechacreacion: "2018-11-11",
      created_at: "2018-11-11"
    }

    test "valido" do
      aspsicosocial = Aspsicosocial.create PRUEBA_ASPSICOSOCIAL
      assert aspsicosocial.valid?
      aspsicosocial.destroy
    end

    test "no valido" do
      aspsicosocial = Aspsicosocial.new PRUEBA_ASPSICOSOCIAL
      aspsicosocial.nombre = ''
      assert_not aspsicosocial.valid?
      aspsicosocial.destroy
    end


  end
end
