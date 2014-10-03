Rails.application.routes.draw do
  get '/desplazamientos/nuevo' => 'desplazamientos#nuevo'
  get '/respuestas/nuevo' => 'respuestas#nuevo'
end
