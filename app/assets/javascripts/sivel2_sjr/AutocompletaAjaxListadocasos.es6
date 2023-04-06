export default class Sivel2SjrAutocompletaAjaxListadocasos {


  // Elije un caso en auto-completación
  static operarElegida (eorig, cadgrupo, id, otrosop) {
    let root = window
    msip_arregla_puntomontaje(root)
    if (typeof otrosop['data-idorig'] == 'undefined') {
      alert('Datos en formato no esperado');
      return;
    }
    const cs = otrosop['data-idorig'].split(';');
    const casoId = cs[0];
    let d = '&caso_id=' + casoId
    const a = root.puntomontaje + 'personas/datos'

    let pl = []
    let ini = 0
    for(i = 1; i<cs.length; i++) {
      const t = parseInt(cs[i])
      pl[i] = cadgrupo.substring(ini, ini + t)
      ini = ini + t + 1
    }
    // pl[2] cnom, pl[3] es cape, pl[4] es cdoc
    const divcp = eorig.target.closest('.' +
      Sivel2SjrAutocompletaAjaxListadocasos.claseEnvoltura);
    divcp.querySelector('[id$=casosjr_id]').value = casoId;
    divcp.querySelector('[id$=casosjr_id]').setAttribute('readonly', true); 
    divcp.querySelector('[id$=casosjr_id]').setAttribute('type', 'hidden');
    divcp.querySelector('[id$=casosjr_id]').parentElement.insertAdjacentHTML(
    'afterEnd', 
    "<a href='/casos/" + pl[1] + "' target=_blank>" + pl[1] + "</a>");
    divcp.querySelector('.nombres').innerText = pl[2];
    divcp.querySelector('.apellidos').innerText = pl[3];
    divcp.querySelector('.tipodocumento').innerText = pl[4];
    divcp.querySelector('.numerodocumento').innerText = pl[5];
    root.sivel2_sjr_autocompleta_contacto_actividad_divcp = divcp
    ruta = "api/sivel2sjr/poblacion_sexo_rangoedadac"
    msip_ajax_recibe_json(root, ruta,
      {caso_id: pl[1], fecha: $('#actividad_fecha_localizada').val() }, 
      sivel2_sjr_completa_rangosedadac)
    return
    window.Rails.ajax({
      type: 'GET',
      url: a,
      data: d,
      success: (resp, estado, xhr) => {
        const divcp = eorig.target.closest('.' + Cor1440GenAutocompletaAjaxAsistentes.claseEnvoltura)
        divcp.querySelector('[id$=_attributes_id]').value = resp.id
        divcp.querySelector('[id$=_attributes_nombres]').value = resp.nombres
        divcp.querySelector('[id$=_attributes_apellidos]').value = resp.apellidos
        divcp.querySelector('[id$=_attributes_sexo]').value = resp.sexo
        const tdocid = divcp.querySelector('[id$=_attributes_tdocumento_id]')
        if (tdocid != null) {
          let idop = null
          tdocid.childNodes.forEach((o) => {
            if (typeof (o.innerText) === 'string' &&
              o.innerText === resp.tdocumento) {
              idop = o.value
           }
          })
          if (idop != null) {
            tdocid.value = idop
          }
        }
        const numdoc = divcp.querySelector('[id$=_numerodocumento]')
        if (numdoc != null) {
          numdoc.value = resp.numerodocumento
        }
        const anionac = divcp.querySelector('[id$=_anionac]')
        if (anionac != null) {
          anionac.value = resp.anionac
        }
        const mesnac = divcp.querySelector('[id$=_mesnac]')
        if (mesnac != null) {
          mesnac.value = resp.mesnac
        }
        const dianac = divcp.querySelector('[id$=_dianac]')
        if (dianac != null) {
          dianac.value = resp.dianac
        }
        const cargo = divcp.querySelector('[id$=_cargo]')
        if (cargo != null) {
          cargo.value = resp.cargo
        }
        const correo = divcp.querySelector('[id$=_correo]')
        if (correo != null) {
          correo.value = resp.correo
        }
        eorig.target.setAttribute('data-autocompleta', 'no')
        eorig.target.removeAttribute('list')
        const sel = document.getElementById(
          Cor1440GenAutocompletaAjaxAsistentes.idDatalist)
        sel.innerHTML = ''
        // $(document).trigger('cor1440gen:autocompletado-asistente')
        document.dispatchEvent(new Event('cor1440gen:autocompletado-asistente'))
      },
      error: (resp, estado, xhr) => {
        window.alert('Error con ajax ' + resp)
      }
    })
  }

  static iniciar() {
    console.log("Sivel2SjrAutocompletaAjaxListadocasos")
      let url = '/casos/busca.json'
      var aeCasos = new window.AutocompletaAjaxExpreg(
          [ /^actividad_actividad_casosjr_attributes_[0-9]*_casosjr_id$/],
          url,
          Sivel2SjrAutocompletaAjaxListadocasos.idDatalist,
          Sivel2SjrAutocompletaAjaxListadocasos.operarElegida
          )
      aeCasos.iniciar()
  }

}


Sivel2SjrAutocompletaAjaxListadocasos.claseEnvoltura = 'nested-fields';
Sivel2SjrAutocompletaAjaxListadocasos.idDatalist = 'fuente-listadocasos';
