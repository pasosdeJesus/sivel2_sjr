require_relative '../../test_helper'

module Sivel2Sjr
  class MotivosjrTest < ActiveSupport::TestCase

    PRUEBA_MOTIVOSJR={
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11"
    }


    test "valido" do
      motivosjr = Motivosjr.create PRUEBA_MOTIVOSJR
      assert motivosjr.valid?
      motivosjr.destroy
    end

    test "no valido" do
      motivosjr = Motivosjr.new PRUEBA_MOTIVOSJR 
      motivosjr.nombre=''
      assert_not motivosjr.valid?
      motivosjr.destroy
    end

    test "existente" do
      motivosjr = Motivosjr.where(id: 0).take
      assert_equal motivosjr.nombre, "SIN INFORMACIÓN"
    end

  end
end
