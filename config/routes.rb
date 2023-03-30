Sivel2Sjr::Engine.routes.draw do

  get '/consactividadcaso' => 'consactividadcaso#index', 
    as: :consactividadcaso

  patch '/actos/agregar' => 'actos#agregar' 
  get '/actos/eliminar' => 'actos#eliminar'

  get '/casos/lista' => 'casos#lista'
  get '/casos/mapaosm' => 'casos#mapaosm'
  get '/casos/nuevaubicacion' => 'casos#nueva_ubicacion'
  get '/casos/nuevavictima' => 'casos#nueva_victima'
  get '/casos/nuevopresponsable' => 'casos#nuevo_presponsable'
  get '/casos/busca' => 'casos#busca'
  get '/casos/filtro' => 'casos#index', as: :casos_filtro
  post '/casos/filtro' => 'casos#index', as: :envia_casos_filtro

  get '/conteos/personas' => 'conteos#personas', as: :conteos_personas
  post "/conteos/personas" => 'conteos#personas', as: :post_conteos_personas
  get '/conteos/respuestas' => 'conteos#respuestas', as: :conteos_respuestas

  get '/desplazamientos/nuevo' => 'desplazamientos#nuevo'

  get '/respuestas/nuevo' => 'respuestas#nuevo'

#  get '/victimas' => 'victimas#index', as: :victimas
#  get '/victimas/nuevo' => 'victimas#nuevo'
  get '/victimascolectivas/nuevo' => 'victimascolectivas#nuevo'
 
  get "/api/sivel2sjr/poblacion_sexo_rangoedadac" => 'casos#poblacion_sexo_rangoedadac',
    as: :sivel2sjr_poblacion_sexo_rangoedadac

  resources :casos, path_names: { new: 'nuevo', edit: 'edita' }

  namespace :admin do
    ab = ::Ability.new
    ab.tablasbasicas.each do |t|
      if (t[0] == 'Sivel2Sjr') 
        c = t[1].pluralize
        resources c.to_sym, 
          path_names: { new: 'nueva', edit: 'edita' }
      end
    end
  end


end
