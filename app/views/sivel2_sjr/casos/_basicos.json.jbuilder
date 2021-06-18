json.set! caso.id do
  casosjr = Sivel2Sjr::Casosjr.find(caso.id)
  if casosjr
    mig = Sivel2Sjr::Migracion.where(caso_id: casosjr.id).order(:id)[0]
    if mig
      if mig.salida_municipio
        json.latitud mig.salida_municipio.latitud
        json.longitud mig.salida_municipio.longitud
      elsif mig.salida_departamento 
        json.latitud mig.salida_departamento.latitud
        json.longitud mig.salida_departamento.longitud
      elsif mig.salida_pais
        json.latitud mig.salida_pais.latitud
        json.longitud mig.salida_pais.longitud
      end
    end
    json.titulo caso.titulo
    json.fecha caso.fecha
    if params && params[:filtro] && params[:filtro][:inc_memo].to_i == 2
      json.descripcion caso.memo
    end
  end
end
