# encoding: UTF-8
class Ability  < Sivel2Sjr::Ability

  def tablasbasicas
    return super()
#   -[
#      ['Sivel2Sjr', 'acreditacion'],
#      ['Sivel2Sjr', 'ayudaestado'],
#      ['Sivel2Sjr', 'clasifdesp'],
#      ['Sivel2Sjr', 'declaroante'],
#      ['Sivel2Sjr', 'inclusion'],
#      ['Sivel2Sjr', 'modalidadtierra'],
#      ['Sivel2Sjr', 'personadesea'],
#      ['Sivel2Sjr', 'progestado'],
#      ['Sivel2Sjr', 'tipodesp']
#    ]
  end
  # Autorizaciones con CanCanCan
  def initialize(usuario = nil)
    # Sin autenticación puede consultarse información geográfica 
    can :read, [Sip::Pais, Sip::Departamento, Sip::Municipio, Sip::Clase]
    if !usuario || usuario.fechadeshabilitacion
      return
    end
    can :read, Heb412Gen::Plantillahcm
    can :read, Heb412Gen::Plantillahcr
    can :read, Heb412Gen::Plantilladoc

    can :descarga_anexo, Sip::Anexo
    can :contar, Sip::Ubicacion
    can :nuevo, Sip::Ubicacion

    can :contar, Sivel2Gen::Caso
    can :buscar, Sivel2Gen::Caso
    can :lista, Sivel2Gen::Caso
    can :nuevo, Sivel2Gen::Presponsable
    can :nuevo, Sivel2Gen::Victima

    can :nuevo, Sivel2Sjr::Desplazamiento
    can :nuevo, Sivel2Sjr::Respuesta

    if !usuario.nil? && !usuario.rol.nil? then
      case usuario.rol 
      when Ability::ROLINV
        cannot :buscar, Sivel2Gen::Caso
        can :read, Sivel2Gen::Caso 

      when Ability::ROLSIST
        can [:update, :create, :destroy], Cor1440Gen::Actividad, 
          oficina: { id: usuario.oficina_id}
        can [:read, :new], Cor1440Gen::Actividad
        can [:index, :read], Cor1440Gen::Proyectofinanciero

        can :manage, Sivel2Gen::Acto

        can :read, Sivel2Gen::Caso, 
          casosjr: { oficina_id: usuario.oficina_id }
        can [:update, :create, :destroy], Sivel2Gen::Caso, 
          casosjr: { asesor: usuario.id, oficina_id:usuario.oficina_id }
        can :new, Sivel2Gen::Caso 

        can [:new, :read, :edit, :update, :create], 
          Sip::Actorsocial
        can :manage, Sip::Persona

      when Ability::ROLANALI
        can :read, Cor1440Gen::Actividad
        can :new, Cor1440Gen::Actividad
        can [:update, :create, :destroy], Cor1440Gen::Actividad, 
          oficina: { id: usuario.oficina_id}
        can :read, Cor1440Gen::Informe
        can [:index, :read], Cor1440Gen::Proyectofinanciero

        can :manage, Sivel2Gen::Acto

        can :read, Sivel2Gen::Caso
        can :new, Sivel2Gen::Caso
        can [:update, :create, :destroy], Sivel2Gen::Caso, 
          casosjr: { oficina_id: usuario.oficina_id }
        
        can [:new, :read, :edit, :update, :create], 
          Sip::Actorsocial
        can :manage, Sip::Persona

      when Ability::ROLCOOR
        can [:read, :manage], Usuario, oficina: { id: usuario.oficina_id}

        can :manage, Cor1440Gen::Informe
        can :read, Cor1440Gen::Actividad
        can :new, Cor1440Gen::Actividad
        can [:index, :read], Cor1440Gen::Proyectofinanciero
        can [:update, :create, :destroy], Cor1440Gen::Actividad, 
          oficina: { id: usuario.oficina_id}
        
        can :manage, Sivel2Gen::Acto

        can :read, Sivel2Gen::Caso
        can :new, Sivel2Gen::Caso
        can [:update, :create, :destroy, :poneretcomp], Sivel2Gen::Caso, 
          casosjr: { oficina_id: usuario.oficina_id }

        can :manage, Sip::Actorsocial
        can :manage, Sip::Persona

      when Ability::ROLADMIN, Ability::ROLDIR
        can :manage, ::Usuario

        can :manage, Cor1440Gen::Actividad
        can :manage, Cor1440Gen::Informe
        can :manage, Cor1440Gen::Proyectofinanciero

        can :manage, Heb412Gen::Plantillahcm
        can :manage, Heb412Gen::Plantillahcr
        can :manage, Heb412Gen::Plantilladoc

        can :manage, Sip::Actorsocial
        can :manage, Sip::Persona

        can :manage, Sivel2Gen::Acto
        can :manage, Sivel2Gen::Caso
        can :manage, :tablasbasicas
        tablasbasicas.each do |t|
          c = Ability.tb_clase(t)
          can :manage, c
        end
      end
    end
  end

end

