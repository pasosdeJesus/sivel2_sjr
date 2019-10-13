class CompletaPoblacionRespconv < ActiveRecord::Migration[6.0]
  def change
    Cor1440Gen::Actividad.where("nombre LIKE 'Respuesta al caso %'").
      each do |a|
      if a.casosjr_ids.length > 0
        rangoedad = {'S' => {}, 'M' => {}, 'F' => {}}
        totsexo = {}
        Sivel2Gen::RangoedadHelper.poblacion_por_rangos(
          a.casosjr_ids[0], a.fecha.year, a.fecha.month, a.fecha.day,
          'Cor1440Gen::Rangoedadac', rangoedad, totsexo)
        byebug
        otrango = {}
        rangoedad.each do |s, gr|
          gr.each do |re, num|
            if !otrango[re]
              otrango[re] = {}
            end
            otrango[re][s] = num
          end
        end
        otrango.each do |re, gs|
          tf = gs['F'] ? gs['F'] : 0
          tm = gs['M'] ? gs['M'] : 0
          tm += gs['S'] ? gs['S'] : 0
          rea = Cor1440Gen::ActividadRangoedadac.create({
            actividad_id: a.id,
            rangoedadac_id: re,
            fr: tf,
            mr: tm
          })
          rea.save
        end

      end
    end
  end

  def down
    execute <<-SQL
      DELETE FROM cor1440_gen_actividadrangoedadac WHERE
        actividad_id IN (SELECT id FROM cor1440_gen_actividad
          WHERE nombre LIKE 'Respuesta al caso%');
    SQL
  end
end
