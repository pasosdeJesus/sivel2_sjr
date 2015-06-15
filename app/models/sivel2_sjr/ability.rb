# encoding: UTF-8

module Sivel2Sjr
  class Ability < Sivel2Gen::Ability
    # Tablas básicas
    @@tablasbasicas = Sivel2Gen::Ability::BASICAS + [
      ['Sivel2Sjr', 'aslegal'], 
      ['Sivel2Sjr', 'ayudasjr'], 
      ['Sivel2Sjr', 'comosupo'], 
      ['Sivel2Sjr', 'idioma'],
      ['Sivel2Sjr', 'proteccion'], 
      ['Sivel2Sjr', 'rolfamilia'],
      ['Sivel2Sjr', 'statusmigratorio'],
      ['Sivel2Sjr', 'tipodesp'],
    ]

    # Tablas basicas cuya secuencia es de la forma tabla_id_seq 
    @@basicas_seq_con_id = Sivel2Gen::Ability::BASICAS_SEQID + [
      ['Sivel2Sjr', 'comosupo'], 
    ]

    # Tablas básicas que deben volcarse primero --por ser requeridas por otras básicas
    @@tablasbasicas_prio = Sivel2Gen::Ability::BASICAS_PRIO + [
      ['Sivel2Sjr', 'regimensalud'],
      ['Sivel2Sjr', 'acreditacion'], 
      ['Sivel2Sjr', 'clasifdesp'],
      ['Sivel2Sjr', 'declaroante'], 
      ['Sivel2Sjr', 'inclusion'],
      ['Sivel2Sjr', 'modalidadtierra'], 
      ['Sivel2Sjr', 'tipodesp'],
      ['Sivel2Sjr', 'personadesea'], 
      ['Sivel2Sjr', 'ayudaestado'],
      ['Sivel2Sjr', 'derecho'], 
      ['Sivel2Sjr', 'progestado'],
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


    # Ver documentacion de este metodo en app/models/ability de sip
    def initialize(usuario)
      # Sin autenticación puede consultarse información geográfica 
      can :read, [Sip::Pais, Sip::Departamento, Sip::Municipio, Sip::Clase]
      if !usuario || usuario.fechadeshabilitacion
        return
      end
      can :contar, Sivel2Gen::Caso
      can :contar, Sip::Ubicacion
      can :buscar, Sivel2Gen::Caso
      can :lista, Sivel2Gen::Caso
      can :descarga_anexo, Sivel2Gen::Anexo
      #can :descarga_anexoactividad, Sivel2Gen::Anexoactividad
      can :nuevo, Sivel2Sjr::Desplazamiento
      can :nuevo, Sivel2Sjr::Respuesta
      can :nuevo, Sip::Ubicacion
      can :nuevo, Sivel2Gen::Presponsable
      can :nuevo, Sivel2Gen::Victima
      if !usuario.nil? && !usuario.rol.nil? then
        case usuario.rol 
        when Ability::ROLSIST
          can :read, Sivel2Gen::Caso, casosjr: { oficina_id: usuario.oficina_id }
          can [:update, :create, :destroy], Sivel2Gen::Caso, 
            casosjr: { asesor: usuario.id, oficina_id:usuario.oficina_id }
          can :read, Cor1440Gen::Actividad
          can :new, Cor1440Gen::Actividad
          can :new, Sivel2Gen::Caso 
          can [:update, :create, :destroy], Cor1440Gen::Actividad, 
            oficina: { id: usuario.oficina_id}
          can :manage, Sivel2Gen::Acto
          can :manage, Sip::Persona
        when Ability::ROLANALI
          can :read, Sivel2Gen::Caso
          can :new, Sivel2Gen::Caso
          can [:update, :create, :destroy], Sivel2Gen::Caso, 
            casosjr: { oficina_id: usuario.oficina_id }
          can :read, Cor1440Gen::Actividad
          can :new, Cor1440Gen::Actividad
          can [:update, :create, :destroy], Cor1440Gen::Actividad, 
            oficina: { id: usuario.oficina_id}
          can :manage, Sivel2Gen::Acto
          can :manage, Sip::Persona
        when Ability::ROLCOOR
          can :read, Sivel2Gen::Caso
          can :new, Sivel2Gen::Caso
          can [:update, :create, :destroy, :poneretcomp], Sivel2Gen::Caso, 
            casosjr: { oficina_id: usuario.oficina_id }
          can :read, Cor1440Gen::Actividad
          can :new, Cor1440Gen::Actividad
          can [:update, :create, :destroy], Cor1440Gen::Actividad, 
            oficina: { id: usuario.oficina_id}
          can :manage, Sivel2Gen::Acto
          can :manage, Sip::Persona
          can :new, Usuario
          can [:read, :manage], Usuario, oficina: { id: usuario.oficina_id}
        when Ability::ROLDIR
          can [:read, :new, :update, :create, :destroy, :ponetetcomp], Sivel2Gen::Caso
          can [:read, :new, :update, :create, :destroy], Cor1440Gen::Actividad
          can :manage, Sivel2Gen::Acto
          can :manage, Sip::Persona
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
          can :manage, Cor1440Gen::Actividad
          can :manage, Sivel2Gen::Acto
          can :manage, Sip::Persona
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
