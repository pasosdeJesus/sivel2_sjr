# encoding: UTF-8

require_relative '../../test_helper'

module Sip
  class OficinaTest < ActiveSupport::TestCase
    PRUEBA_OFICINA = {
      nombre:"Oficina1",
      fechacreacion:"2014-08-05",
      fechadeshabilitacion:nil
    }

    test "valido" do
      oficina = Oficina.create PRUEBA_OFICINA
      assert oficina.valid?
      oficina.destroy
    end

    test "no valido" do
      oficina = Oficina.new PRUEBA_OFICINA
      oficina.nombre = ''
      assert_not oficina.valid?
      oficina.destroy
    end

    test "existente" do
      oficina = Sip::Oficina.where(id: 1).take
      assert_equal oficina.nombre, "SIN INFORMACIÓN"
    end
  end
end
