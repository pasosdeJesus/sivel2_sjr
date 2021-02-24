json.set! caso.id do
  if caso.ubicacion[0]
    ubi_prin = Sip::Ubicacion.find(caso.ubicacion[0].id)
    json.latitud ubi_prin.latitud if ubi_prin.latitud
    json.longitud ubi_prin.longitud if ubi_prin.longitud
    if ubi_prin.departamento && params && params[:filtro] && 
      params[:filtro][:inc_ubicaciones].to_i == 2
      json.departamento ubi_prin.departamento.nombre
      if ubi_prin.municipio
        json.municipio ubi_prin.municipio.nombre
      end
    end
    json.titulo caso.titulo
    json.fecha caso.fecha
    if params && params[:filtro] && params[:filtro][:inc_memo].to_i == 2
      json.descripcion caso.memo
    end
  end
end
