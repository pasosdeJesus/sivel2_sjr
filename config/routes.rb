Rails.application.routes.draw do
    get '/desplazamiento/nuevo' => 'desplazamiento#nuevo'
    get '/respuesta/nuevo' => 'respuesta#nuevo'
end
