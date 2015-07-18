# encoding: UTF-8

module Sivel2Sjr
  class Ability < Sivel2Gen::Ability
    # Tablas básicas
    BASICAS_PROPIAS = [
      ['Sivel2Sjr', 'aslegal'], 
      ['Sivel2Sjr', 'ayudasjr'], 
      ['Sivel2Sjr', 'comosupo'], 
      ['Sivel2Sjr', 'idioma'],
      ['Sivel2Sjr', 'proteccion'], 
      ['Sivel2Sjr', 'rolfamilia'],
      ['Sivel2Sjr', 'statusmigratorio'],
      ['Sivel2Sjr', 'tipodesp'],
    ]
    @@tablasbasicas = Sip::Ability::BASICAS_PROPIAS + 
      Sivel2Gen::Ability::BASICAS_PROPIAS + BASICAS_PROPIAS

    @@basicas_id_noauto = Sip::Ability::BASICAS_ID_NOAUTO +
      Sivel2Gen::Ability::BASICAS_ID_NOAUTO 

    @@nobasicas_indice_seq_con_id = Sip::Ability::NOBASICAS_INDSEQID +
      Sivel2Gen::Ability::NOBASICAS_INDSEQID 

    # Tablas básicas que deben volcarse primero --por ser requeridas por otras básicas
    BASICAS_PRIO = [
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
    @@tablasbasicas_prio = Sip::Ability::BASICAS_PRIO + BASICAS_PRIO

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
      can :descarga_anexo, Sip::Anexo
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
          can [:read, :new], Cor1440Gen::Actividad
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
          can :read, Cor1440Gen::Informe
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
          can :manage, Cor1440Gen::Informe
          can :read, Cor1440Gen::Actividad
          can :new, Cor1440Gen::Actividad
          can [:update, :create, :destroy], Cor1440Gen::Actividad, 
            oficina: { id: usuario.oficina_id}
          can :manage, Sivel2Gen::Acto
          can :manage, Sip::Persona
          can :new, Usuario
          can [:read, :manage], Usuario, oficina: { id: usuario.oficina_id}
        when Ability::ROLINV
          cannot :buscar, Sivel2Gen::Caso
          can :read, Sivel2Gen::Caso 
        when Ability::ROLADMIN, Ability::ROLDIR
          can :manage, Sivel2Gen::Caso
          can :manage, Cor1440Gen::Actividad
          can :manage, Cor1440Gen::Informe
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
