require_relative '../../test_helper'

module Sivel2Sjr
  class RolfamiliaTest < ActiveSupport::TestCase

    PRUEBA_ROLFAMILIA={
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11"
    }

    test "valido" do
      rolfamilia = Rolfamilia.create PRUEBA_ROLFAMILIA
      assert rolfamilia.valid?
      rolfamilia.destroy
    end

    test "no valido" do
      rolfamilia = Rolfamilia.new PRUEBA_ROLFAMILIA 
      rolfamilia.nombre=''
      assert_not rolfamilia.valid?
      rolfamilia.destroy
    end

    test "existente" do
      rolfamilia = Rolfamilia.where(id: 0).take
      assert_equal rolfamilia.nombre, "SIN INFORMACIÓN"
    end

  end
end
