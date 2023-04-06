module Sivel2Sjr
  module RangoedadHelper

    # Calcula matriz con poblacion de un caso por sexo y rangos de edad 
    # @param caso_id # Caso
    # @param (anio,mes,dia) Fecha de referencia para calculo de edades
    # @param modelorango Modelo con rangos de edades por usar
    # @param rangoedad Incrementa este hash/matriz que tiene [sexo][rango]
    #   tipicamente funciona llamadora lo inicia con
    #   rangoedad = {'S' => {}, 'M' => {}, 'F' => {}}
    # @param totsexo Incrementa este hash con llaves 'S' 'M' y 'F',
    #   tipicamente función llamador lo inicia con:
    #   totsexo ={}
    # @return true sii puede calcular poblacion por sexo y rangos de edad
    def poblacion_por_sexo_rango(caso_id, anio, mes, dia, modelorango, rangoedad, totsexo)
      casosjr = Sivel2Sjr::Casosjr.where(caso_id: caso_id)

      if casosjr.count < 1 
        return false
      end

      # Contar de un caso solo los no desagregados o desagregados
      # después de la fecha de la actividad
      fechaac = anio.to_s + '-' + mes.to_s + '-' + dia.to_s
      casosjr.take.caso.victima.joins(
        'JOIN msip_persona ' \
        'ON msip_persona.id=sivel2_gen_victima.persona_id'
      ).joins(
        'JOIN sivel2_sjr_victimasjr ON ' \
        'sivel2_sjr_victimasjr.victima_id=sivel2_gen_victima.id'
      ).where('sivel2_sjr_victimasjr.fechadesagregacion IS NULL OR ' +
              'sivel2_sjr_victimasjr.fechadesagregacion > ?', fechaac).
      each do |vi|
        re = Sivel2Gen::RangoedadHelper.buscar_rango_edad(
          Sivel2Gen::RangoedadHelper.edad_de_fechanac_fecha(
            vi.persona.anionac, vi.persona.mesnac, vi.persona.dianac,
            anio, mes, dia), modelorango)
        if !rangoedad[vi.persona.sexo]
          rangoedad[vi.persona.sexo] = {}
        end
        if !rangoedad[vi.persona.sexo][re]
          rangoedad[vi.persona.sexo][re] = 0
        end
        rangoedad[vi.persona.sexo][re] += 1
        totsexo[vi.persona.sexo] = totsexo[vi.persona.sexo] ?
          totsexo[vi.persona.sexo] + 1 : 1
      end
      return true
    end 
    module_function :poblacion_por_sexo_rango

  end
end
