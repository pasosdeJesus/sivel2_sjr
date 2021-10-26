require_relative '../../test_helper'

module Sivel2Gen
  class IglesiaTest < ActiveSupport::TestCase

    PRUEBA_IGLESIA = {
      nombre: 'n',
      fechacreacion: '2017-03-08', 
      fechadeshabilitacion: nil
    }

    test "valido" do
      iglesia = Iglesia.create PRUEBA_IGLESIA
      assert iglesia.valid?
      iglesia.destroy
    end

    test "no valido" do
      iglesia = Iglesia.create PRUEBA_IGLESIA
      iglesia.nombre = ''
      assert_not iglesia.valid?
      iglesia.destroy
    end

    test "existente" do
      iglesia = Iglesia.where(id: 1).take
      assert_equal iglesia.nombre, "SIN INFORMACIÓN"
    end

  end
end
