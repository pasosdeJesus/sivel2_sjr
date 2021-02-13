# encoding: UTF-8

Rails.application.routes.draw do

  rutarel = ENV.fetch('RUTA_RELATIVA', 'sivel2sjr/')
  scope rutarel do
    devise_scope :usuario do
      get 'sign_out' => 'devise/sessions#destroy'

      # El siguiente para superar mala generación del action en el formulario
      # cuando se autentica mal (genera
      # /puntomontaje/puntomontaje/usuarios/sign_in )
      if (Rails.configuration.relative_url_root != '/')
        ruta = File.join(Rails.configuration.relative_url_root,
                         'usuarios/sign_in')
        post ruta, to: 'devise/sessions#create'
        get  ruta, to: 'devise/sessions#new'
      end
    end

    devise_for :usuarios, :skip => [:registrations], module: :devise
    as :usuario do
      get 'usuarios/edit' => 'devise/registrations#edit',
        :as => 'editar_registro_usuario'
      put 'usuarios/:id' => 'devise/registrations#update',
        :as => 'registro_usuario'
    end
    resources :usuarios, path_names: { new: 'nuevo', edit: 'edita' }

    patch '/actos/agregar' => 'sivel2_sjr/actos#agregar'
    get '/actos/eliminar' => 'sivel2_sjr/actos#eliminar'

    #get '/personas' => 'sivel2_sjr/personas#index'
    #get '/personas/remplazar' => 'sivel2_sjr/personas#remplazar'

    root 'sip/hogar#index'
    namespace :admin do
      ab = ::Ability.new
      ab.tablasbasicas.each do |t|
        if (t[0] == '')
          c = t[1].pluralize
          resources c.to_sym,
            path_names: { new: 'nueva', edit: 'edita' }
        end
      end
    end
  end

  mount Sivel2Sjr::Engine, at: rutarel, as: 'sivel2_sjr'
  mount Cor1440Gen::Engine, at: rutarel, as: 'cor1440_gen'
  mount Sivel2Gen::Engine, at: rutarel, as: 'sivel2_gen'
  mount Heb412Gen::Engine, at: rutarel, as: 'heb412_gen'
  mount Mr519Gen::Engine, at: rutarel, as: 'mr519_gen'
  mount Sip::Engine, at: rutarel, as: 'sip'
end
