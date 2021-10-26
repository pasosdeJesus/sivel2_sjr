require_relative '../../test_helper'

module Sivel2Sjr
  class AyudaestadoTest < ActiveSupport::TestCase

    PRUEBA_AYUDAESTADO={
      nombre: "A",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11"
    }

    test "valido" do
      ayudaestado = Ayudaestado.create PRUEBA_AYUDAESTADO
      assert ayudaestado.valid?
      ayudaestado.destroy
    end

    test "no valido" do
      ayudaestado = Ayudaestado.new PRUEBA_AYUDAESTADO
      ayudaestado.nombre = ''
      assert_not ayudaestado.valid?
      ayudaestado.destroy
    end

    test "existente" do
      ayudaestado = Ayudaestado.where(id: 0).take
      assert_equal ayudaestado.nombre, "SIN INFORMACIÓN"
    end

  end
end
