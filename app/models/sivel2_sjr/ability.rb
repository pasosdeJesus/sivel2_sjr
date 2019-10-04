# encoding: UTF-8

module Sivel2Sjr
  class Ability < Sivel2Gen::Ability

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
      ["Sistematizador", ROLSIST],
    ]

    # Tablas básicas propias
    BASICAS_PROPIAS = [
      ['Sivel2Sjr', 'acreditacion'], 
      ['Sivel2Sjr', 'aslegal'], 
      ['Sivel2Sjr', 'aspsicosocial'], 
      ['Sivel2Sjr', 'ayudaestado'], 
      ['Sivel2Sjr', 'ayudasjr'], 
      ['Sivel2Sjr', 'clasifdesp'], 
      ['Sivel2Sjr', 'comosupo'], 
      ['Sivel2Sjr', 'declaroante'],
      ['Sivel2Sjr', 'derecho'],
      ['Sivel2Sjr', 'idioma'],
      ['Sivel2Sjr', 'inclusion'],
      ['Sivel2Sjr', 'modalidadtierra'],
      ['Sivel2Sjr', 'personadesea'],
      ['Sivel2Sjr', 'proteccion'],
      ['Sivel2Sjr', 'progestado'],
      ['Sivel2Sjr', 'rolfamilia'],
      ['Sivel2Sjr', 'statusmigratorio'],
      ['Sivel2Sjr', 'tipodesp'],
    ]
    def tablasbasicas 
      Sip::Ability::BASICAS_PROPIAS + 
        Cor1440Gen::Ability::BASICAS_PROPIAS +
        Sivel2Gen::Ability::BASICAS_PROPIAS + BASICAS_PROPIAS - [
          ['Sip', 'fuenteprensa'],
          ['Sip', 'grupo'],
          ['Sivel2Gen', 'filiacion'],
          ['Sivel2Gen', 'frontera'],
          ['Sivel2Gen', 'intervalo'],
          ['Sivel2Gen', 'organizacion'],
          ['Sivel2Gen', 'region'],
          ['Sivel2Gen', 'sectorsocial'],
          ['Sivel2Gen', 'vinculoestado']
        ]
    end

    BASICAS_ID_NOAUTO = []
    def basicas_id_noauto 
      Sip::Ability::BASICAS_ID_NOAUTO +
        Sivel2Gen::Ability::BASICAS_ID_NOAUTO 
    end

    NOBASICAS_INDSEQID =  []
    def nobasicas_indice_seq_con_id 
      Sip::Ability::NOBASICAS_INDSEQID +
        Sivel2Gen::Ability::NOBASICAS_INDSEQID 
    end

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
    def tablasbasicas_prio 
      Sip::Ability::BASICAS_PRIO + BASICAS_PRIO
    end


    CAMPOS_PLANTILLAS_PROPIAS = {
      'Caso' => {
        campos: [
          :caso_id,
          :contacto,
          :fecharec,
          :oficina,
          :nusuario,
          :fecha,
          :statusmigratorio,
          :ultimaatencion_fecha,
          :memo,
          :victimas
        ],
        controlador: 'Sivel2Gen::CasosController',
        ruta: '/casos'
      }
    }

    def campos_plantillas 
      Heb412Gen::Ability::CAMPOS_PLANTILLAS_PROPIAS.
        clone.merge(Cor1440Gen::Ability::CAMPOS_PLANTILLAS_PROPIAS.clone.merge(
          Sivel2Gen::Ability::CAMPOS_PLANTILLAS_PROPIAS.clone.merge(
            Sivel2Sjr::Ability::CAMPOS_PLANTILLAS_PROPIAS.clone)
      ))
    end

  end
end
