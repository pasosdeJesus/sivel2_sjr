# encoding: UTF-8
class Ability  < Sivel2Sjr::Ability

  # Autorizaciones con CanCanCan
  def initialize(usuario = nil)
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
        tablasbasicas.each do |t|
          c = Ability.tb_clase(t)
          can :manage, c
        end
      end
    end
  end

end

