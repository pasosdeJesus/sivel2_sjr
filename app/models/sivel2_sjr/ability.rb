# encoding: UTF-8

module Sivel2Sjr
  class Ability < Sivel2Gen::Ability
    # Tablas básicas
    @@tablasbasicas = [
      ['Sivel2Gen', 'actividadarea'], ['Sivel2Gen', 'actividadoficio'],  
      ['Sivel2Sjr', 'aslegal'], 
      ['Sivel2Sjr', 'ayudasjr'], 
      ['Sivel2Gen', 'categoria'], ['Sivel2Gen', 'clase'], 
      ['Sivel2Sjr', 'comosupo'], 
      ['Sivel2Gen', 'departamento'], 
      ['Sivel2Gen', 'escolaridad'],
      ['Sivel2Gen', 'estadocivil'], ['Sivel2Gen', 'etiqueta'], 
      ['Sivel2Gen', 'etnia'], 
      ['Sivel2Sjr', 'idioma'], ['Sivel2Gen', 'iglesia'],
      ['Sivel2Gen', 'maternidad'], ['Sivel2Gen', 'municipio'], 
      ['Sivel2Gen', 'pais'], ['Sivel2Gen', 'presponsable'], 
      ['Sivel2Gen', 'profesion'], 
      ['Sivel2Sjr', 'proteccion'], 
      ['Sivel2Gen', 'rangoedad'], ['Sivel2Gen', 'rangoedadac'], 
      ['Sivel2Gen', 'regionsjr'], ['Sivel2Sjr', 'rolfamilia'],
      ['Sivel2Sjr', 'statusmigratorio'], ['Sivel2Gen', 'supracategoria'], 
      ['Sivel2Gen', 'tclase'], ['Sivel2Gen', 'tdocumento'], 
      ['Sivel2Gen', 'tsitio'], ['Sivel2Gen', 'tviolencia']
#      ['', 'emprendimiento'],
#      ['', 'aspsicosocial'],  
    ]

    # Tablas basicas cuya secuencia es de la forma tabla_id_seq 
    @@basicas_seq_con_id = [
      ['Sivel2Gen', 'actividadarea'], ['Sivel2Sjr', 'comosupo'], 
      ['Sivel2Gen', 'pais'], ['Sivel2Gen', 'rangoedadac'], 
      ['Sivel2Gen', 'tdocumento'] 
    ]

    # Tablas básicas que deben volcarse primero --por ser requeridas por otras básicas
    @@tablasbasicas_prio = [
      ['Sivel2Gen', 'pconsolidado'], ['Sivel2Gen', 'tviolencia'], 
      ['Sivel2Gen', 'supracategoria'],
      ['Sivel2Gen', 'tclase'], ['Sivel2Gen', 'pais'], 
      ['Sivel2Gen', 'departamento'], ['Sivel2Gen', 'municipio'], 
      ['Sivel2Gen', 'clase'],
      ['Sivel2Gen', 'intervalo'], ['Sivel2Gen', 'filiacion'], 
      ['Sivel2Gen', 'organizacion'], ['Sivel2Gen', 'sectorsocial'],
      ['Sivel2Gen', 'vinculoestado'], ['Sivel2Sjr', 'regimensalud'],
      ['Sivel2Sjr', 'acreditacion'], ['Sivel2Sjr', 'clasifdesp'],
      ['Sivel2Sjr', 'declaroante'], ['Sivel2Sjr', 'inclusion'],
      ['Sivel2Sjr', 'modalidadtierra'], ['Sivel2Sjr', 'tipodesp'],
      ['Sivel2Sjr', 'personadesea'], ['Sivel2Sjr', 'ayudaestado'],
      ['Sivel2Sjr', 'derecho'], ['Sivel2Sjr', 'progestado'],
      ['Sivel2Sjr', 'motivosjr']
    ]


    ROLADMIN  = 1
    ROLINV    = 2
    ROLDIR    = 3
    ROLCOOR   = 4
    ROLANALI  = 5
    ROLSIST   = 6

    ROLES = [
      ["Administrador", ROLADMIN], 
      ["Invitado Nacional", ROLINV], 
      ["Director Nacional", ROLDIR], 
      ["Coordinador oficina", ROLCOOR], 
      ["Analista", ROLANALI], 
      ["Sistematizador", ROLSIST]
    ]


    # Ver documentacion de este metodo en app/models/ability de sivel2_gen
    def initialize(usuario)
      if !usuario || usuario.fechadeshabilitacion
        return
      end
      can :contar, Sivel2Gen::Caso
      can :buscar, Sivel2Gen::Caso
      can :lista, Sivel2Gen::Caso
      can :descarga_anexo, Sivel2Gen::Anexo
      can :descarga_anexoactividad, Sivel2Gen::Anexoactividad
      can :nuevo, Sivel2Sjr::Desplazamiento
      can :nuevo, Sivel2Sjr::Respuesta
      can :nuevo, Sivel2Gen::Ubicacion
      can :nuevo, Sivel2Gen::Presponsable
      can :nuevo, Sivel2Gen::Victima
      if !usuario.nil? && !usuario.rol.nil? then
        case usuario.rol 
        when Ability::ROLSIST
          can :read, Sivel2Gen::Caso, casosjr: { id_regionsjr: usuario.regionsjr_id }
          can [:update, :create, :destroy], Sivel2Gen::Caso, 
            casosjr: { asesor: usuario.id, id_regionsjr:usuario.regionsjr_id }
          can :read, Sivel2Gen::Actividad
          can :new, Sivel2Gen::Actividad
          can :new, Sivel2Gen::Caso 
          can [:update, :create, :destroy], Sivel2Gen::Actividad, 
            oficina: { id: usuario.regionsjr_id}
          can :manage, Sivel2Gen::Acto
        when Ability::ROLANALI
          can :read, Sivel2Gen::Caso
          can :new, Sivel2Gen::Caso
          can [:update, :create, :destroy], Sivel2Gen::Caso, 
            casosjr: { id_regionsjr: usuario.regionsjr_id }
          can :read, Sivel2Gen::Actividad
          can :new, Sivel2Gen::Actividad
          can [:update, :create, :destroy], Sivel2Gen::Actividad, 
            oficina: { id: usuario.regionsjr_id}
          can :manage, Sivel2Gen::Acto
        when Ability::ROLCOOR
          can :read, Sivel2Gen::Caso
          can :new, Sivel2Gen::Caso
          can [:update, :create, :destroy, :poneretcomp], Sivel2Gen::Caso, 
            casosjr: { id_regionsjr: usuario.regionsjr_id }
          can :read, Sivel2Gen::Actividad
          can :new, Sivel2Gen::Actividad
          can [:update, :create, :destroy], Sivel2Gen::Actividad, 
            oficina: { id: usuario.regionsjr_id}
          can :manage, Sivel2Gen::Acto
          can :new, Usuario
          can [:read, :manage], Usuario, regionsjr: { id: usuario.regionsjr_id}
        when Ability::ROLDIR
          can [:read, :new, :update, :create, :destroy, :ponetetcomp], Sivel2Gen::Caso
          can [:read, :new, :update, :create, :destroy], Sivel2Gen::Actividad
          can :manage, Sivel2Gen::Acto
          can :manage, Usuario
          can :manage, :tablasbasicas
          @@tablasbasicas.each do |t|
            c = Ability.tb_clase(t)
            can :manage, c
          end
        when Ability::ROLINV
          cannot :buscar, Sivel2Gen::Caso
          can :read, Sivel2Gen::Caso 
        when Ability::ROLADMIN
          can :manage, Sivel2Gen::Caso
          can :manage, Sivel2Gen::Actividad
          can :manage, Sivel2Gen::Acto
          can :manage, Usuario
          can :manage, :tablasbasicas
          @@tablasbasicas.each do |t|
            c = Ability.tb_clase(t)
            can :manage, c
          end
        end
      end
    end
  end
end
