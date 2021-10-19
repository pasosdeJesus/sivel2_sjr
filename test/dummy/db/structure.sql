SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: es_co_utf_8; Type: COLLATION; Schema: public; Owner: -
--

CREATE COLLATION public.es_co_utf_8 (provider = libc, locale = 'es_CO.UTF-8');


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: completa_obs(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.completa_obs(obs character varying, nuevaobs character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
      BEGIN
        RETURN CASE WHEN obs IS NULL THEN nuevaobs
          WHEN obs='' THEN nuevaobs
          WHEN RIGHT(obs, 1)='.' THEN obs || ' ' || nuevaobs
          ELSE obs || '. ' || nuevaobs
        END;
      END; $$;


--
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
      SELECT public.unaccent('public.unaccent', $1)  
      $_$;


--
-- Name: sip_edad_de_fechanac_fecharef(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sip_edad_de_fechanac_fecharef(anionac integer, mesnac integer, dianac integer, anioref integer, mesref integer, diaref integer) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$
        SELECT CASE 
          WHEN anionac IS NULL THEN NULL
          WHEN anioref IS NULL THEN NULL
          WHEN mesnac IS NULL OR dianac IS NULL OR mesref IS NULL OR diaref IS NULL THEN 
            anioref-anionac 
          WHEN mesnac < mesref THEN
            anioref-anionac
          WHEN mesnac > mesref THEN
            anioref-anionac-1
          WHEN dianac > diaref THEN
            anioref-anionac-1
          ELSE 
            anioref-anionac
        END 
      $$;


--
-- Name: sivel2_gen_polo_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sivel2_gen_polo_id(presponsable_id integer) RETURNS integer
    LANGUAGE sql
    AS $$
        WITH RECURSIVE des AS (
          SELECT id, nombre, papa_id 
          FROM sivel2_gen_presponsable WHERE id=presponsable_id 
          UNION SELECT e.id, e.nombre, e.papa_id 
          FROM sivel2_gen_presponsable e INNER JOIN des d ON d.papa_id=e.id) 
        SELECT id FROM des WHERE papa_id IS NULL;
      $$;


--
-- Name: sivel2_gen_polo_nombre(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sivel2_gen_polo_nombre(presponsable_id integer) RETURNS character varying
    LANGUAGE sql
    AS $$
        SELECT CASE 
          WHEN fechadeshabilitacion IS NULL THEN nombre
          ELSE nombre || '(DESHABILITADO)' 
        END 
        FROM sivel2_gen_presponsable 
        WHERE id=sivel2_gen_polo_id(presponsable_id)
      $$;


--
-- Name: soundexesp(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexesp(input text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
DECLARE
	soundex text='';	
	-- para determinar la primera letra
	pri_letra text;
	resto text;
	sustituida text ='';
	-- para quitar adyacentes
	anterior text;
	actual text;
	corregido text;
BEGIN
       -- devolver null si recibi un string en blanco o con espacios en blanco
	IF length(trim(input))= 0 then
		RETURN NULL;
	end IF;
 
 
	-- 1: LIMPIEZA:
		-- pasar a mayuscula, eliminar la letra "H" inicial, los acentos y la enie
		-- 'holá coñó' => 'OLA CONO'
		input=translate(ltrim(trim(upper(input)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU');
 
		-- eliminar caracteres no alfabéticos (números, símbolos como &,%,",*,!,+, etc.
		input=regexp_replace(input, '[^a-zA-Z]', '', 'g');
 
	-- 2: PRIMERA LETRA ES IMPORTANTE, DEBO ASOCIAR LAS SIMILARES
	--  'vaca' se convierte en 'baca'  y 'zapote' se convierte en 'sapote'
	-- un fenomeno importante es GE y GI se vuelven JE y JI; CA se vuelve KA, etc
	pri_letra =substr(input,1,1);
	resto =substr(input,2);
	CASE 
		when pri_letra IN ('V') then
			sustituida='B';
		when pri_letra IN ('Z','X') then
			sustituida='S';
		when pri_letra IN ('G') AND substr(input,2,1) IN ('E','I') then
			sustituida='J';
		when pri_letra IN('C') AND substr(input,2,1) NOT IN ('H','E','I') then
			sustituida='K';
		else
			sustituida=pri_letra;
 
	end case;
	--corregir el parametro con las consonantes sustituidas:
	input=sustituida || resto;		
 
	-- 3: corregir "letras compuestas" y volverlas una sola
	input=REPLACE(input,'CH','V');
	input=REPLACE(input,'QU','K');
	input=REPLACE(input,'LL','J');
	input=REPLACE(input,'CE','S');
	input=REPLACE(input,'CI','S');
	input=REPLACE(input,'YA','J');
	input=REPLACE(input,'YE','J');
	input=REPLACE(input,'YI','J');
	input=REPLACE(input,'YO','J');
	input=REPLACE(input,'YU','J');
	input=REPLACE(input,'GE','J');
	input=REPLACE(input,'GI','J');
	input=REPLACE(input,'NY','N');
	-- para debug:    --return input;
 
	-- EMPIEZA EL CALCULO DEL SOUNDEX
	-- 4: OBTENER PRIMERA letra
	pri_letra=substr(input,1,1);
 
	-- 5: retener el resto del string
	resto=substr(input,2);
 
	--6: en el resto del string, quitar vocales y vocales fonéticas
	resto=translate(resto,'@AEIOUHWY','@');
 
	--7: convertir las letras foneticamente equivalentes a numeros  (esto hace que B sea equivalente a V, C con S y Z, etc.)
	resto=translate(resto, 'BPFVCGKSXZDTLMNRQJ', '111122222233455677');
	-- así va quedando la cosa
	soundex=pri_letra || resto;
 
	--8: eliminar números iguales adyacentes (A11233 se vuelve A123)
	anterior=substr(soundex,1,1);
	corregido=anterior;
 
	FOR i IN 2 .. length(soundex) LOOP
		actual = substr(soundex, i, 1);
		IF actual <> anterior THEN
			corregido=corregido || actual;
			anterior=actual;			
		END IF;
	END LOOP;
	-- así va la cosa
	soundex=corregido;
 
	-- 9: siempre retornar un string de 4 posiciones
	soundex=rpad(soundex,4,'0');
	soundex=substr(soundex,1,4);		
 
	-- YA ESTUVO
	RETURN soundex;	
END;	
$$;


--
-- Name: acto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.acto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anexo_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anexo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: caso_etiqueta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.caso_etiqueta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: caso_presponsable_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.caso_presponsable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso (
    id integer DEFAULT nextval('public.sivel2_gen_caso_id_seq'::regclass) NOT NULL,
    titulo character varying(50),
    fecha date NOT NULL,
    hora character varying(10),
    duracion character varying(10),
    memo text NOT NULL,
    grconfiabilidad character varying(5),
    gresclarecimiento character varying(5),
    grimpunidad character varying(8),
    grinformacion character varying(8),
    bienes text,
    id_intervalo integer DEFAULT 5,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ubicacion_id integer
);


--
-- Name: victima_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.victima_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_victima (
    id_persona integer NOT NULL,
    id_caso integer NOT NULL,
    hijos integer,
    id_profesion integer DEFAULT 22 NOT NULL,
    id_rangoedad integer DEFAULT 6 NOT NULL,
    id_filiacion integer DEFAULT 10 NOT NULL,
    id_sectorsocial integer DEFAULT 15 NOT NULL,
    id_organizacion integer DEFAULT 16 NOT NULL,
    id_vinculoestado integer DEFAULT 38 NOT NULL,
    organizacionarmada integer DEFAULT 35 NOT NULL,
    anotaciones character varying(1000),
    id_etnia integer DEFAULT 1 NOT NULL,
    id_iglesia integer DEFAULT 1,
    orientacionsexual character(1) DEFAULT 'S'::bpchar NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.victima_seq'::regclass) NOT NULL,
    CONSTRAINT victima_hijos_check CHECK (((hijos IS NULL) OR ((hijos >= 0) AND (hijos <= 100)))),
    CONSTRAINT victima_orientacionsexual_check CHECK (((orientacionsexual = 'L'::bpchar) OR (orientacionsexual = 'G'::bpchar) OR (orientacionsexual = 'B'::bpchar) OR (orientacionsexual = 'T'::bpchar) OR (orientacionsexual = 'O'::bpchar) OR (orientacionsexual = 'H'::bpchar) OR (orientacionsexual = 'S'::bpchar)))
);


--
-- Name: sivel2_sjr_casosjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_casosjr (
    id_caso integer NOT NULL,
    fecharec date NOT NULL,
    asesor integer NOT NULL,
    oficina_id integer DEFAULT 1,
    direccion character varying(1000),
    telefono character varying(1000),
    contacto_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    dependen integer,
    sustento character varying(1000),
    leerescribir boolean,
    trabaja boolean,
    ingresomensual integer,
    gastos integer,
    estrato character(1),
    id_statusmigratorio integer DEFAULT 0,
    id_proteccion integer DEFAULT 0,
    id_idioma integer DEFAULT 0,
    concentimientosjr boolean,
    concentimientobd boolean,
    fechasalida date,
    id_salida integer,
    fechallegada date,
    id_llegada integer,
    categoriaref integer,
    observacionesref character varying(5000),
    comosupo_id integer DEFAULT 1
);


--
-- Name: cben1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cben1 AS
 SELECT caso.id AS id_caso,
    victima.id_persona,
        CASE
            WHEN (casosjr.contacto_id = victima.id_persona) THEN 1
            ELSE 0
        END AS contacto,
        CASE
            WHEN (casosjr.contacto_id <> victima.id_persona) THEN 1
            ELSE 0
        END AS beneficiario,
    1 AS npersona,
    'total'::text AS total
   FROM public.sivel2_gen_caso caso,
    public.sivel2_sjr_casosjr casosjr,
    public.sivel2_gen_victima victima
  WHERE ((caso.id = victima.id_caso) AND (caso.id = casosjr.id_caso) AND (caso.id = victima.id_caso));


--
-- Name: desplazamiento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.desplazamiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_clase_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_clase_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_clase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_clase (
    id_clalocal integer,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    id_tclase character varying(10) DEFAULT 'CP'::character varying NOT NULL,
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_municipio integer,
    id integer DEFAULT nextval('public.sip_clase_id_seq'::regclass) NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT clase_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_departamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_departamento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_departamento (
    id_deplocal integer,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer DEFAULT 0 NOT NULL,
    id integer DEFAULT nextval('public.sip_departamento_id_seq'::regclass) NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT departamento_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_municipio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_municipio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_municipio (
    id_munlocal integer,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_departamento integer,
    id integer DEFAULT nextval('public.sip_municipio_id_seq'::regclass) NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT municipio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_ubicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_ubicacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_ubicacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_ubicacion (
    id integer DEFAULT nextval('public.sip_ubicacion_id_seq'::regclass) NOT NULL,
    lugar character varying(500) COLLATE public.es_co_utf_8,
    sitio character varying(500) COLLATE public.es_co_utf_8,
    id_tsitio integer DEFAULT 1 NOT NULL,
    id_caso integer NOT NULL,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer DEFAULT 0,
    id_departamento integer,
    id_municipio integer,
    id_clase integer
);


--
-- Name: sivel2_sjr_desplazamiento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_desplazamiento (
    id_caso integer NOT NULL,
    fechaexpulsion date NOT NULL,
    id_expulsion integer NOT NULL,
    fechallegada date NOT NULL,
    id_llegada integer NOT NULL,
    id_clasifdesp integer DEFAULT 0 NOT NULL,
    id_tipodesp integer DEFAULT 0 NOT NULL,
    descripcion character varying(5000),
    otrosdatos character varying(1000),
    declaro character(1),
    hechosdeclarados character varying(5000),
    fechadeclaracion date,
    departamentodecl integer,
    municipiodecl integer,
    id_declaroante integer DEFAULT 0,
    id_inclusion integer DEFAULT 0,
    id_acreditacion integer DEFAULT 0,
    retornado boolean,
    reubicado boolean,
    connacionalretorno boolean,
    acompestado boolean,
    connacionaldeportado boolean,
    oficioantes character varying(5000),
    id_modalidadtierra integer DEFAULT 0,
    materialesperdidos character varying(5000),
    inmaterialesperdidos character varying(5000),
    protegiorupta boolean,
    documentostierra character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    paisdecl integer,
    id integer DEFAULT nextval('public.desplazamiento_seq'::regclass) NOT NULL,
    CONSTRAINT desplazamiento_declaro_check CHECK (((declaro = 'S'::bpchar) OR (declaro = 'N'::bpchar) OR (declaro = 'R'::bpchar)))
);


--
-- Name: ultimodesplazamiento; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ultimodesplazamiento AS
 SELECT sivel2_sjr_desplazamiento.id,
    s.id_caso,
    s.fechaexpulsion,
    sivel2_sjr_desplazamiento.id_expulsion
   FROM public.sivel2_sjr_desplazamiento,
    ( SELECT sivel2_sjr_desplazamiento_1.id_caso,
            max(sivel2_sjr_desplazamiento_1.fechaexpulsion) AS fechaexpulsion
           FROM public.sivel2_sjr_desplazamiento sivel2_sjr_desplazamiento_1
          GROUP BY sivel2_sjr_desplazamiento_1.id_caso) s
  WHERE ((sivel2_sjr_desplazamiento.id_caso = s.id_caso) AND (sivel2_sjr_desplazamiento.fechaexpulsion = s.fechaexpulsion));


--
-- Name: cben2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cben2 AS
 SELECT cben1.id_caso,
    cben1.id_persona,
    cben1.contacto,
    cben1.beneficiario,
    cben1.npersona,
    cben1.total,
    ubicacion.id_departamento,
    departamento.nombre AS departamento_nombre,
    ubicacion.id_municipio,
    municipio.nombre AS municipio_nombre,
    ubicacion.id_clase,
    clase.nombre AS clase_nombre,
    ultimodesplazamiento.fechaexpulsion
   FROM (((((public.cben1
     LEFT JOIN public.ultimodesplazamiento ON ((cben1.id_caso = ultimodesplazamiento.id_caso)))
     LEFT JOIN public.sip_ubicacion ubicacion ON ((ultimodesplazamiento.id_expulsion = ubicacion.id)))
     LEFT JOIN public.sip_departamento departamento ON ((ubicacion.id_departamento = departamento.id)))
     LEFT JOIN public.sip_municipio municipio ON ((ubicacion.id_municipio = municipio.id)))
     LEFT JOIN public.sip_clase clase ON ((ubicacion.id_clase = clase.id)));


--
-- Name: cor1440_gen_actividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad (
    id integer NOT NULL,
    minutos integer,
    nombre character varying(500),
    objetivo character varying(5000),
    resultado character varying(5000),
    fecha date NOT NULL,
    observaciones character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    oficina_id integer NOT NULL,
    rangoedadac_id integer,
    usuario_id integer NOT NULL,
    lugar character varying(500)
);


--
-- Name: cor1440_gen_actividad_actividadpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_actividadpf (
    actividad_id bigint NOT NULL,
    actividadpf_id bigint NOT NULL
);


--
-- Name: cor1440_gen_actividad_actividadtipo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_actividadtipo (
    actividad_id integer,
    actividadtipo_id integer
);


--
-- Name: cor1440_gen_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividad_id_seq OWNED BY public.cor1440_gen_actividad.id;


--
-- Name: cor1440_gen_actividad_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_orgsocial (
    actividad_id bigint NOT NULL,
    orgsocial_id bigint NOT NULL
);


--
-- Name: cor1440_gen_actividad_proyecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_proyecto (
    id integer NOT NULL,
    actividad_id integer,
    proyecto_id integer
);


--
-- Name: cor1440_gen_actividad_proyecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_proyecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_proyecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividad_proyecto_id_seq OWNED BY public.cor1440_gen_actividad_proyecto.id;


--
-- Name: cor1440_gen_actividad_proyectofinanciero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_proyectofinanciero_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_proyectofinanciero (
    actividad_id integer NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    id integer DEFAULT nextval('public.cor1440_gen_actividad_proyectofinanciero_id_seq'::regclass) NOT NULL
);


--
-- Name: cor1440_gen_actividad_rangoedadac; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_rangoedadac (
    id integer NOT NULL,
    actividad_id integer,
    rangoedadac_id integer,
    ml integer,
    mr integer,
    fl integer,
    fr integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    s integer
);


--
-- Name: cor1440_gen_actividad_rangoedadac_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_rangoedadac_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_rangoedadac_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividad_rangoedadac_id_seq OWNED BY public.cor1440_gen_actividad_rangoedadac.id;


--
-- Name: cor1440_gen_actividad_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_respuestafor (
    actividad_id integer NOT NULL,
    respuestafor_id integer NOT NULL
);


--
-- Name: cor1440_gen_actividad_sip_anexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_sip_anexo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_sip_anexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_sip_anexo (
    actividad_id integer NOT NULL,
    anexo_id integer NOT NULL,
    id integer DEFAULT nextval('public.cor1440_gen_actividad_sip_anexo_id_seq'::regclass) NOT NULL
);


--
-- Name: cor1440_gen_actividad_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_usuario (
    actividad_id integer NOT NULL,
    usuario_id integer NOT NULL
);


--
-- Name: cor1440_gen_actividad_valorcampotind; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_valorcampotind (
    id bigint NOT NULL,
    actividad_id integer,
    valorcampotind_id integer
);


--
-- Name: cor1440_gen_actividad_valorcampotind_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_valorcampotind_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_valorcampotind_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividad_valorcampotind_id_seq OWNED BY public.cor1440_gen_actividad_valorcampotind.id;


--
-- Name: cor1440_gen_actividadarea; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadarea (
    id integer NOT NULL,
    nombre character varying(500),
    observaciones character varying(5000),
    fechacreacion date DEFAULT ('now'::text)::date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cor1440_gen_actividadarea_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividadarea_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividadarea_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividadarea_id_seq OWNED BY public.cor1440_gen_actividadarea.id;


--
-- Name: cor1440_gen_actividadareas_actividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadareas_actividad (
    id integer NOT NULL,
    actividad_id integer,
    actividadarea_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cor1440_gen_actividadareas_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividadareas_actividad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividadareas_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividadareas_actividad_id_seq OWNED BY public.cor1440_gen_actividadareas_actividad.id;


--
-- Name: cor1440_gen_actividadpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadpf (
    id integer NOT NULL,
    proyectofinanciero_id integer,
    nombrecorto character varying(15),
    titulo character varying(255),
    descripcion character varying(5000),
    resultadopf_id integer,
    actividadtipo_id integer,
    formulario_id integer,
    heredade_id integer
);


--
-- Name: cor1440_gen_actividadpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividadpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividadpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividadpf_id_seq OWNED BY public.cor1440_gen_actividadpf.id;


--
-- Name: cor1440_gen_actividadpf_mindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadpf_mindicadorpf (
    actividadpf_id integer,
    mindicadorpf_id integer
);


--
-- Name: cor1440_gen_actividadtipo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadtipo (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    listadoasistencia boolean
);


--
-- Name: cor1440_gen_actividadtipo_formulario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadtipo_formulario (
    actividadtipo_id integer NOT NULL,
    formulario_id integer NOT NULL
);


--
-- Name: cor1440_gen_actividadtipo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividadtipo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividadtipo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividadtipo_id_seq OWNED BY public.cor1440_gen_actividadtipo.id;


--
-- Name: cor1440_gen_anexo_efecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_anexo_efecto (
    id bigint NOT NULL,
    efecto_id integer,
    anexo_id integer
);


--
-- Name: cor1440_gen_anexo_efecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_anexo_efecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_anexo_efecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_anexo_efecto_id_seq OWNED BY public.cor1440_gen_anexo_efecto.id;


--
-- Name: cor1440_gen_anexo_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_anexo_proyectofinanciero (
    id bigint NOT NULL,
    anexo_id integer,
    proyectofinanciero_id integer
);


--
-- Name: cor1440_gen_anexo_proyectofinanciero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_anexo_proyectofinanciero_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_anexo_proyectofinanciero_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_anexo_proyectofinanciero_id_seq OWNED BY public.cor1440_gen_anexo_proyectofinanciero.id;


--
-- Name: cor1440_gen_asistencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_asistencia (
    id bigint NOT NULL,
    actividad_id integer NOT NULL,
    persona_id integer NOT NULL,
    rangoedadac_id integer,
    externo boolean,
    orgsocial_id integer,
    perfilorgsocial_id integer
);


--
-- Name: cor1440_gen_asistencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_asistencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_asistencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_asistencia_id_seq OWNED BY public.cor1440_gen_asistencia.id;


--
-- Name: cor1440_gen_beneficiariopf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_beneficiariopf (
    persona_id integer,
    proyectofinanciero_id integer
);


--
-- Name: cor1440_gen_campoact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_campoact (
    id bigint NOT NULL,
    actividadtipo_id integer,
    nombrecampo character varying(128),
    ayudauso character varying(1024),
    tipo integer DEFAULT 1
);


--
-- Name: cor1440_gen_campoact_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_campoact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_campoact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_campoact_id_seq OWNED BY public.cor1440_gen_campoact.id;


--
-- Name: cor1440_gen_campotind; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_campotind (
    id bigint NOT NULL,
    tipoindicador_id integer NOT NULL,
    nombrecampo character varying(128) NOT NULL,
    ayudauso character varying(1024),
    tipo integer DEFAULT 1
);


--
-- Name: cor1440_gen_campotind_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_campotind_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_campotind_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_campotind_id_seq OWNED BY public.cor1440_gen_campotind.id;


--
-- Name: cor1440_gen_caracterizacionpersona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_caracterizacionpersona (
    id bigint NOT NULL,
    persona_id integer NOT NULL,
    respuestafor_id integer NOT NULL,
    ulteditor_id integer NOT NULL
);


--
-- Name: cor1440_gen_caracterizacionpersona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_caracterizacionpersona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_caracterizacionpersona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_caracterizacionpersona_id_seq OWNED BY public.cor1440_gen_caracterizacionpersona.id;


--
-- Name: cor1440_gen_caracterizacionpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_caracterizacionpf (
    formulario_id integer,
    proyectofinanciero_id integer
);


--
-- Name: cor1440_gen_datointermedioti; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_datointermedioti (
    id bigint NOT NULL,
    nombre character varying(1024) NOT NULL,
    tipoindicador_id integer,
    nombreinterno character varying(127),
    filtro character varying(5000),
    funcion character varying(5000),
    mindicadorpf_id integer
);


--
-- Name: cor1440_gen_datointermedioti_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_datointermedioti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_datointermedioti_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_datointermedioti_id_seq OWNED BY public.cor1440_gen_datointermedioti.id;


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_datointermedioti_pmindicadorpf (
    id bigint NOT NULL,
    datointermedioti_id integer NOT NULL,
    pmindicadorpf_id integer NOT NULL,
    valor double precision,
    rutaevidencia character varying(5000)
);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_datointermedioti_pmindicadorpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_datointermedioti_pmindicadorpf_id_seq OWNED BY public.cor1440_gen_datointermedioti_pmindicadorpf.id;


--
-- Name: cor1440_gen_desembolso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_desembolso (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    detalle character varying(5000),
    fecha date,
    valorpesos numeric(20,2),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_desembolso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_desembolso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_desembolso_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_desembolso_id_seq OWNED BY public.cor1440_gen_desembolso.id;


--
-- Name: cor1440_gen_efecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_efecto (
    id bigint NOT NULL,
    indicadorpf_id integer,
    fecha date,
    registradopor_id integer,
    nombre character varying(500),
    descripcion character varying(5000)
);


--
-- Name: cor1440_gen_efecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_efecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_efecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_efecto_id_seq OWNED BY public.cor1440_gen_efecto.id;


--
-- Name: cor1440_gen_efecto_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_efecto_orgsocial (
    efecto_id integer,
    orgsocial_id integer
);


--
-- Name: cor1440_gen_efecto_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_efecto_respuestafor (
    efecto_id integer,
    respuestafor_id integer
);


--
-- Name: cor1440_gen_financiador; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_financiador (
    id integer NOT NULL,
    nombre character varying(1000),
    observaciones character varying(5000),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cor1440_gen_financiador_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_financiador_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_financiador_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_financiador_id_seq OWNED BY public.cor1440_gen_financiador.id;


--
-- Name: cor1440_gen_financiador_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_financiador_proyectofinanciero (
    financiador_id integer NOT NULL,
    proyectofinanciero_id integer NOT NULL
);


--
-- Name: cor1440_gen_formulario_mindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_formulario_mindicadorpf (
    formulario_id bigint NOT NULL,
    mindicadorpf_id bigint NOT NULL
);


--
-- Name: cor1440_gen_formulario_tipoindicador; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_formulario_tipoindicador (
    tipoindicador_id integer NOT NULL,
    formulario_id integer NOT NULL
);


--
-- Name: cor1440_gen_indicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_indicadorpf (
    id bigint NOT NULL,
    proyectofinanciero_id integer,
    resultadopf_id integer,
    numero character varying(15) NOT NULL,
    indicador character varying(5000) NOT NULL,
    tipoindicador_id integer,
    objetivopf_id integer
);


--
-- Name: cor1440_gen_indicadorpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_indicadorpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_indicadorpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_indicadorpf_id_seq OWNED BY public.cor1440_gen_indicadorpf.id;


--
-- Name: cor1440_gen_informe; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_informe (
    id integer NOT NULL,
    titulo character varying(500) NOT NULL,
    filtrofechaini date NOT NULL,
    filtrofechafin date NOT NULL,
    filtroproyecto integer,
    filtroactividadarea integer,
    columnanombre boolean,
    columnatipo boolean,
    columnaobjetivo boolean,
    columnaproyecto boolean,
    columnapoblacion boolean,
    recomendaciones character varying(5000),
    avances character varying(5000),
    logros character varying(5000),
    dificultades character varying(5000),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    filtroproyectofinanciero integer,
    filtroresponsable integer,
    filtrooficina integer,
    columnafecha boolean,
    columnaresponsable boolean
);


--
-- Name: cor1440_gen_informe_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_informe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_informe_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_informe_id_seq OWNED BY public.cor1440_gen_informe.id;


--
-- Name: cor1440_gen_informeauditoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_informeauditoria (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    detalle character varying(5000),
    fecha date,
    devoluciones boolean,
    seguimiento character varying(5000),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_informeauditoria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_informeauditoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_informeauditoria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_informeauditoria_id_seq OWNED BY public.cor1440_gen_informeauditoria.id;


--
-- Name: cor1440_gen_informefinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_informefinanciero (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    detalle character varying(5000),
    fecha date,
    devoluciones boolean,
    seguimiento character varying(5000),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_informefinanciero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_informefinanciero_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_informefinanciero_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_informefinanciero_id_seq OWNED BY public.cor1440_gen_informefinanciero.id;


--
-- Name: cor1440_gen_informenarrativo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_informenarrativo (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    detalle character varying(5000),
    fecha date,
    devoluciones boolean,
    seguimiento character varying(5000),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_informenarrativo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_informenarrativo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_informenarrativo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_informenarrativo_id_seq OWNED BY public.cor1440_gen_informenarrativo.id;


--
-- Name: cor1440_gen_mindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_mindicadorpf (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    indicadorpf_id integer NOT NULL,
    formulacion character varying(512),
    frecuenciaanual character varying(128),
    descd1 character varying,
    descd2 character varying,
    descd3 character varying,
    meta double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    medircon integer,
    funcionresultado character varying(5000)
);


--
-- Name: cor1440_gen_mindicadorpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_mindicadorpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_mindicadorpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_mindicadorpf_id_seq OWNED BY public.cor1440_gen_mindicadorpf.id;


--
-- Name: cor1440_gen_objetivopf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_objetivopf (
    id bigint NOT NULL,
    proyectofinanciero_id integer,
    numero character varying(15) NOT NULL,
    objetivo character varying(5000) NOT NULL
);


--
-- Name: cor1440_gen_objetivopf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_objetivopf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_objetivopf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_objetivopf_id_seq OWNED BY public.cor1440_gen_objetivopf.id;


--
-- Name: cor1440_gen_plantillahcm_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_plantillahcm_proyectofinanciero (
    plantillahcm_id integer,
    proyectofinanciero_id integer
);


--
-- Name: cor1440_gen_pmindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_pmindicadorpf (
    id bigint NOT NULL,
    mindicadorpf_id integer NOT NULL,
    finicio date,
    ffin date,
    restiempo character varying(128),
    dmed1 double precision,
    dmed2 double precision,
    dmed3 double precision,
    datosmedicion json,
    resind double precision,
    meta double precision,
    resindicador json,
    porcump double precision,
    analisis character varying(4096),
    acciones character varying(4096),
    responsables character varying(4096),
    plazo character varying(4096),
    fecha date,
    urlev1 character varying(4096),
    urlev2 character varying(4096),
    urlev3 character varying(4096),
    rutaevidencia character varying(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cor1440_gen_pmindicadorpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_pmindicadorpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_pmindicadorpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_pmindicadorpf_id_seq OWNED BY public.cor1440_gen_pmindicadorpf.id;


--
-- Name: cor1440_gen_proyecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_proyecto (
    id integer NOT NULL,
    nombre character varying(1000),
    observaciones character varying(5000),
    fechainicio date,
    fechacierre date,
    resultados character varying(5000),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cor1440_gen_proyecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_proyecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_proyecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_proyecto_id_seq OWNED BY public.cor1440_gen_proyecto.id;


--
-- Name: cor1440_gen_proyecto_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_proyecto_proyectofinanciero (
    proyecto_id integer NOT NULL,
    proyectofinanciero_id integer NOT NULL
);


--
-- Name: cor1440_gen_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_proyectofinanciero (
    id integer NOT NULL,
    nombre character varying(1000),
    observaciones character varying(5000),
    fechainicio date,
    fechacierre date,
    responsable_id integer,
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    compromisos character varying(5000),
    monto numeric,
    sectorapc_id integer,
    titulo character varying(1000),
    poromision boolean,
    fechaformulacion date,
    fechaaprobacion date,
    fechaliquidacion date,
    estado character varying(1) DEFAULT 'E'::character varying,
    dificultad character varying(1) DEFAULT 'N'::character varying,
    tipomoneda_id integer,
    saldoaejecutarp numeric(20,2),
    centrocosto character varying(500),
    tasaej double precision,
    montoej double precision,
    aportepropioej double precision,
    aporteotrosej double precision,
    presupuestototalej double precision
);


--
-- Name: cor1440_gen_proyectofinanciero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_proyectofinanciero_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_proyectofinanciero_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_proyectofinanciero_id_seq OWNED BY public.cor1440_gen_proyectofinanciero.id;


--
-- Name: cor1440_gen_proyectofinanciero_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_proyectofinanciero_usuario (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    usuario_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_proyectofinanciero_usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_proyectofinanciero_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_proyectofinanciero_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_proyectofinanciero_usuario_id_seq OWNED BY public.cor1440_gen_proyectofinanciero_usuario.id;


--
-- Name: cor1440_gen_rangoedadac; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_rangoedadac (
    id integer NOT NULL,
    nombre character varying(255),
    limiteinferior integer,
    limitesuperior integer,
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000)
);


--
-- Name: cor1440_gen_rangoedadac_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_rangoedadac_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_rangoedadac_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_rangoedadac_id_seq OWNED BY public.cor1440_gen_rangoedadac.id;


--
-- Name: cor1440_gen_resultadopf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_resultadopf (
    id bigint NOT NULL,
    proyectofinanciero_id integer,
    objetivopf_id integer,
    numero character varying(15) NOT NULL,
    resultado character varying(5000) NOT NULL
);


--
-- Name: cor1440_gen_resultadopf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_resultadopf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_resultadopf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_resultadopf_id_seq OWNED BY public.cor1440_gen_resultadopf.id;


--
-- Name: cor1440_gen_sectorapc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_sectorapc (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cor1440_gen_sectorapc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_sectorapc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_sectorapc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_sectorapc_id_seq OWNED BY public.cor1440_gen_sectorapc.id;


--
-- Name: cor1440_gen_tipoindicador; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_tipoindicador (
    id bigint NOT NULL,
    nombre character varying(32),
    medircon integer,
    espcampos character varying(1000),
    espvaloresomision character varying(1000),
    espvalidaciones character varying(1000),
    esptipometa character varying(32),
    espfuncionmedir character varying(1000),
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at date,
    updated_at date,
    descd1 character varying(32),
    descd2 character varying(32),
    descd3 character varying(32),
    descd4 character varying(32)
);


--
-- Name: cor1440_gen_tipoindicador_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_tipoindicador_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_tipoindicador_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_tipoindicador_id_seq OWNED BY public.cor1440_gen_tipoindicador.id;


--
-- Name: cor1440_gen_tipomoneda; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_tipomoneda (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    codiso4217 character varying(3) NOT NULL,
    simbolo character varying(10),
    pais_id integer,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_tipomoneda_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_tipomoneda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_tipomoneda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_tipomoneda_id_seq OWNED BY public.cor1440_gen_tipomoneda.id;


--
-- Name: cor1440_gen_valorcampoact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_valorcampoact (
    id bigint NOT NULL,
    actividad_id integer,
    campoact_id integer,
    valor character varying(5000)
);


--
-- Name: cor1440_gen_valorcampoact_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_valorcampoact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_valorcampoact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_valorcampoact_id_seq OWNED BY public.cor1440_gen_valorcampoact.id;


--
-- Name: cor1440_gen_valorcampotind; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_valorcampotind (
    id bigint NOT NULL,
    campotind_id integer,
    valor character varying(5000)
);


--
-- Name: cor1440_gen_valorcampotind_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_valorcampotind_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_valorcampotind_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_valorcampotind_id_seq OWNED BY public.cor1440_gen_valorcampotind.id;


--
-- Name: respuesta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.respuesta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_aslegal_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_aslegal_respuesta (
    id_respuesta integer NOT NULL,
    id_aslegal integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_respuesta (
    id_caso integer NOT NULL,
    fechaatencion date NOT NULL,
    prorrogas boolean,
    numprorrogas integer,
    montoprorrogas integer,
    fechaultima date,
    lugarultima character varying(500),
    entregada boolean,
    proxprorroga boolean,
    turno character varying(100),
    lugar character varying(500),
    descamp character varying(5000),
    compromisos character varying(5000),
    remision character varying(5000),
    orientaciones character varying(5000),
    gestionessjr character varying(5000),
    observaciones character varying(5000),
    id_personadesea integer DEFAULT 0,
    verifcsjr character varying(5000),
    verifcper character varying(5000),
    efectividad character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.respuesta_seq'::regclass) NOT NULL,
    detallear character varying(5000),
    montoar integer,
    cantidadayes character varying(50),
    institucionayes character varying(500),
    informacionder boolean,
    accionesder character varying(5000),
    detallemotivo character varying(5000),
    difobsprog character varying(5000),
    detalleal character varying(5000),
    montoal integer,
    detalleap character varying(5000),
    montoap integer,
    detalleem character varying(5000),
    montoem integer
);


--
-- Name: cres1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cres1 AS
 SELECT caso.id AS id_caso,
    respuesta.fechaatencion,
    casosjr.oficina_id,
    aslegal_respuesta.id_aslegal
   FROM public.sivel2_gen_caso caso,
    public.sivel2_sjr_casosjr casosjr,
    public.sivel2_sjr_respuesta respuesta,
    public.sivel2_sjr_aslegal_respuesta aslegal_respuesta
  WHERE ((caso.id = casosjr.id_caso) AND (caso.id = respuesta.id_caso) AND (respuesta.id = aslegal_respuesta.id_respuesta));


--
-- Name: fotra_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fotra_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campohc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_campohc (
    id integer NOT NULL,
    doc_id integer NOT NULL,
    nombrecampo character varying(127) NOT NULL,
    columna character varying(5) NOT NULL,
    fila integer
);


--
-- Name: heb412_gen_campohc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_campohc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campohc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_campohc_id_seq OWNED BY public.heb412_gen_campohc.id;


--
-- Name: heb412_gen_campoplantillahcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_campoplantillahcm (
    id integer NOT NULL,
    plantillahcm_id integer,
    nombrecampo character varying(183),
    columna character varying(5)
);


--
-- Name: heb412_gen_campoplantillahcm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_campoplantillahcm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campoplantillahcm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_campoplantillahcm_id_seq OWNED BY public.heb412_gen_campoplantillahcm.id;


--
-- Name: heb412_gen_campoplantillahcr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_campoplantillahcr (
    id bigint NOT NULL,
    plantillahcr_id integer,
    nombrecampo character varying(127),
    columna character varying(5),
    fila integer
);


--
-- Name: heb412_gen_campoplantillahcr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_campoplantillahcr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campoplantillahcr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_campoplantillahcr_id_seq OWNED BY public.heb412_gen_campoplantillahcr.id;


--
-- Name: heb412_gen_carpetaexclusiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_carpetaexclusiva (
    id bigint NOT NULL,
    carpeta character varying(2048),
    grupo_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: heb412_gen_carpetaexclusiva_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_carpetaexclusiva_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_carpetaexclusiva_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_carpetaexclusiva_id_seq OWNED BY public.heb412_gen_carpetaexclusiva.id;


--
-- Name: heb412_gen_doc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_doc (
    id integer NOT NULL,
    nombre character varying(512),
    tipodoc character varying(1),
    dirpapa integer,
    url character varying(1024),
    fuente character varying(1024),
    descripcion character varying(5000),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    adjunto_file_name character varying,
    adjunto_content_type character varying,
    adjunto_file_size integer,
    adjunto_updated_at timestamp without time zone,
    nombremenu character varying(127),
    vista character varying(255),
    filainicial integer,
    ruta character varying(2047),
    licencia character varying(255),
    tdoc_id integer,
    tdoc_type character varying
);


--
-- Name: heb412_gen_doc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_doc_id_seq OWNED BY public.heb412_gen_doc.id;


--
-- Name: heb412_gen_formulario_plantillahcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_formulario_plantillahcm (
    formulario_id integer,
    plantillahcm_id integer
);


--
-- Name: heb412_gen_formulario_plantillahcr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_formulario_plantillahcr (
    id bigint NOT NULL,
    plantillahcr_id integer,
    formulario_id integer
);


--
-- Name: heb412_gen_formulario_plantillahcr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_formulario_plantillahcr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_formulario_plantillahcr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_formulario_plantillahcr_id_seq OWNED BY public.heb412_gen_formulario_plantillahcr.id;


--
-- Name: heb412_gen_plantilladoc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_plantilladoc (
    id bigint NOT NULL,
    ruta character varying(2047),
    fuente character varying(1023),
    licencia character varying(1023),
    vista character varying(127),
    nombremenu character varying(127)
);


--
-- Name: heb412_gen_plantilladoc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_plantilladoc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_plantilladoc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_plantilladoc_id_seq OWNED BY public.heb412_gen_plantilladoc.id;


--
-- Name: heb412_gen_plantillahcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_plantillahcm (
    id integer NOT NULL,
    ruta character varying(2047) NOT NULL,
    fuente character varying(1023),
    licencia character varying(1023),
    vista character varying(127) NOT NULL,
    nombremenu character varying(127) NOT NULL,
    filainicial integer NOT NULL
);


--
-- Name: heb412_gen_plantillahcm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_plantillahcm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_plantillahcm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_plantillahcm_id_seq OWNED BY public.heb412_gen_plantillahcm.id;


--
-- Name: heb412_gen_plantillahcr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_plantillahcr (
    id bigint NOT NULL,
    ruta character varying(2047),
    fuente character varying(1023),
    licencia character varying(1023),
    vista character varying(127),
    nombremenu character varying(127)
);


--
-- Name: heb412_gen_plantillahcr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_plantillahcr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_plantillahcr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_plantillahcr_id_seq OWNED BY public.heb412_gen_plantillahcr.id;


--
-- Name: instanciader_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instanciader_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mecanismoder_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mecanismoder_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: motivoconsulta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.motivoconsulta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_campo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_campo (
    id bigint NOT NULL,
    nombre character varying(512) NOT NULL,
    ayudauso character varying(1024),
    tipo integer DEFAULT 1 NOT NULL,
    obligatorio boolean,
    formulario_id integer NOT NULL,
    nombreinterno character varying(60),
    fila integer,
    columna integer,
    ancho integer,
    tablabasica character varying(32)
);


--
-- Name: mr519_gen_campo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_campo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_campo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_campo_id_seq OWNED BY public.mr519_gen_campo.id;


--
-- Name: mr519_gen_encuestapersona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_encuestapersona (
    id bigint NOT NULL,
    persona_id integer,
    formulario_id integer,
    fecha date,
    fechainicio date NOT NULL,
    fechafin date,
    adurl character varying(32),
    respuestafor_id integer
);


--
-- Name: mr519_gen_encuestapersona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_encuestapersona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_encuestapersona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_encuestapersona_id_seq OWNED BY public.mr519_gen_encuestapersona.id;


--
-- Name: mr519_gen_encuestausuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_encuestausuario (
    id bigint NOT NULL,
    usuario_id integer NOT NULL,
    fecha date,
    fechainicio date NOT NULL,
    fechafin date,
    respuestafor_id integer
);


--
-- Name: mr519_gen_encuestausuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_encuestausuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_encuestausuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_encuestausuario_id_seq OWNED BY public.mr519_gen_encuestausuario.id;


--
-- Name: mr519_gen_formulario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_formulario (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    nombreinterno character varying(60)
);


--
-- Name: mr519_gen_formulario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_formulario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_formulario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_formulario_id_seq OWNED BY public.mr519_gen_formulario.id;


--
-- Name: mr519_gen_opcioncs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_opcioncs (
    id bigint NOT NULL,
    campo_id integer NOT NULL,
    nombre character varying(1024) NOT NULL,
    valor character varying(60) NOT NULL
);


--
-- Name: mr519_gen_opcioncs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_opcioncs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_opcioncs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_opcioncs_id_seq OWNED BY public.mr519_gen_opcioncs.id;


--
-- Name: mr519_gen_planencuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_planencuesta (
    id bigint NOT NULL,
    fechaini date,
    fechafin date,
    formulario_id integer,
    plantillacorreoinv_id integer,
    adurl character varying(32),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mr519_gen_planencuesta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_planencuesta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_planencuesta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_planencuesta_id_seq OWNED BY public.mr519_gen_planencuesta.id;


--
-- Name: mr519_gen_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_respuestafor (
    id bigint NOT NULL,
    formulario_id integer,
    fechaini date NOT NULL,
    fechacambio date NOT NULL
);


--
-- Name: mr519_gen_respuestafor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_respuestafor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_respuestafor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_respuestafor_id_seq OWNED BY public.mr519_gen_respuestafor.id;


--
-- Name: mr519_gen_valorcampo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_valorcampo (
    id bigint NOT NULL,
    campo_id integer NOT NULL,
    valor character varying(5000),
    respuestafor_id integer NOT NULL,
    valorjson json
);


--
-- Name: mr519_gen_valorcampo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_valorcampo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_valorcampo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_valorcampo_id_seq OWNED BY public.mr519_gen_valorcampo.id;


--
-- Name: regimensalud_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.regimensalud_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resagresion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resagresion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sip_anexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_anexo (
    id integer NOT NULL,
    descripcion character varying(1500) COLLATE public.es_co_utf_8,
    adjunto_file_name character varying(255),
    adjunto_content_type character varying(255),
    adjunto_file_size integer,
    adjunto_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sip_anexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_anexo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_anexo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_anexo_id_seq OWNED BY public.sip_anexo.id;


--
-- Name: sip_bitacora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_bitacora (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    ip character varying(100),
    usuario_id integer,
    url character varying(1023),
    params character varying(5000),
    modelo character varying(511),
    modelo_id integer,
    operacion character varying(63),
    detalle json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_bitacora_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_bitacora_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_bitacora_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_bitacora_id_seq OWNED BY public.sip_bitacora.id;


--
-- Name: sip_etiqueta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_etiqueta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_etiqueta (
    id integer DEFAULT nextval('public.sip_etiqueta_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT etiqueta_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_etiqueta_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_etiqueta_municipio (
    etiqueta_id bigint NOT NULL,
    municipio_id bigint NOT NULL
);


--
-- Name: sip_fuenteprensa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_fuenteprensa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_fuenteprensa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_fuenteprensa (
    id integer DEFAULT nextval('public.sip_fuenteprensa_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    tfuente character varying(25),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT sip_fuenteprensa_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_grupo (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_grupo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_grupo_id_seq OWNED BY public.sip_grupo.id;


--
-- Name: sip_grupo_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_grupo_usuario (
    usuario_id integer NOT NULL,
    sip_grupo_id integer NOT NULL
);


--
-- Name: sip_grupoper_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_grupoper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_grupoper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_grupoper (
    id integer DEFAULT nextval('public.sip_grupoper_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    anotaciones character varying(1000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sip_mundep_sinorden; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sip_mundep_sinorden AS
 SELECT ((sip_departamento.id_deplocal * 1000) + sip_municipio.id_munlocal) AS idlocal,
    (((sip_municipio.nombre)::text || ' / '::text) || (sip_departamento.nombre)::text) AS nombre
   FROM (public.sip_municipio
     JOIN public.sip_departamento ON ((sip_municipio.id_departamento = sip_departamento.id)))
  WHERE ((sip_departamento.id_pais = 170) AND (sip_municipio.fechadeshabilitacion IS NULL) AND (sip_departamento.fechadeshabilitacion IS NULL))
UNION
 SELECT sip_departamento.id_deplocal AS idlocal,
    sip_departamento.nombre
   FROM public.sip_departamento
  WHERE ((sip_departamento.id_pais = 170) AND (sip_departamento.fechadeshabilitacion IS NULL));


--
-- Name: sip_mundep; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.sip_mundep AS
 SELECT sip_mundep_sinorden.idlocal,
    sip_mundep_sinorden.nombre,
    to_tsvector('spanish'::regconfig, public.unaccent(sip_mundep_sinorden.nombre)) AS mundep
   FROM public.sip_mundep_sinorden
  ORDER BY (sip_mundep_sinorden.nombre COLLATE public.es_co_utf_8)
  WITH NO DATA;


--
-- Name: sip_oficina_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_oficina_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_oficina; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_oficina (
    id integer DEFAULT nextval('public.sip_oficina_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT regionsjr_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_orgsocial (
    id bigint NOT NULL,
    grupoper_id integer NOT NULL,
    telefono character varying(500),
    fax character varying(500),
    direccion character varying(500),
    pais_id integer,
    web character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    fechadeshabilitacion date
);


--
-- Name: sip_orgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_orgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_orgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_orgsocial_id_seq OWNED BY public.sip_orgsocial.id;


--
-- Name: sip_orgsocial_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_orgsocial_persona (
    id bigint NOT NULL,
    persona_id integer NOT NULL,
    orgsocial_id integer,
    perfilorgsocial_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    correo character varying(100),
    cargo character varying(254)
);


--
-- Name: sip_orgsocial_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_orgsocial_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_orgsocial_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_orgsocial_persona_id_seq OWNED BY public.sip_orgsocial_persona.id;


--
-- Name: sip_orgsocial_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_orgsocial_sectororgsocial (
    orgsocial_id integer,
    sectororgsocial_id integer
);


--
-- Name: sip_pais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_pais (
    id integer NOT NULL,
    nombre character varying(200) NOT NULL COLLATE public.es_co_utf_8,
    nombreiso character varying(200) NOT NULL,
    latitud double precision,
    longitud double precision,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codiso integer,
    div1 character varying(100),
    div2 character varying(100),
    div3 character varying(100),
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT pais_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_pais_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_pais_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_pais_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_pais_id_seq OWNED BY public.sip_pais.id;


--
-- Name: sip_perfilorgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_perfilorgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_perfilorgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_perfilorgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_perfilorgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_perfilorgsocial_id_seq OWNED BY public.sip_perfilorgsocial.id;


--
-- Name: sip_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_persona (
    id integer DEFAULT nextval('public.sip_persona_id_seq'::regclass) NOT NULL,
    nombres character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    apellidos character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    anionac integer,
    mesnac integer,
    dianac integer,
    sexo character(1) DEFAULT 'S'::bpchar NOT NULL,
    numerodocumento character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer,
    nacionalde integer,
    tdocumento_id integer,
    id_departamento integer,
    id_municipio integer,
    id_clase integer,
    CONSTRAINT persona_check CHECK (((dianac IS NULL) OR (((dianac >= 1) AND (((mesnac = 1) OR (mesnac = 3) OR (mesnac = 5) OR (mesnac = 7) OR (mesnac = 8) OR (mesnac = 10) OR (mesnac = 12)) AND (dianac <= 31))) OR (((mesnac = 4) OR (mesnac = 6) OR (mesnac = 9) OR (mesnac = 11)) AND (dianac <= 30)) OR ((mesnac = 2) AND (dianac <= 29))))),
    CONSTRAINT persona_mesnac_check CHECK (((mesnac IS NULL) OR ((mesnac >= 1) AND (mesnac <= 12)))),
    CONSTRAINT persona_sexo_check CHECK (((sexo = 'S'::bpchar) OR (sexo = 'F'::bpchar) OR (sexo = 'M'::bpchar)))
);


--
-- Name: sip_persona_trelacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_persona_trelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_persona_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_persona_trelacion (
    persona1 integer NOT NULL,
    persona2 integer NOT NULL,
    id_trelacion character(2) DEFAULT 'SI'::bpchar NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sip_persona_trelacion_id_seq'::regclass) NOT NULL
);


--
-- Name: sip_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_sectororgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_sectororgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_sectororgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_sectororgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_sectororgsocial_id_seq OWNED BY public.sip_sectororgsocial.id;


--
-- Name: sip_tclase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tclase (
    id character varying(10) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT tclase_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_tdocumento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tdocumento (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    sigla character varying(100),
    formatoregex character varying(500),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8
);


--
-- Name: sip_tdocumento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tdocumento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tdocumento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_tdocumento_id_seq OWNED BY public.sip_tdocumento.id;


--
-- Name: sip_tema; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tema (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    nav_ini character varying(8),
    nav_fin character varying(8),
    nav_fuente character varying(8),
    fondo_lista character varying(8),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    btn_primario_fondo_ini character varying(127),
    btn_primario_fondo_fin character varying(127),
    btn_primario_fuente character varying(127),
    btn_peligro_fondo_ini character varying(127),
    btn_peligro_fondo_fin character varying(127),
    btn_peligro_fuente character varying(127),
    btn_accion_fondo_ini character varying(127),
    btn_accion_fondo_fin character varying(127),
    btn_accion_fuente character varying(127),
    alerta_exito_fondo character varying(127),
    alerta_exito_fuente character varying(127),
    alerta_problema_fondo character varying(127),
    alerta_problema_fuente character varying(127),
    fondo character varying(127),
    color_fuente character varying(127),
    color_flota_subitem_fuente character varying,
    color_flota_subitem_fondo character varying
);


--
-- Name: sip_tema_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_tema_id_seq OWNED BY public.sip_tema.id;


--
-- Name: sip_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_trelacion (
    id character(2) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    inverso character varying(2),
    CONSTRAINT trelacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_trivalente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_trivalente (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sip_trivalente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_trivalente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_trivalente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_trivalente_id_seq OWNED BY public.sip_trivalente.id;


--
-- Name: sip_tsitio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_tsitio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_tsitio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_tsitio (
    id integer DEFAULT nextval('public.sip_tsitio_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT tsitio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sip_ubicacionpre; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sip_ubicacionpre (
    id bigint NOT NULL,
    nombre character varying(2000) NOT NULL COLLATE public.es_co_utf_8,
    pais_id integer,
    departamento_id integer,
    municipio_id integer,
    clase_id integer,
    lugar character varying(500),
    sitio character varying(500),
    tsitio_id integer,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nombre_sin_pais character varying(500)
);


--
-- Name: sip_ubicacionpre_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sip_ubicacionpre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sip_ubicacionpre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sip_ubicacionpre_id_seq OWNED BY public.sip_ubicacionpre.id;


--
-- Name: sivel2_gen_actividadoficio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_actividadoficio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actividadoficio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_actividadoficio (
    id integer DEFAULT nextval('public.sivel2_gen_actividadoficio_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT actividadoficio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_acto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_acto (
    id_presponsable integer NOT NULL,
    id_categoria integer NOT NULL,
    id_persona integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.acto_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_actocolectivo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_actocolectivo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actocolectivo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_actocolectivo (
    id_presponsable integer NOT NULL,
    id_categoria integer NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_actocolectivo_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_anexo_caso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_anexo_caso (
    id integer DEFAULT nextval('public.anexo_seq'::regclass) NOT NULL,
    id_caso integer NOT NULL,
    fecha date NOT NULL,
    fuenteprensa_id integer,
    fechaffrecuente date,
    id_fotra integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_anexo integer NOT NULL
);


--
-- Name: sivel2_gen_anexo_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_anexo_victima (
    id bigint NOT NULL,
    id_anexo integer,
    id_victima integer,
    fecha date
);


--
-- Name: sivel2_gen_anexo_victima_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_anexo_victima_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_anexo_victima_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_anexo_victima_id_seq OWNED BY public.sivel2_gen_anexo_victima.id;


--
-- Name: sivel2_gen_antecedente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_antecedente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_antecedente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente (
    id integer DEFAULT nextval('public.sivel2_gen_antecedente_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT antecedente_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_antecedente_caso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_caso (
    id_antecedente integer NOT NULL,
    id_caso integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_combatiente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_combatiente (
    id_antecedente integer NOT NULL,
    id_combatiente integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_victima (
    id_antecedente integer NOT NULL,
    id_victima integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_victimacolectiva (
    id_antecedente integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_caso_categoria_presponsable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_categoria_presponsable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_categoria_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_categoria_presponsable (
    id_categoria integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_caso_presponsable integer NOT NULL,
    id integer DEFAULT nextval('public.sivel2_gen_caso_categoria_presponsable_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_caso_contexto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_contexto (
    id_caso integer NOT NULL,
    id_contexto integer NOT NULL
);


--
-- Name: sivel2_gen_caso_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_etiqueta (
    id_caso integer NOT NULL,
    id_etiqueta integer NOT NULL,
    id_usuario integer NOT NULL,
    fecha date NOT NULL,
    observaciones character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.caso_etiqueta_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_caso_fotra_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_fotra_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_fotra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_fotra (
    id_caso integer NOT NULL,
    id_fotra integer,
    anotacion character varying(1024),
    fecha date NOT NULL,
    ubicacionfisica character varying(1024),
    tfuente character varying(25),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    id integer DEFAULT nextval('public.sivel2_gen_caso_fotra_seq'::regclass) NOT NULL,
    anexo_caso_id integer
);


--
-- Name: sivel2_gen_caso_frontera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_frontera (
    id_frontera integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_fuenteprensa_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_fuenteprensa_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_fuenteprensa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_fuenteprensa (
    fecha date NOT NULL,
    ubicacion character varying(1024),
    clasificacion character varying(100),
    ubicacionfisica character varying(1024),
    fuenteprensa_id integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_caso_fuenteprensa_seq'::regclass) NOT NULL,
    anexo_caso_id integer
);


--
-- Name: sivel2_gen_caso_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_presponsable (
    id_caso integer NOT NULL,
    id_presponsable integer NOT NULL,
    tipo integer DEFAULT 0 NOT NULL,
    bloque character varying(50),
    frente character varying(50),
    brigada character varying(50),
    batallon character varying(50),
    division character varying(50),
    otro character varying(500),
    id integer DEFAULT nextval('public.caso_presponsable_seq'::regclass) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_region (
    id_caso integer NOT NULL,
    id_region integer NOT NULL
);


--
-- Name: sivel2_gen_caso_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_respuestafor (
    caso_id integer NOT NULL,
    respuestafor_id integer NOT NULL
);


--
-- Name: sivel2_gen_caso_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_usuario (
    id_usuario integer NOT NULL,
    id_caso integer NOT NULL,
    fechainicio date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_categoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_categoria (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    id_pconsolidado integer,
    contadaen integer,
    tipocat character(1) DEFAULT 'I'::bpchar,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    supracategoria_id integer,
    CONSTRAINT categoria_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion))),
    CONSTRAINT categoria_tipocat_check CHECK (((tipocat = 'I'::bpchar) OR (tipocat = 'C'::bpchar) OR (tipocat = 'O'::bpchar)))
);


--
-- Name: sivel2_gen_combatiente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_combatiente (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    alias character varying(500),
    edad integer,
    sexo character varying(1) DEFAULT 'S'::character varying NOT NULL,
    id_resagresion integer DEFAULT 1 NOT NULL,
    id_profesion integer DEFAULT 22,
    id_rangoedad integer DEFAULT 6,
    id_filiacion integer DEFAULT 10,
    id_sectorsocial integer DEFAULT 15,
    id_organizacion integer DEFAULT 16,
    id_vinculoestado integer DEFAULT 38,
    id_caso integer,
    organizacionarmada integer DEFAULT 35,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_combatiente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_combatiente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_combatiente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_combatiente_id_seq OWNED BY public.sivel2_gen_combatiente.id;


--
-- Name: sivel2_sjr_statusmigratorio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_statusmigratorio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_statusmigratorio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_statusmigratorio (
    id integer DEFAULT nextval('public.sivel2_sjr_statusmigratorio_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT statusmigratorio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id integer DEFAULT nextval('public.usuario_id_seq'::regclass) NOT NULL,
    nusuario character varying(15) NOT NULL,
    password character varying(64) DEFAULT ''::character varying NOT NULL,
    nombre character varying(50) COLLATE public.es_co_utf_8,
    descripcion character varying(50),
    rol integer DEFAULT 4,
    idioma character varying(6) DEFAULT 'es_CO'::character varying NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    oficina_id integer,
    failed_attempts integer DEFAULT 0,
    unlock_token character varying(255),
    locked_at timestamp without time zone,
    tema_id integer,
    observadorffechaini date,
    observadorffechafin date,
    fincontrato date,
    CONSTRAINT usuario_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion))),
    CONSTRAINT usuario_rol_check CHECK ((rol >= 1))
);


--
-- Name: sivel2_gen_conscaso1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sivel2_gen_conscaso1 AS
 SELECT casosjr.id_caso AS caso_id,
    array_to_string(ARRAY( SELECT (((persona.nombres)::text || ' '::text) || (persona.apellidos)::text)
           FROM public.sip_persona persona
          WHERE (persona.id = casosjr.contacto_id)), ', '::text) AS contacto,
    casosjr.fecharec,
    oficina.nombre AS oficina,
    usuario.nusuario,
    caso.fecha,
    statusmigratorio.nombre AS statusmigratorio,
    array_to_string(ARRAY( SELECT respuesta.fechaatencion
           FROM public.sivel2_sjr_respuesta respuesta
          WHERE (respuesta.id_caso = casosjr.id_caso)
          ORDER BY respuesta.fechaatencion DESC
         LIMIT 1), ', '::text) AS ultimaatencion_fecha,
    caso.memo,
    array_to_string(ARRAY( SELECT (((persona.nombres)::text || ' '::text) || (persona.apellidos)::text)
           FROM public.sip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.id_persona) AND (victima.id_caso = caso.id))), ', '::text) AS victimas
   FROM ((((public.sivel2_sjr_casosjr casosjr
     JOIN public.sivel2_gen_caso caso ON ((casosjr.id_caso = caso.id)))
     JOIN public.sip_oficina oficina ON ((oficina.id = casosjr.oficina_id)))
     JOIN public.usuario ON ((usuario.id = casosjr.asesor)))
     LEFT JOIN public.sivel2_sjr_statusmigratorio statusmigratorio ON ((statusmigratorio.id = casosjr.id_statusmigratorio)));


--
-- Name: sivel2_gen_conscaso; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.sivel2_gen_conscaso AS
 SELECT sivel2_gen_conscaso1.caso_id,
    sivel2_gen_conscaso1.contacto,
    sivel2_gen_conscaso1.fecharec,
    sivel2_gen_conscaso1.oficina,
    sivel2_gen_conscaso1.nusuario,
    sivel2_gen_conscaso1.fecha,
    sivel2_gen_conscaso1.statusmigratorio,
    sivel2_gen_conscaso1.ultimaatencion_fecha,
    sivel2_gen_conscaso1.memo,
    sivel2_gen_conscaso1.victimas,
    to_tsvector('spanish'::regconfig, public.unaccent(((((((((((((((((((sivel2_gen_conscaso1.caso_id || ' '::text) || sivel2_gen_conscaso1.contacto) || ' '::text) || replace(((sivel2_gen_conscaso1.fecharec)::character varying)::text, '-'::text, ' '::text)) || ' '::text) || (sivel2_gen_conscaso1.oficina)::text) || ' '::text) || (sivel2_gen_conscaso1.nusuario)::text) || ' '::text) || replace(((sivel2_gen_conscaso1.fecha)::character varying)::text, '-'::text, ' '::text)) || ' '::text) || (sivel2_gen_conscaso1.statusmigratorio)::text) || ' '::text) || replace(((sivel2_gen_conscaso1.ultimaatencion_fecha)::character varying)::text, '-'::text, ' '::text)) || ' '::text) || sivel2_gen_conscaso1.memo) || ' '::text) || sivel2_gen_conscaso1.victimas))) AS q
   FROM public.sivel2_gen_conscaso1
  WITH NO DATA;


--
-- Name: sivel2_gen_contexto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_contexto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_contexto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_contexto (
    id integer DEFAULT nextval('public.sivel2_gen_contexto_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT contexto_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_contextovictima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_contextovictima (
    id bigint NOT NULL,
    nombre character varying(100) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_contextovictima_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_contextovictima_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_contextovictima_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_contextovictima_id_seq OWNED BY public.sivel2_gen_contextovictima.id;


--
-- Name: sivel2_gen_contextovictima_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_contextovictima_victima (
    contextovictima_id integer NOT NULL,
    victima_id integer NOT NULL
);


--
-- Name: sivel2_gen_departamento_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_departamento_region (
    departamento_id integer,
    region_id integer
);


--
-- Name: sivel2_gen_escolaridad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_escolaridad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_escolaridad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_escolaridad (
    id integer DEFAULT nextval('public.sivel2_gen_escolaridad_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT escolaridad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_estadocivil_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_estadocivil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_estadocivil; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_estadocivil (
    id integer DEFAULT nextval('public.sivel2_gen_estadocivil_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT estadocivil_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_etnia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_etnia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_etnia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_etnia (
    id integer DEFAULT nextval('public.sivel2_gen_etnia_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    descripcion character varying(1000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT etnia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_etnia_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_etnia_victimacolectiva (
    etnia_id integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_filiacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_filiacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_filiacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_filiacion (
    id integer DEFAULT nextval('public.sivel2_gen_filiacion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT filiacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_filiacion_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_filiacion_victimacolectiva (
    id_filiacion integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_fotra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_fotra (
    id integer DEFAULT nextval('public.fotra_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_frontera_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_frontera_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_frontera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_frontera (
    id integer DEFAULT nextval('public.sivel2_gen_frontera_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT frontera_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_iglesia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_iglesia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_iglesia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_iglesia (
    id integer DEFAULT nextval('public.sivel2_gen_iglesia_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    descripcion character varying(1000),
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT iglesia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_intervalo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_intervalo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_intervalo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_intervalo (
    id integer DEFAULT nextval('public.sivel2_gen_intervalo_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    rango character varying(25) NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT intervalo_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_maternidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_maternidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_maternidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_maternidad (
    id integer DEFAULT nextval('public.sivel2_gen_maternidad_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT maternidad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_municipio_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_municipio_region (
    municipio_id integer,
    region_id integer
);


--
-- Name: sivel2_gen_observador_filtrodepartamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_observador_filtrodepartamento (
    usuario_id integer,
    departamento_id integer
);


--
-- Name: sivel2_gen_organizacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_organizacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_organizacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_organizacion (
    id integer DEFAULT nextval('public.sivel2_gen_organizacion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT organizacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_organizacion_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_organizacion_victimacolectiva (
    id_organizacion integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_pconsolidado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_pconsolidado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_pconsolidado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_pconsolidado (
    id integer DEFAULT nextval('public.sivel2_gen_pconsolidado_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    tipoviolencia character varying(25) NOT NULL,
    clasificacion character varying(25) NOT NULL,
    peso integer DEFAULT 0,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(500),
    CONSTRAINT pconsolidado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_presponsable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_presponsable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_presponsable (
    id integer DEFAULT nextval('public.sivel2_gen_presponsable_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    papa_id integer,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT presponsable_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_profesion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_profesion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_profesion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_profesion (
    id integer DEFAULT nextval('public.sivel2_gen_profesion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT profesion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_profesion_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_profesion_victimacolectiva (
    id_profesion integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_rangoedad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_rangoedad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_rangoedad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_rangoedad (
    id integer DEFAULT nextval('public.sivel2_gen_rangoedad_id_seq'::regclass) NOT NULL,
    nombre character varying(20) NOT NULL COLLATE public.es_co_utf_8,
    limiteinferior integer DEFAULT 0 NOT NULL,
    limitesuperior integer DEFAULT 0 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT rangoedad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_rangoedad_victimacolectiva (
    id_rangoedad integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_region (
    id integer DEFAULT nextval('public.sivel2_gen_region_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT region_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_resagresion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_resagresion (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_resagresion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_resagresion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_resagresion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_resagresion_id_seq OWNED BY public.sivel2_gen_resagresion.id;


--
-- Name: sivel2_gen_sectorsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_sectorsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_sectorsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_sectorsocial (
    id integer DEFAULT nextval('public.sivel2_gen_sectorsocial_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT sectorsocial_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_sectorsocial_victimacolectiva (
    id_sectorsocial integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_sectorsocialsec_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_sectorsocialsec_victima (
    sectorsocial_id integer,
    victima_id integer
);


--
-- Name: sivel2_gen_supracategoria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_supracategoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_supracategoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_supracategoria (
    codigo integer,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    id_tviolencia character varying(1) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    id integer DEFAULT nextval('public.sivel2_gen_supracategoria_id_seq'::regclass) NOT NULL,
    CONSTRAINT supracategoria_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_tviolencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_tviolencia (
    id character(1) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    nomcorto character varying(10) NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT tviolencia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_victimacolectiva_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_victimacolectiva_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_victimacolectiva (
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    personasaprox integer,
    organizacionarmada integer DEFAULT 35,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_victimacolectiva_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_victimacolectiva_vinculoestado (
    victimacolectiva_id integer NOT NULL,
    id_vinculoestado integer NOT NULL
);


--
-- Name: sivel2_gen_vinculoestado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_vinculoestado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_vinculoestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_vinculoestado (
    id integer DEFAULT nextval('public.sivel2_gen_vinculoestado_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT vinculoestado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_acreditacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_acreditacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_acreditacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_acreditacion (
    id integer DEFAULT nextval('public.sivel2_sjr_acreditacion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT acreditacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_actividad_casosjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_actividad_casosjr (
    id bigint NOT NULL,
    actividad_id integer,
    casosjr_id integer
);


--
-- Name: sivel2_sjr_actividad_casosjr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_actividad_casosjr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_actividad_casosjr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_actividad_casosjr_id_seq OWNED BY public.sivel2_sjr_actividad_casosjr.id;


--
-- Name: sivel2_sjr_actosjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_actosjr (
    fecha date NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_acto integer NOT NULL,
    desplazamiento_id integer
);


--
-- Name: sivel2_sjr_actualizacionbase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_actualizacionbase (
    id character varying(10) NOT NULL,
    fecha date NOT NULL,
    descripcion character varying(500) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_aslegal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_aslegal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_aslegal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_aslegal (
    id integer DEFAULT nextval('public.sivel2_sjr_aslegal_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT aslegal_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_aspsicosocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_aspsicosocial (
    id bigint NOT NULL,
    nombre character varying(100) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_sjr_aspsicosocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_aspsicosocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_aspsicosocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_aspsicosocial_id_seq OWNED BY public.sivel2_sjr_aspsicosocial.id;


--
-- Name: sivel2_sjr_aspsicosocial_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_aspsicosocial_respuesta (
    id_aspsicosocial bigint NOT NULL,
    id_respuesta bigint NOT NULL
);


--
-- Name: sivel2_sjr_ayudaestado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_ayudaestado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_ayudaestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudaestado (
    id integer DEFAULT nextval('public.sivel2_sjr_ayudaestado_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT ayudaestado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_ayudaestado_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudaestado_derecho (
    ayudaestado_id integer NOT NULL,
    derecho_id integer NOT NULL
);


--
-- Name: sivel2_sjr_ayudaestado_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudaestado_respuesta (
    id_respuesta integer NOT NULL,
    id_ayudaestado integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_ayudasjr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_ayudasjr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_ayudasjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudasjr (
    id integer DEFAULT nextval('public.sivel2_sjr_ayudasjr_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT ayudasjr_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_ayudasjr_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudasjr_derecho (
    ayudasjr_id integer,
    derecho_id integer
);


--
-- Name: sivel2_sjr_ayudasjr_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudasjr_respuesta (
    id_ayudasjr integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_respuesta integer NOT NULL
);


--
-- Name: sivel2_sjr_clasifdesp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_clasifdesp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_clasifdesp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_clasifdesp (
    id integer DEFAULT nextval('public.sivel2_sjr_clasifdesp_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT clasifdesp_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_comosupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_comosupo (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_comosupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_comosupo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_comosupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_comosupo_id_seq OWNED BY public.sivel2_sjr_comosupo.id;


--
-- Name: sivel2_sjr_declaroante_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_declaroante_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_declaroante; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_declaroante (
    id integer DEFAULT nextval('public.sivel2_sjr_declaroante_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT declaroante_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_derecho_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_derecho_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_derecho (
    id integer DEFAULT nextval('public.sivel2_sjr_derecho_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT '2013-06-12'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT derecho_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_derecho_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_derecho_respuesta (
    id_respuesta integer NOT NULL,
    id_derecho integer DEFAULT 9 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_etiqueta_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_etiqueta_usuario (
    id integer NOT NULL,
    etiqueta_id integer,
    usuario_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_etiqueta_usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_etiqueta_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_etiqueta_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_etiqueta_usuario_id_seq OWNED BY public.sivel2_sjr_etiqueta_usuario.id;


--
-- Name: sivel2_sjr_idioma_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_idioma_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_idioma; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_idioma (
    id integer DEFAULT nextval('public.sivel2_sjr_idioma_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT '2014-02-14'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT idioma_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_inclusion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_inclusion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_inclusion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_inclusion (
    id integer DEFAULT nextval('public.sivel2_sjr_inclusion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT inclusion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_instanciader; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_instanciader (
    id integer DEFAULT nextval('public.instanciader_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-06-12'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT instanciader_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_mecanismoder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_mecanismoder (
    id integer DEFAULT nextval('public.mecanismoder_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-06-12'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT mecanismoder_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_modalidadtierra_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_modalidadtierra_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_modalidadtierra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_modalidadtierra (
    id integer DEFAULT nextval('public.sivel2_sjr_modalidadtierra_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT modalidadtierra_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_motivoconsulta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_motivoconsulta (
    id integer DEFAULT nextval('public.motivoconsulta_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-05-13'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT motivoconsulta_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_motivosjr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_motivosjr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_motivosjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_motivosjr (
    id integer DEFAULT nextval('public.sivel2_sjr_motivosjr_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT '2013-06-16'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT motivosjr_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_motivosjr_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_motivosjr_derecho (
    motivosjr_id integer,
    derecho_id integer
);


--
-- Name: sivel2_sjr_motivosjr_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_motivosjr_respuesta (
    id_respuesta integer NOT NULL,
    id_motivosjr integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_oficina_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_oficina_proyectofinanciero (
    oficina_id bigint NOT NULL,
    proyectofinanciero_id bigint NOT NULL
);


--
-- Name: sivel2_sjr_personadesea_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_personadesea_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_personadesea; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_personadesea (
    id integer DEFAULT nextval('public.sivel2_sjr_personadesea_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-06-17'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT personadesea_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_progestado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_progestado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_progestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_progestado (
    id integer DEFAULT nextval('public.sivel2_sjr_progestado_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-06-17'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT progestado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_progestado_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_progestado_derecho (
    progestado_id integer,
    derecho_id integer
);


--
-- Name: sivel2_sjr_progestado_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_progestado_respuesta (
    id_respuesta integer NOT NULL,
    id_progestado integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_proteccion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_proteccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_proteccion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_proteccion (
    id integer DEFAULT nextval('public.sivel2_sjr_proteccion_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT proteccion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_refugio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_refugio (
    id integer NOT NULL,
    id_caso integer,
    fechasalida date,
    id_salida integer,
    fechallegada date,
    id_llegada integer,
    id_causaref integer,
    observaciones character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_refugio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_refugio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_refugio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_refugio_id_seq OWNED BY public.sivel2_sjr_refugio.id;


--
-- Name: sivel2_sjr_regimensalud; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_regimensalud (
    id integer DEFAULT nextval('public.regimensalud_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-05-13'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT regimensalud_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_resagresion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_resagresion (
    id integer DEFAULT nextval('public.resagresion_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT resagresion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_rolfamilia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_rolfamilia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_rolfamilia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_rolfamilia (
    id integer DEFAULT nextval('public.sivel2_sjr_rolfamilia_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT rolfamilia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_tipodesp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_tipodesp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_tipodesp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_tipodesp (
    id integer DEFAULT nextval('public.sivel2_sjr_tipodesp_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT tipodesp_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_victimasjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_victimasjr (
    sindocumento boolean,
    id_estadocivil integer DEFAULT 0,
    id_rolfamilia integer DEFAULT 0 NOT NULL,
    cabezafamilia boolean,
    id_maternidad integer DEFAULT 0,
    discapacitado boolean,
    id_actividadoficio integer DEFAULT 0,
    id_escolaridad integer DEFAULT 0,
    asisteescuela boolean,
    tienesisben boolean,
    id_departamento integer,
    id_municipio integer,
    nivelsisben integer,
    id_regimensalud integer DEFAULT 0,
    eps character varying(1000),
    libretamilitar boolean,
    distrito integer,
    progadultomayor boolean,
    fechadesagregacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_victima integer NOT NULL,
    id_pais integer,
    enfermedad character varying(5000),
    ndiscapacidad character varying(100)
);


--
-- Name: vvictimasoundexesp; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.vvictimasoundexesp AS
 SELECT sivel2_gen_victima.id_caso,
    sip_persona.id AS id_persona,
    (((sip_persona.nombres)::text || ' '::text) || (sip_persona.apellidos)::text) AS nomap,
    ( SELECT array_to_string(array_agg(public.soundexesp(n.s)), ' '::text) AS array_to_string
           FROM ( SELECT unnest(string_to_array(regexp_replace((((sip_persona.nombres)::text || ' '::text) || (sip_persona.apellidos)::text), '  *'::text, ' '::text), ' '::text)) AS s
                  ORDER BY (unnest(string_to_array(regexp_replace((((sip_persona.nombres)::text || ' '::text) || (sip_persona.apellidos)::text), '  *'::text, ' '::text), ' '::text)))) n) AS nomsoundexesp
   FROM public.sip_persona,
    public.sivel2_gen_victima
  WHERE (sip_persona.id = sivel2_gen_victima.id_persona)
  WITH NO DATA;


--
-- Name: cor1440_gen_actividad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividad_id_seq'::regclass);


--
-- Name: cor1440_gen_actividad_proyecto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyecto ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividad_proyecto_id_seq'::regclass);


--
-- Name: cor1440_gen_actividad_rangoedadac id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_rangoedadac ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividad_rangoedadac_id_seq'::regclass);


--
-- Name: cor1440_gen_actividad_valorcampotind id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_valorcampotind ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividad_valorcampotind_id_seq'::regclass);


--
-- Name: cor1440_gen_actividadarea id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadarea ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividadarea_id_seq'::regclass);


--
-- Name: cor1440_gen_actividadareas_actividad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadareas_actividad ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividadareas_actividad_id_seq'::regclass);


--
-- Name: cor1440_gen_actividadpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividadpf_id_seq'::regclass);


--
-- Name: cor1440_gen_actividadtipo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadtipo ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividadtipo_id_seq'::regclass);


--
-- Name: cor1440_gen_anexo_efecto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_efecto ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_anexo_efecto_id_seq'::regclass);


--
-- Name: cor1440_gen_anexo_proyectofinanciero id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_proyectofinanciero ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_anexo_proyectofinanciero_id_seq'::regclass);


--
-- Name: cor1440_gen_asistencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_asistencia ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_asistencia_id_seq'::regclass);


--
-- Name: cor1440_gen_campoact id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_campoact ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_campoact_id_seq'::regclass);


--
-- Name: cor1440_gen_campotind id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_campotind ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_campotind_id_seq'::regclass);


--
-- Name: cor1440_gen_caracterizacionpersona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_caracterizacionpersona_id_seq'::regclass);


--
-- Name: cor1440_gen_datointermedioti id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_datointermedioti_id_seq'::regclass);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti_pmindicadorpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_datointermedioti_pmindicadorpf_id_seq'::regclass);


--
-- Name: cor1440_gen_desembolso id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_desembolso ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_desembolso_id_seq'::regclass);


--
-- Name: cor1440_gen_efecto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_efecto_id_seq'::regclass);


--
-- Name: cor1440_gen_financiador id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_financiador ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_financiador_id_seq'::regclass);


--
-- Name: cor1440_gen_indicadorpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_indicadorpf_id_seq'::regclass);


--
-- Name: cor1440_gen_informe id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_informe_id_seq'::regclass);


--
-- Name: cor1440_gen_informeauditoria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informeauditoria ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_informeauditoria_id_seq'::regclass);


--
-- Name: cor1440_gen_informefinanciero id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informefinanciero ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_informefinanciero_id_seq'::regclass);


--
-- Name: cor1440_gen_informenarrativo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informenarrativo ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_informenarrativo_id_seq'::regclass);


--
-- Name: cor1440_gen_mindicadorpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_mindicadorpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_mindicadorpf_id_seq'::regclass);


--
-- Name: cor1440_gen_objetivopf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_objetivopf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_objetivopf_id_seq'::regclass);


--
-- Name: cor1440_gen_pmindicadorpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_pmindicadorpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_pmindicadorpf_id_seq'::regclass);


--
-- Name: cor1440_gen_proyecto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyecto ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_proyecto_id_seq'::regclass);


--
-- Name: cor1440_gen_proyectofinanciero id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_proyectofinanciero_id_seq'::regclass);


--
-- Name: cor1440_gen_proyectofinanciero_usuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero_usuario ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_proyectofinanciero_usuario_id_seq'::regclass);


--
-- Name: cor1440_gen_rangoedadac id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_rangoedadac ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_rangoedadac_id_seq'::regclass);


--
-- Name: cor1440_gen_resultadopf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_resultadopf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_resultadopf_id_seq'::regclass);


--
-- Name: cor1440_gen_sectorapc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_sectorapc ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_sectorapc_id_seq'::regclass);


--
-- Name: cor1440_gen_tipoindicador id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipoindicador ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_tipoindicador_id_seq'::regclass);


--
-- Name: cor1440_gen_tipomoneda id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipomoneda ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_tipomoneda_id_seq'::regclass);


--
-- Name: cor1440_gen_valorcampoact id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_valorcampoact ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_valorcampoact_id_seq'::regclass);


--
-- Name: cor1440_gen_valorcampotind id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_valorcampotind ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_valorcampotind_id_seq'::regclass);


--
-- Name: heb412_gen_campohc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campohc ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_campohc_id_seq'::regclass);


--
-- Name: heb412_gen_campoplantillahcm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcm ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_campoplantillahcm_id_seq'::regclass);


--
-- Name: heb412_gen_campoplantillahcr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcr ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_campoplantillahcr_id_seq'::regclass);


--
-- Name: heb412_gen_carpetaexclusiva id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_carpetaexclusiva ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_carpetaexclusiva_id_seq'::regclass);


--
-- Name: heb412_gen_doc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_doc ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_doc_id_seq'::regclass);


--
-- Name: heb412_gen_formulario_plantillahcr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_formulario_plantillahcr_id_seq'::regclass);


--
-- Name: heb412_gen_plantilladoc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantilladoc ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_plantilladoc_id_seq'::regclass);


--
-- Name: heb412_gen_plantillahcm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcm ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_plantillahcm_id_seq'::regclass);


--
-- Name: heb412_gen_plantillahcr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcr ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_plantillahcr_id_seq'::regclass);


--
-- Name: mr519_gen_campo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_campo_id_seq'::regclass);


--
-- Name: mr519_gen_encuestapersona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_encuestapersona_id_seq'::regclass);


--
-- Name: mr519_gen_encuestausuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_encuestausuario_id_seq'::regclass);


--
-- Name: mr519_gen_formulario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_formulario ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_formulario_id_seq'::regclass);


--
-- Name: mr519_gen_opcioncs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_opcioncs_id_seq'::regclass);


--
-- Name: mr519_gen_planencuesta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_planencuesta ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_planencuesta_id_seq'::regclass);


--
-- Name: mr519_gen_respuestafor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_respuestafor_id_seq'::regclass);


--
-- Name: mr519_gen_valorcampo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_valorcampo_id_seq'::regclass);


--
-- Name: sip_anexo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_anexo ALTER COLUMN id SET DEFAULT nextval('public.sip_anexo_id_seq'::regclass);


--
-- Name: sip_bitacora id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_bitacora ALTER COLUMN id SET DEFAULT nextval('public.sip_bitacora_id_seq'::regclass);


--
-- Name: sip_grupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo ALTER COLUMN id SET DEFAULT nextval('public.sip_grupo_id_seq'::regclass);


--
-- Name: sip_orgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial ALTER COLUMN id SET DEFAULT nextval('public.sip_orgsocial_id_seq'::regclass);


--
-- Name: sip_orgsocial_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_persona ALTER COLUMN id SET DEFAULT nextval('public.sip_orgsocial_persona_id_seq'::regclass);


--
-- Name: sip_pais id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_pais ALTER COLUMN id SET DEFAULT nextval('public.sip_pais_id_seq'::regclass);


--
-- Name: sip_perfilorgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_perfilorgsocial ALTER COLUMN id SET DEFAULT nextval('public.sip_perfilorgsocial_id_seq'::regclass);


--
-- Name: sip_sectororgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_sectororgsocial ALTER COLUMN id SET DEFAULT nextval('public.sip_sectororgsocial_id_seq'::regclass);


--
-- Name: sip_tdocumento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tdocumento ALTER COLUMN id SET DEFAULT nextval('public.sip_tdocumento_id_seq'::regclass);


--
-- Name: sip_tema id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tema ALTER COLUMN id SET DEFAULT nextval('public.sip_tema_id_seq'::regclass);


--
-- Name: sip_trivalente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trivalente ALTER COLUMN id SET DEFAULT nextval('public.sip_trivalente_id_seq'::regclass);


--
-- Name: sip_ubicacionpre id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre ALTER COLUMN id SET DEFAULT nextval('public.sip_ubicacionpre_id_seq'::regclass);


--
-- Name: sivel2_gen_anexo_victima id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_victima ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_anexo_victima_id_seq'::regclass);


--
-- Name: sivel2_gen_combatiente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_combatiente_id_seq'::regclass);


--
-- Name: sivel2_gen_contextovictima id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_contextovictima_id_seq'::regclass);


--
-- Name: sivel2_gen_resagresion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_resagresion ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_resagresion_id_seq'::regclass);


--
-- Name: sivel2_sjr_actividad_casosjr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actividad_casosjr ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_actividad_casosjr_id_seq'::regclass);


--
-- Name: sivel2_sjr_aspsicosocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aspsicosocial ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_aspsicosocial_id_seq'::regclass);


--
-- Name: sivel2_sjr_comosupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_comosupo ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_comosupo_id_seq'::regclass);


--
-- Name: sivel2_sjr_etiqueta_usuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_etiqueta_usuario ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_etiqueta_usuario_id_seq'::regclass);


--
-- Name: sivel2_sjr_refugio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_refugio ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_refugio_id_seq'::regclass);


--
-- Name: cor1440_gen_actividad actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad
    ADD CONSTRAINT actividad_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_rangoedadac actividad_rangoedadac_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_rangoedadac
    ADD CONSTRAINT actividad_rangoedadac_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividadarea actividadarea_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadarea
    ADD CONSTRAINT actividadarea_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividadareas_actividad actividadareas_actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadareas_actividad
    ADD CONSTRAINT actividadareas_actividad_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_actividadoficio actividadoficio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actividadoficio
    ADD CONSTRAINT actividadoficio_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_acto acto_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_key UNIQUE (id);


--
-- Name: sivel2_gen_acto acto_id_presponsable_id_categoria_id_persona_id_caso_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_presponsable_id_categoria_id_persona_id_caso_key UNIQUE (id_presponsable, id_categoria, id_persona, id_caso);


--
-- Name: sivel2_gen_acto acto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_actosjr actosjr_id_acto_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actosjr
    ADD CONSTRAINT actosjr_id_acto_key UNIQUE (id_acto);


--
-- Name: sivel2_sjr_actosjr actosjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actosjr
    ADD CONSTRAINT actosjr_pkey PRIMARY KEY (id_acto);


--
-- Name: sivel2_sjr_actualizacionbase actualizacionbase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actualizacionbase
    ADD CONSTRAINT actualizacionbase_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_anexo_caso anexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_pkey PRIMARY KEY (id);


--
-- Name: sip_anexo anexoactividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_anexo
    ADD CONSTRAINT anexoactividad_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_antecedente antecedente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente
    ADD CONSTRAINT antecedente_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: sivel2_sjr_aslegal aslegal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aslegal
    ADD CONSTRAINT aslegal_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_aslegal_respuesta aslegal_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aslegal_respuesta
    ADD CONSTRAINT aslegal_respuesta_pkey PRIMARY KEY (id_respuesta, id_aslegal);


--
-- Name: sivel2_sjr_ayudaestado ayudaestado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado
    ADD CONSTRAINT ayudaestado_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_ayudaestado_respuesta ayudaestado_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado_respuesta
    ADD CONSTRAINT ayudaestado_respuesta_pkey PRIMARY KEY (id_respuesta, id_ayudaestado);


--
-- Name: sivel2_sjr_ayudasjr ayudasjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr
    ADD CONSTRAINT ayudasjr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_ayudasjr_respuesta ayudasjr_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_respuesta
    ADD CONSTRAINT ayudasjr_respuesta_pkey PRIMARY KEY (id_respuesta, id_ayudasjr);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_key UNIQUE (id);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso
    ADD CONSTRAINT caso_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_presponsable caso_presponsable_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_key UNIQUE (id);


--
-- Name: sivel2_gen_caso_presponsable caso_presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_usuario caso_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_usuario
    ADD CONSTRAINT caso_usuario_pkey PRIMARY KEY (id_usuario, id_caso);


--
-- Name: sivel2_sjr_casosjr casosjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_pkey PRIMARY KEY (id_caso);


--
-- Name: sivel2_gen_categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_clasifdesp clasifdesp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_clasifdesp
    ADD CONSTRAINT clasifdesp_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_comosupo comosupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_comosupo
    ADD CONSTRAINT comosupo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_contexto contexto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contexto
    ADD CONSTRAINT contexto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_proyecto cor1440_gen_actividad_proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyecto
    ADD CONSTRAINT cor1440_gen_actividad_proyecto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero cor1440_gen_actividad_proyectofinanciero_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyectofinanciero
    ADD CONSTRAINT cor1440_gen_actividad_proyectofinanciero_id_key UNIQUE (id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero cor1440_gen_actividad_proyectofinanciero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyectofinanciero
    ADD CONSTRAINT cor1440_gen_actividad_proyectofinanciero_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_sip_anexo cor1440_gen_actividad_sip_anexo_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_sip_anexo
    ADD CONSTRAINT cor1440_gen_actividad_sip_anexo_id_key UNIQUE (id);


--
-- Name: cor1440_gen_actividad_sip_anexo cor1440_gen_actividad_sip_anexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_sip_anexo
    ADD CONSTRAINT cor1440_gen_actividad_sip_anexo_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_valorcampotind cor1440_gen_actividad_valorcampotind_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_valorcampotind
    ADD CONSTRAINT cor1440_gen_actividad_valorcampotind_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividadpf cor1440_gen_actividadpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT cor1440_gen_actividadpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividadtipo cor1440_gen_actividadtipo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadtipo
    ADD CONSTRAINT cor1440_gen_actividadtipo_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_anexo_efecto cor1440_gen_anexo_efecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_efecto
    ADD CONSTRAINT cor1440_gen_anexo_efecto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_anexo_proyectofinanciero cor1440_gen_anexo_proyectofinanciero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_proyectofinanciero
    ADD CONSTRAINT cor1440_gen_anexo_proyectofinanciero_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_asistencia cor1440_gen_asistencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_asistencia
    ADD CONSTRAINT cor1440_gen_asistencia_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_campoact cor1440_gen_campoact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_campoact
    ADD CONSTRAINT cor1440_gen_campoact_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_campotind cor1440_gen_campotind_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_campotind
    ADD CONSTRAINT cor1440_gen_campotind_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_caracterizacionpersona cor1440_gen_caracterizacionpersona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona
    ADD CONSTRAINT cor1440_gen_caracterizacionpersona_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_datointermedioti cor1440_gen_datointermedioti_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti
    ADD CONSTRAINT cor1440_gen_datointermedioti_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf cor1440_gen_datointermedioti_pmindicadorpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti_pmindicadorpf
    ADD CONSTRAINT cor1440_gen_datointermedioti_pmindicadorpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_desembolso cor1440_gen_desembolso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_desembolso
    ADD CONSTRAINT cor1440_gen_desembolso_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_efecto cor1440_gen_efecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto
    ADD CONSTRAINT cor1440_gen_efecto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_financiador cor1440_gen_financiador_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_financiador
    ADD CONSTRAINT cor1440_gen_financiador_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_indicadorpf cor1440_gen_indicadorpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT cor1440_gen_indicadorpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_informe cor1440_gen_informe_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT cor1440_gen_informe_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_informeauditoria cor1440_gen_informeauditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informeauditoria
    ADD CONSTRAINT cor1440_gen_informeauditoria_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_informefinanciero cor1440_gen_informefinanciero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informefinanciero
    ADD CONSTRAINT cor1440_gen_informefinanciero_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_informenarrativo cor1440_gen_informenarrativo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informenarrativo
    ADD CONSTRAINT cor1440_gen_informenarrativo_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_mindicadorpf cor1440_gen_mindicadorpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_mindicadorpf
    ADD CONSTRAINT cor1440_gen_mindicadorpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_objetivopf cor1440_gen_objetivopf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_objetivopf
    ADD CONSTRAINT cor1440_gen_objetivopf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_pmindicadorpf cor1440_gen_pmindicadorpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_pmindicadorpf
    ADD CONSTRAINT cor1440_gen_pmindicadorpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_proyecto cor1440_gen_proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyecto
    ADD CONSTRAINT cor1440_gen_proyecto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_proyectofinanciero cor1440_gen_proyectofinanciero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero
    ADD CONSTRAINT cor1440_gen_proyectofinanciero_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_proyectofinanciero_usuario cor1440_gen_proyectofinanciero_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero_usuario
    ADD CONSTRAINT cor1440_gen_proyectofinanciero_usuario_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_resultadopf cor1440_gen_resultadopf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_resultadopf
    ADD CONSTRAINT cor1440_gen_resultadopf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_sectorapc cor1440_gen_sectorapc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_sectorapc
    ADD CONSTRAINT cor1440_gen_sectorapc_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_tipoindicador cor1440_gen_tipoindicador_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipoindicador
    ADD CONSTRAINT cor1440_gen_tipoindicador_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_tipomoneda cor1440_gen_tipomoneda_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipomoneda
    ADD CONSTRAINT cor1440_gen_tipomoneda_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_valorcampoact cor1440_gen_valorcampoact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_valorcampoact
    ADD CONSTRAINT cor1440_gen_valorcampoact_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_valorcampotind cor1440_gen_valorcampotind_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_valorcampotind
    ADD CONSTRAINT cor1440_gen_valorcampotind_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_declaroante declaroante_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_declaroante
    ADD CONSTRAINT declaroante_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_derecho derecho_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_derecho
    ADD CONSTRAINT derecho_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_derecho_respuesta derecho_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_derecho_respuesta
    ADD CONSTRAINT derecho_respuesta_pkey PRIMARY KEY (id_respuesta, id_derecho);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_caso_fechaexpulsion_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_caso_fechaexpulsion_key UNIQUE (id_caso, fechaexpulsion);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_key UNIQUE (id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_escolaridad escolaridad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_escolaridad
    ADD CONSTRAINT escolaridad_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_estadocivil estadocivil_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_estadocivil
    ADD CONSTRAINT estadocivil_pkey PRIMARY KEY (id);


--
-- Name: sip_etiqueta etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_etiqueta
    ADD CONSTRAINT etiqueta_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_etiqueta_usuario etiqueta_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_etiqueta_usuario
    ADD CONSTRAINT etiqueta_usuario_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_etnia etnia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia
    ADD CONSTRAINT etnia_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_filiacion filiacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion
    ADD CONSTRAINT filiacion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_fotra fotra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_fotra
    ADD CONSTRAINT fotra_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_frontera frontera_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_frontera
    ADD CONSTRAINT frontera_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_campohc heb412_gen_campohc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campohc
    ADD CONSTRAINT heb412_gen_campohc_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_campoplantillahcm heb412_gen_campoplantillahcm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcm
    ADD CONSTRAINT heb412_gen_campoplantillahcm_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_campoplantillahcr heb412_gen_campoplantillahcr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcr
    ADD CONSTRAINT heb412_gen_campoplantillahcr_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_carpetaexclusiva heb412_gen_carpetaexclusiva_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_carpetaexclusiva
    ADD CONSTRAINT heb412_gen_carpetaexclusiva_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_doc heb412_gen_doc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_doc
    ADD CONSTRAINT heb412_gen_doc_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_formulario_plantillahcr heb412_gen_formulario_plantillahcr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr
    ADD CONSTRAINT heb412_gen_formulario_plantillahcr_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_plantilladoc heb412_gen_plantilladoc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantilladoc
    ADD CONSTRAINT heb412_gen_plantilladoc_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_plantillahcm heb412_gen_plantillahcm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcm
    ADD CONSTRAINT heb412_gen_plantillahcm_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_plantillahcr heb412_gen_plantillahcr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcr
    ADD CONSTRAINT heb412_gen_plantillahcr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_idioma idioma_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_idioma
    ADD CONSTRAINT idioma_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_iglesia iglesia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_iglesia
    ADD CONSTRAINT iglesia_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_inclusion inclusion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_inclusion
    ADD CONSTRAINT inclusion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_instanciader instanciader_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_instanciader
    ADD CONSTRAINT instanciader_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_intervalo intervalo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_intervalo
    ADD CONSTRAINT intervalo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_maternidad maternidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_maternidad
    ADD CONSTRAINT maternidad_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_mecanismoder mecanismoder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_mecanismoder
    ADD CONSTRAINT mecanismoder_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_modalidadtierra modalidadtierra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_modalidadtierra
    ADD CONSTRAINT modalidadtierra_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_motivoconsulta motivoconsulta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivoconsulta
    ADD CONSTRAINT motivoconsulta_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_motivosjr motivosjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr
    ADD CONSTRAINT motivosjr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_motivosjr_respuesta motivosjr_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_respuesta
    ADD CONSTRAINT motivosjr_respuesta_pkey PRIMARY KEY (id_respuesta, id_motivosjr);


--
-- Name: mr519_gen_campo mr519_gen_campo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo
    ADD CONSTRAINT mr519_gen_campo_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_encuestapersona mr519_gen_encuestapersona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT mr519_gen_encuestapersona_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_encuestausuario mr519_gen_encuestausuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT mr519_gen_encuestausuario_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_formulario mr519_gen_formulario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_formulario
    ADD CONSTRAINT mr519_gen_formulario_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_opcioncs mr519_gen_opcioncs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs
    ADD CONSTRAINT mr519_gen_opcioncs_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_planencuesta mr519_gen_planencuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_planencuesta
    ADD CONSTRAINT mr519_gen_planencuesta_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_respuestafor mr519_gen_respuestafor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor
    ADD CONSTRAINT mr519_gen_respuestafor_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_valorcampo mr519_gen_valorcampo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT mr519_gen_valorcampo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_organizacion organizacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion
    ADD CONSTRAINT organizacion_pkey PRIMARY KEY (id);


--
-- Name: sip_pais pais_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_pais
    ADD CONSTRAINT pais_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_pconsolidado pconsolidado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_pconsolidado
    ADD CONSTRAINT pconsolidado_pkey PRIMARY KEY (id);


--
-- Name: sip_persona persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_personadesea personadesea_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_personadesea
    ADD CONSTRAINT personadesea_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_presponsable presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_presponsable
    ADD CONSTRAINT presponsable_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_profesion profesion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion
    ADD CONSTRAINT profesion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_progestado progestado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado
    ADD CONSTRAINT progestado_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_progestado_respuesta progestado_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_respuesta
    ADD CONSTRAINT progestado_respuesta_pkey PRIMARY KEY (id_respuesta, id_progestado);


--
-- Name: sivel2_sjr_proteccion proteccion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_proteccion
    ADD CONSTRAINT proteccion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_rangoedad rangoedad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad
    ADD CONSTRAINT rangoedad_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_rangoedadac rangoedadac_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_rangoedadac
    ADD CONSTRAINT rangoedadac_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_refugio refugio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_refugio
    ADD CONSTRAINT refugio_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_regimensalud regimensalud_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_regimensalud
    ADD CONSTRAINT regimensalud_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_region region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: sip_oficina regionsjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_oficina
    ADD CONSTRAINT regionsjr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_resagresion resagresion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_resagresion
    ADD CONSTRAINT resagresion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_respuesta respuesta_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_respuesta
    ADD CONSTRAINT respuesta_id_key UNIQUE (id);


--
-- Name: sivel2_sjr_respuesta respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_respuesta
    ADD CONSTRAINT respuesta_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_rolfamilia rolfamilia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_rolfamilia
    ADD CONSTRAINT rolfamilia_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_sectorsocial sectorsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial
    ADD CONSTRAINT sectorsocial_pkey PRIMARY KEY (id);


--
-- Name: sip_bitacora sip_bitacora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_bitacora
    ADD CONSTRAINT sip_bitacora_pkey PRIMARY KEY (id);


--
-- Name: sip_clase sip_clase_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT sip_clase_id_key UNIQUE (id);


--
-- Name: sip_clase sip_clase_id_municipio_id_clalocal_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT sip_clase_id_municipio_id_clalocal_key UNIQUE (id_municipio, id_clalocal);


--
-- Name: sip_clase sip_clase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT sip_clase_pkey PRIMARY KEY (id);


--
-- Name: sip_departamento sip_departamento_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT sip_departamento_id_key UNIQUE (id);


--
-- Name: sip_departamento sip_departamento_id_pais_id_deplocal_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT sip_departamento_id_pais_id_deplocal_key UNIQUE (id_pais, id_deplocal);


--
-- Name: sip_departamento sip_departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT sip_departamento_pkey PRIMARY KEY (id);


--
-- Name: sip_fuenteprensa sip_fuenteprensa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_fuenteprensa
    ADD CONSTRAINT sip_fuenteprensa_pkey PRIMARY KEY (id);


--
-- Name: sip_grupo sip_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo
    ADD CONSTRAINT sip_grupo_pkey PRIMARY KEY (id);


--
-- Name: sip_grupoper sip_grupoper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupoper
    ADD CONSTRAINT sip_grupoper_pkey PRIMARY KEY (id);


--
-- Name: sip_municipio sip_municipio_id_departamento_id_munlocal_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_id_departamento_id_munlocal_key UNIQUE (id_departamento, id_munlocal);


--
-- Name: sip_municipio sip_municipio_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_id_key UNIQUE (id);


--
-- Name: sip_municipio sip_municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_pkey PRIMARY KEY (id);


--
-- Name: sip_orgsocial_persona sip_orgsocial_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_persona
    ADD CONSTRAINT sip_orgsocial_persona_pkey PRIMARY KEY (id);


--
-- Name: sip_orgsocial sip_orgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial
    ADD CONSTRAINT sip_orgsocial_pkey PRIMARY KEY (id);


--
-- Name: sip_perfilorgsocial sip_perfilorgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_perfilorgsocial
    ADD CONSTRAINT sip_perfilorgsocial_pkey PRIMARY KEY (id);


--
-- Name: sip_persona_trelacion sip_persona_trelacion_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT sip_persona_trelacion_id_key UNIQUE (id);


--
-- Name: sip_persona_trelacion sip_persona_trelacion_persona1_persona2_id_trelacion_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT sip_persona_trelacion_persona1_persona2_id_trelacion_key UNIQUE (persona1, persona2, id_trelacion);


--
-- Name: sip_persona_trelacion sip_persona_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT sip_persona_trelacion_pkey PRIMARY KEY (id);


--
-- Name: sip_sectororgsocial sip_sectororgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_sectororgsocial
    ADD CONSTRAINT sip_sectororgsocial_pkey PRIMARY KEY (id);


--
-- Name: sip_tema sip_tema_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tema
    ADD CONSTRAINT sip_tema_pkey PRIMARY KEY (id);


--
-- Name: sip_trivalente sip_trivalente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trivalente
    ADD CONSTRAINT sip_trivalente_pkey PRIMARY KEY (id);


--
-- Name: sip_ubicacionpre sip_ubicacionpre_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT sip_ubicacionpre_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_actocolectivo sivel2_gen_actocolectivo_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT sivel2_gen_actocolectivo_id_key UNIQUE (id);


--
-- Name: sivel2_gen_actocolectivo sivel2_gen_actocolectivo_id_presponsable_id_categoria_id_gr_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT sivel2_gen_actocolectivo_id_presponsable_id_categoria_id_gr_key UNIQUE (id_presponsable, id_categoria, id_grupoper, id_caso);


--
-- Name: sivel2_gen_actocolectivo sivel2_gen_actocolectivo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT sivel2_gen_actocolectivo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_anexo_victima sivel2_gen_anexo_victima_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_victima
    ADD CONSTRAINT sivel2_gen_anexo_victima_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_antecedente_caso sivel2_gen_antecedente_caso_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT sivel2_gen_antecedente_caso_pkey1 PRIMARY KEY (id_antecedente, id_caso);


--
-- Name: sivel2_gen_antecedente_combatiente sivel2_gen_antecedente_combatiente_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_combatiente
    ADD CONSTRAINT sivel2_gen_antecedente_combatiente_pkey1 PRIMARY KEY (id_antecedente, id_combatiente);


--
-- Name: sivel2_gen_antecedente_victima sivel2_gen_antecedente_victima_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victima
    ADD CONSTRAINT sivel2_gen_antecedente_victima_pkey1 PRIMARY KEY (id_antecedente, id_victima);


--
-- Name: sivel2_gen_antecedente_victimacolectiva sivel2_gen_antecedente_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victimacolectiva
    ADD CONSTRAINT sivel2_gen_antecedente_victimacolectiva_pkey1 PRIMARY KEY (id_antecedente, victimacolectiva_id);


--
-- Name: sivel2_gen_caso_categoria_presponsable sivel2_gen_caso_categoria_pre_id_caso_presponsable_id_categ_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT sivel2_gen_caso_categoria_pre_id_caso_presponsable_id_categ_key UNIQUE (id_caso_presponsable, id_categoria);


--
-- Name: sivel2_gen_caso_categoria_presponsable sivel2_gen_caso_categoria_presponsable_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT sivel2_gen_caso_categoria_presponsable_id_key UNIQUE (id);


--
-- Name: sivel2_gen_caso_categoria_presponsable sivel2_gen_caso_categoria_presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT sivel2_gen_caso_categoria_presponsable_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_contexto sivel2_gen_caso_contexto_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_contexto
    ADD CONSTRAINT sivel2_gen_caso_contexto_pkey1 PRIMARY KEY (id_caso, id_contexto);


--
-- Name: sivel2_gen_caso_fotra sivel2_gen_caso_fotra_id_caso_nombre_fecha_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT sivel2_gen_caso_fotra_id_caso_nombre_fecha_key UNIQUE (id_caso, nombre, fecha);


--
-- Name: sivel2_gen_caso_fotra sivel2_gen_caso_fotra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT sivel2_gen_caso_fotra_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_id_caso_fecha_fuenteprensa_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_id_caso_fecha_fuenteprensa_id_key UNIQUE (id_caso, fecha, fuenteprensa_id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_region sivel2_gen_caso_region_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_region
    ADD CONSTRAINT sivel2_gen_caso_region_pkey1 PRIMARY KEY (id_caso, id_region);


--
-- Name: sivel2_gen_caso_respuestafor sivel2_gen_caso_respuestafor_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_respuestafor
    ADD CONSTRAINT sivel2_gen_caso_respuestafor_pkey1 PRIMARY KEY (caso_id, respuestafor_id);


--
-- Name: sivel2_gen_combatiente sivel2_gen_combatiente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT sivel2_gen_combatiente_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_contextovictima sivel2_gen_contextovictima_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima
    ADD CONSTRAINT sivel2_gen_contextovictima_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_contextovictima_victima sivel2_gen_contextovictima_victima_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima_victima
    ADD CONSTRAINT sivel2_gen_contextovictima_victima_pkey1 PRIMARY KEY (contextovictima_id, victima_id);


--
-- Name: sivel2_gen_etnia_victimacolectiva sivel2_gen_etnia_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia_victimacolectiva
    ADD CONSTRAINT sivel2_gen_etnia_victimacolectiva_pkey1 PRIMARY KEY (etnia_id, victimacolectiva_id);


--
-- Name: sivel2_gen_filiacion_victimacolectiva sivel2_gen_filiacion_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion_victimacolectiva
    ADD CONSTRAINT sivel2_gen_filiacion_victimacolectiva_pkey1 PRIMARY KEY (id_filiacion, victimacolectiva_id);


--
-- Name: sivel2_gen_organizacion_victimacolectiva sivel2_gen_organizacion_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion_victimacolectiva
    ADD CONSTRAINT sivel2_gen_organizacion_victimacolectiva_pkey1 PRIMARY KEY (id_organizacion, victimacolectiva_id);


--
-- Name: sivel2_gen_profesion_victimacolectiva sivel2_gen_profesion_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victimacolectiva
    ADD CONSTRAINT sivel2_gen_profesion_victimacolectiva_pkey1 PRIMARY KEY (id_profesion, victimacolectiva_id);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva sivel2_gen_rangoedad_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad_victimacolectiva
    ADD CONSTRAINT sivel2_gen_rangoedad_victimacolectiva_pkey1 PRIMARY KEY (id_rangoedad, victimacolectiva_id);


--
-- Name: sivel2_gen_resagresion sivel2_gen_resagresion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_resagresion
    ADD CONSTRAINT sivel2_gen_resagresion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva sivel2_gen_sectorsocial_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial_victimacolectiva
    ADD CONSTRAINT sivel2_gen_sectorsocial_victimacolectiva_pkey1 PRIMARY KEY (id_sectorsocial, victimacolectiva_id);


--
-- Name: sivel2_gen_supracategoria sivel2_gen_supracategoria_id_tviolencia_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT sivel2_gen_supracategoria_id_tviolencia_codigo_key UNIQUE (id_tviolencia, codigo);


--
-- Name: sivel2_gen_supracategoria sivel2_gen_supracategoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT sivel2_gen_supracategoria_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victimacolectiva sivel2_gen_victimacolectiva_id_caso_id_grupoper_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT sivel2_gen_victimacolectiva_id_caso_id_grupoper_key UNIQUE (id_caso, id_grupoper);


--
-- Name: sivel2_gen_victimacolectiva sivel2_gen_victimacolectiva_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT sivel2_gen_victimacolectiva_id_key UNIQUE (id);


--
-- Name: sivel2_gen_victimacolectiva sivel2_gen_victimacolectiva_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT sivel2_gen_victimacolectiva_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado sivel2_gen_victimacolectiva_vinculoestado_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva_vinculoestado
    ADD CONSTRAINT sivel2_gen_victimacolectiva_vinculoestado_pkey1 PRIMARY KEY (victimacolectiva_id, id_vinculoestado);


--
-- Name: sivel2_sjr_acreditacion sivel2_sjr_acreditacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_acreditacion
    ADD CONSTRAINT sivel2_sjr_acreditacion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_actividad_casosjr sivel2_sjr_actividad_casosjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actividad_casosjr
    ADD CONSTRAINT sivel2_sjr_actividad_casosjr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_aspsicosocial sivel2_sjr_aspsicosocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aspsicosocial
    ADD CONSTRAINT sivel2_sjr_aspsicosocial_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_statusmigratorio statusmigratorio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_statusmigratorio
    ADD CONSTRAINT statusmigratorio_pkey PRIMARY KEY (id);


--
-- Name: sip_tclase tclase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tclase
    ADD CONSTRAINT tclase_pkey PRIMARY KEY (id);


--
-- Name: sip_tdocumento tdocumento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tdocumento
    ADD CONSTRAINT tdocumento_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_tipodesp tipodesp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_tipodesp
    ADD CONSTRAINT tipodesp_pkey PRIMARY KEY (id);


--
-- Name: sip_trelacion trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_trelacion
    ADD CONSTRAINT trelacion_pkey PRIMARY KEY (id);


--
-- Name: sip_tsitio tsitio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_tsitio
    ADD CONSTRAINT tsitio_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_tviolencia tviolencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_tviolencia
    ADD CONSTRAINT tviolencia_pkey PRIMARY KEY (id);


--
-- Name: sip_ubicacion ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_nusuario_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_nusuario_key UNIQUE (nusuario);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victima victima_id_caso_id_persona_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_id_persona_key UNIQUE (id_caso, id_persona);


--
-- Name: sivel2_gen_victima victima_id_caso_id_persona_key1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_id_persona_key1 UNIQUE (id_caso, id_persona);


--
-- Name: sivel2_gen_victima victima_id_caso_id_persona_key2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_id_persona_key2 UNIQUE (id_caso, id_persona);


--
-- Name: sivel2_gen_victima victima_id_caso_id_persona_key3; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_id_persona_key3 UNIQUE (id_caso, id_persona);


--
-- Name: sivel2_gen_victima victima_id_caso_id_persona_key4; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_id_persona_key4 UNIQUE (id_caso, id_persona);


--
-- Name: sivel2_gen_victima victima_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_key UNIQUE (id);


--
-- Name: sivel2_gen_victima victima_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_pkey PRIMARY KEY (id_victima);


--
-- Name: sivel2_gen_vinculoestado vinculoestado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_vinculoestado
    ADD CONSTRAINT vinculoestado_pkey PRIMARY KEY (id);


--
-- Name: busca_conscaso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX busca_conscaso ON public.sivel2_gen_conscaso USING gin (q);


--
-- Name: cor1440_gen_actividad_oficina_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_actividad_oficina_id_idx ON public.cor1440_gen_actividad USING btree (oficina_id);


--
-- Name: cor1440_gen_actividad_proyectofinanci_proyectofinanciero_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_actividad_proyectofinanci_proyectofinanciero_id_idx ON public.cor1440_gen_actividad_proyectofinanciero USING btree (proyectofinanciero_id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero_actividad_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_actividad_proyectofinanciero_actividad_id_idx ON public.cor1440_gen_actividad_proyectofinanciero USING btree (actividad_id);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf_llaves_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cor1440_gen_datointermedioti_pmindicadorpf_llaves_idx ON public.cor1440_gen_datointermedioti_pmindicadorpf USING btree (datointermedioti_id, pmindicadorpf_id);


--
-- Name: index_cor1440_gen_actividad_on_usuario_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_actividad_on_usuario_id ON public.cor1440_gen_actividad USING btree (usuario_id);


--
-- Name: index_cor1440_gen_actividad_sip_anexo_on_anexo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_actividad_sip_anexo_on_anexo_id ON public.cor1440_gen_actividad_sip_anexo USING btree (anexo_id);


--
-- Name: index_cor1440_gen_actividadpf_mindicadorpf_on_actividadpf_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_actividadpf_mindicadorpf_on_actividadpf_id ON public.cor1440_gen_actividadpf_mindicadorpf USING btree (actividadpf_id);


--
-- Name: index_cor1440_gen_actividadpf_mindicadorpf_on_mindicadorpf_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_actividadpf_mindicadorpf_on_mindicadorpf_id ON public.cor1440_gen_actividadpf_mindicadorpf USING btree (mindicadorpf_id);


--
-- Name: index_cor1440_gen_datointermedioti_on_mindicadorpf_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_datointermedioti_on_mindicadorpf_id ON public.cor1440_gen_datointermedioti USING btree (mindicadorpf_id);


--
-- Name: index_heb412_gen_doc_on_tdoc_type_and_tdoc_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_heb412_gen_doc_on_tdoc_type_and_tdoc_id ON public.heb412_gen_doc USING btree (tdoc_type, tdoc_id);


--
-- Name: index_mr519_gen_encuestapersona_on_adurl; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mr519_gen_encuestapersona_on_adurl ON public.mr519_gen_encuestapersona USING btree (adurl);


--
-- Name: index_sip_orgsocial_on_grupoper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_orgsocial_on_grupoper_id ON public.sip_orgsocial USING btree (grupoper_id);


--
-- Name: index_sip_orgsocial_on_pais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_orgsocial_on_pais_id ON public.sip_orgsocial USING btree (pais_id);


--
-- Name: index_sip_ubicacion_on_id_clase; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_clase ON public.sip_ubicacion USING btree (id_clase);


--
-- Name: index_sip_ubicacion_on_id_departamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_departamento ON public.sip_ubicacion USING btree (id_departamento);


--
-- Name: index_sip_ubicacion_on_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_municipio ON public.sip_ubicacion USING btree (id_municipio);


--
-- Name: index_sip_ubicacion_on_id_pais; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sip_ubicacion_on_id_pais ON public.sip_ubicacion USING btree (id_pais);


--
-- Name: index_sivel2_gen_actividad_on_rangoedadac_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_actividad_on_rangoedadac_id ON public.cor1440_gen_actividad USING btree (rangoedadac_id);


--
-- Name: index_sivel2_gen_actividad_rangoedadac_on_actividad_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_actividad_rangoedadac_on_actividad_id ON public.cor1440_gen_actividad_rangoedadac USING btree (actividad_id);


--
-- Name: index_sivel2_gen_actividad_rangoedadac_on_rangoedadac_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_actividad_rangoedadac_on_rangoedadac_id ON public.cor1440_gen_actividad_rangoedadac USING btree (rangoedadac_id);


--
-- Name: index_sivel2_gen_sectorsocialsec_victima_on_sectorsocial_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_sectorsocialsec_victima_on_sectorsocial_id ON public.sivel2_gen_sectorsocialsec_victima USING btree (sectorsocial_id);


--
-- Name: index_sivel2_gen_sectorsocialsec_victima_on_victima_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_sectorsocialsec_victima_on_victima_id ON public.sivel2_gen_sectorsocialsec_victima USING btree (victima_id);


--
-- Name: index_sivel2_sjr_casosjr_on_comosupo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_casosjr_on_comosupo_id ON public.sivel2_sjr_casosjr USING btree (comosupo_id);


--
-- Name: index_usuario_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_usuario_on_email ON public.usuario USING btree (email);


--
-- Name: index_usuario_on_regionsjr_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_usuario_on_regionsjr_id ON public.usuario USING btree (oficina_id);


--
-- Name: index_usuario_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_usuario_on_reset_password_token ON public.usuario USING btree (reset_password_token);


--
-- Name: indice_sip_ubicacion_sobre_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sip_ubicacion_sobre_id_caso ON public.sip_ubicacion USING btree (id_caso);


--
-- Name: indice_sivel2_gen_acto_sobre_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_caso ON public.sivel2_gen_acto USING btree (id_caso);


--
-- Name: indice_sivel2_gen_acto_sobre_id_categoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_categoria ON public.sivel2_gen_acto USING btree (id_categoria);


--
-- Name: indice_sivel2_gen_acto_sobre_id_persona; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_persona ON public.sivel2_gen_acto USING btree (id_persona);


--
-- Name: indice_sivel2_gen_acto_sobre_id_presponsable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_presponsable ON public.sivel2_gen_acto USING btree (id_presponsable);


--
-- Name: indice_sivel2_gen_caso_presponsable_sobre_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_presponsable_sobre_id_caso ON public.sivel2_gen_caso_presponsable USING btree (id_caso);


--
-- Name: indice_sivel2_gen_caso_presponsable_sobre_id_presponsable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_presponsable_sobre_id_presponsable ON public.sivel2_gen_caso_presponsable USING btree (id_presponsable);


--
-- Name: indice_sivel2_gen_caso_presponsable_sobre_ids_caso_presp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_presponsable_sobre_ids_caso_presp ON public.sivel2_gen_caso_presponsable USING btree (id_caso, id_presponsable);


--
-- Name: indice_sivel2_gen_caso_sobre_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_sobre_fecha ON public.sivel2_gen_caso USING btree (fecha);


--
-- Name: indice_sivel2_gen_caso_sobre_ubicacion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_sobre_ubicacion_id ON public.sivel2_gen_caso USING btree (ubicacion_id);


--
-- Name: indice_sivel2_gen_categoria_sobre_supracategoria_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_categoria_sobre_supracategoria_id ON public.sivel2_gen_categoria USING btree (supracategoria_id);


--
-- Name: indice_sivel2_sjr_casosjr_on_asesor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_casosjr_on_asesor ON public.sivel2_sjr_casosjr USING btree (asesor);


--
-- Name: indice_sivel2_sjr_casosjr_on_caso_contacto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_casosjr_on_caso_contacto ON public.sivel2_sjr_casosjr USING btree (id_caso, contacto_id);


--
-- Name: indice_sivel2_sjr_casosjr_on_oficina_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_casosjr_on_oficina_id ON public.sivel2_sjr_casosjr USING btree (oficina_id);


--
-- Name: indice_sivel2_sjr_desplazamiento_on_fechaexpulsion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_desplazamiento_on_fechaexpulsion ON public.sivel2_sjr_desplazamiento USING btree (fechaexpulsion);


--
-- Name: indice_sivel2_sjr_desplazamiento_on_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_desplazamiento_on_id_caso ON public.sivel2_sjr_desplazamiento USING btree (id_caso);


--
-- Name: indice_sivel2_sjr_desplazamiento_on_id_llegada; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_desplazamiento_on_id_llegada ON public.sivel2_sjr_desplazamiento USING btree (id_llegada);


--
-- Name: indice_sivel2_sjr_respuesta_on_fechaatencion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_respuesta_on_fechaatencion ON public.sivel2_sjr_respuesta USING btree (fechaatencion);


--
-- Name: sip_busca_mundep; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_busca_mundep ON public.sip_mundep USING gin (mundep);


--
-- Name: sip_nombre_ubicacionpre_b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sip_nombre_ubicacionpre_b ON public.sip_ubicacionpre USING gin (to_tsvector('spanish'::regconfig, public.f_unaccent((nombre)::text)));


--
-- Name: sivel2_gen_obs_fildep_d_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_obs_fildep_d_idx ON public.sivel2_gen_observador_filtrodepartamento USING btree (departamento_id);


--
-- Name: sivel2_gen_obs_fildep_u_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_obs_fildep_u_idx ON public.sivel2_gen_observador_filtrodepartamento USING btree (usuario_id);


--
-- Name: sivel2_sjr_actividad_casosjr_actividad_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_actividad_casosjr_actividad_id_idx ON public.sivel2_sjr_actividad_casosjr USING btree (actividad_id);


--
-- Name: sivel2_sjr_actividad_casosjr_casosjr_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_actividad_casosjr_casosjr_id_idx ON public.sivel2_sjr_actividad_casosjr USING btree (casosjr_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: usuario_nusuario; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX usuario_nusuario ON public.usuario USING btree (nusuario);


--
-- Name: cor1440_gen_actividad actividad_regionsjr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad
    ADD CONSTRAINT actividad_regionsjr_id_fkey FOREIGN KEY (oficina_id) REFERENCES public.sip_oficina(id);


--
-- Name: sivel2_gen_acto acto_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_acto acto_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_acto acto_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_gen_acto acto_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_presponsable_fkey FOREIGN KEY (id_presponsable) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_acto acto_victima_lf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_victima_lf FOREIGN KEY (id_caso, id_persona) REFERENCES public.sivel2_gen_victima(id_caso, id_persona);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES public.sip_grupoper(id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_presponsable_fkey FOREIGN KEY (id_presponsable) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_sjr_actosjr actosjr_desplazamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actosjr
    ADD CONSTRAINT actosjr_desplazamiento_id_fkey FOREIGN KEY (desplazamiento_id) REFERENCES public.sivel2_sjr_desplazamiento(id);


--
-- Name: sivel2_sjr_actosjr actosjr_id_acto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actosjr
    ADD CONSTRAINT actosjr_id_acto_fkey FOREIGN KEY (id_acto) REFERENCES public.sivel2_gen_acto(id);


--
-- Name: sivel2_gen_anexo_caso anexo_fuenteprensa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_fuenteprensa_id_fkey FOREIGN KEY (fuenteprensa_id) REFERENCES public.sip_fuenteprensa(id);


--
-- Name: sivel2_gen_anexo_caso anexo_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_anexo_caso anexo_id_fotra_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_id_fotra_fkey FOREIGN KEY (id_fotra) REFERENCES public.sivel2_gen_fotra(id);


--
-- Name: sivel2_gen_antecedente_caso antecedente_caso_id_antecedente_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_antecedente_fkey1 FOREIGN KEY (id_antecedente) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_caso antecedente_caso_id_caso_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_caso_fkey1 FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_antecedente_combatiente antecedente_combatiente_id_antecedente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_combatiente
    ADD CONSTRAINT antecedente_combatiente_id_antecedente_fkey FOREIGN KEY (id_antecedente) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_combatiente antecedente_combatiente_id_combatiente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_combatiente
    ADD CONSTRAINT antecedente_combatiente_id_combatiente_fkey FOREIGN KEY (id_combatiente) REFERENCES public.sivel2_gen_combatiente(id);


--
-- Name: sivel2_gen_antecedente_victima antecedente_victima_id_antecedente_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_antecedente_fkey1 FOREIGN KEY (id_antecedente) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_victima antecedente_victima_id_victima_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_victima_fkey1 FOREIGN KEY (id_victima) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: sivel2_gen_antecedente_victimacolectiva antecedente_victimacolectiva_id_antecedente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victimacolectiva
    ADD CONSTRAINT antecedente_victimacolectiva_id_antecedente_fkey FOREIGN KEY (id_antecedente) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_victimacolectiva antecedente_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victimacolectiva
    ADD CONSTRAINT antecedente_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_sjr_aslegal_respuesta aslegal_respuesta_id_aslegal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aslegal_respuesta
    ADD CONSTRAINT aslegal_respuesta_id_aslegal_fkey FOREIGN KEY (id_aslegal) REFERENCES public.sivel2_sjr_aslegal(id);


--
-- Name: sivel2_sjr_aslegal_respuesta aslegal_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aslegal_respuesta
    ADD CONSTRAINT aslegal_respuesta_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_sjr_ayudaestado_respuesta ayudaestado_respuesta_id_ayudaestado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado_respuesta
    ADD CONSTRAINT ayudaestado_respuesta_id_ayudaestado_fkey FOREIGN KEY (id_ayudaestado) REFERENCES public.sivel2_sjr_ayudaestado(id);


--
-- Name: sivel2_sjr_ayudaestado_respuesta ayudaestado_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado_respuesta
    ADD CONSTRAINT ayudaestado_respuesta_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_sjr_ayudasjr_respuesta ayudasjr_respuesta_id_ayudasjr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_respuesta
    ADD CONSTRAINT ayudasjr_respuesta_id_ayudasjr_fkey FOREIGN KEY (id_ayudasjr) REFERENCES public.sivel2_sjr_ayudasjr(id);


--
-- Name: sivel2_sjr_ayudasjr_respuesta ayudasjr_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_respuesta
    ADD CONSTRAINT ayudasjr_respuesta_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_gen_caso_categoria_presponsable caso_categoria_presponsable_id_caso_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_caso_presponsable_fkey FOREIGN KEY (id_caso_presponsable) REFERENCES public.sivel2_gen_caso_presponsable(id);


--
-- Name: sivel2_gen_caso_categoria_presponsable caso_categoria_presponsable_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_caso_contexto caso_contexto_id_caso_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_contexto
    ADD CONSTRAINT caso_contexto_id_caso_fkey1 FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_contexto caso_contexto_id_contexto_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_contexto
    ADD CONSTRAINT caso_contexto_id_contexto_fkey1 FOREIGN KEY (id_contexto) REFERENCES public.sivel2_gen_contexto(id);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_etiqueta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_etiqueta_fkey FOREIGN KEY (id_etiqueta) REFERENCES public.sip_etiqueta(id);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id);


--
-- Name: sivel2_gen_caso_fotra caso_fotra_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT caso_fotra_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_fotra caso_fotra_id_fotra_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT caso_fotra_id_fotra_fkey FOREIGN KEY (id_fotra) REFERENCES public.sivel2_gen_fotra(id);


--
-- Name: sivel2_gen_caso_frontera caso_frontera_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_frontera
    ADD CONSTRAINT caso_frontera_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_frontera caso_frontera_id_frontera_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_frontera
    ADD CONSTRAINT caso_frontera_id_frontera_fkey FOREIGN KEY (id_frontera) REFERENCES public.sivel2_gen_frontera(id);


--
-- Name: sivel2_gen_caso_usuario caso_funcionario_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_usuario
    ADD CONSTRAINT caso_funcionario_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_presponsable caso_presponsable_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_presponsable caso_presponsable_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_presponsable_fkey FOREIGN KEY (id_presponsable) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_caso_region caso_region_id_caso_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_region
    ADD CONSTRAINT caso_region_id_caso_fkey1 FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_region caso_region_id_region_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_region
    ADD CONSTRAINT caso_region_id_region_fkey1 FOREIGN KEY (id_region) REFERENCES public.sivel2_gen_region(id);


--
-- Name: sivel2_gen_caso_respuestafor caso_respuestafor_caso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_respuestafor
    ADD CONSTRAINT caso_respuestafor_caso_id_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_respuestafor caso_respuestafor_respuestafor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_respuestafor
    ADD CONSTRAINT caso_respuestafor_respuestafor_id_fkey FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sivel2_gen_caso_usuario caso_usuario_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_usuario
    ADD CONSTRAINT caso_usuario_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_usuario caso_usuario_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_usuario
    ADD CONSTRAINT caso_usuario_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_casosjr casosjr_asesor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_asesor_fkey FOREIGN KEY (asesor) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_casosjr casosjr_categoriaref_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_categoriaref_fkey FOREIGN KEY (categoriaref) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_sjr_casosjr casosjr_comosupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_comosupo_id_fkey FOREIGN KEY (comosupo_id) REFERENCES public.sivel2_sjr_comosupo(id);


--
-- Name: sivel2_sjr_casosjr casosjr_contacto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_contacto_fkey FOREIGN KEY (contacto_id) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_idioma_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_idioma_fkey FOREIGN KEY (id_idioma) REFERENCES public.sivel2_sjr_idioma(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_llegada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_llegada_fkey FOREIGN KEY (id_llegada) REFERENCES public.sip_ubicacion(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_proteccion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_proteccion_fkey FOREIGN KEY (id_proteccion) REFERENCES public.sivel2_sjr_proteccion(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_regionsjr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_regionsjr_fkey FOREIGN KEY (oficina_id) REFERENCES public.sip_oficina(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_salida_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_salida_fkey FOREIGN KEY (id_salida) REFERENCES public.sip_ubicacion(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_statusmigratorio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_statusmigratorio_fkey FOREIGN KEY (id_statusmigratorio) REFERENCES public.sivel2_sjr_statusmigratorio(id);


--
-- Name: sivel2_gen_categoria categoria_contadaen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT categoria_contadaen_fkey FOREIGN KEY (contadaen) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sip_clase clase_id_tclase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT clase_id_tclase_fkey FOREIGN KEY (id_tclase) REFERENCES public.sip_tclase(id);


--
-- Name: sivel2_gen_contextovictima_victima contextovictima_victima_contextovictima_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima_victima
    ADD CONSTRAINT contextovictima_victima_contextovictima_id_fkey FOREIGN KEY (contextovictima_id) REFERENCES public.sivel2_gen_contextovictima(id);


--
-- Name: sivel2_gen_contextovictima_victima contextovictima_victima_victima_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima_victima
    ADD CONSTRAINT contextovictima_victima_victima_id_fkey FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: cor1440_gen_actividad_actividadtipo cor1440_gen_actividad_actividadtipo_actividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_actividadtipo
    ADD CONSTRAINT cor1440_gen_actividad_actividadtipo_actividad_id_fkey FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_actividad_actividadtipo cor1440_gen_actividad_actividadtipo_actividadtipo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_actividadtipo
    ADD CONSTRAINT cor1440_gen_actividad_actividadtipo_actividadtipo_id_fkey FOREIGN KEY (actividadtipo_id) REFERENCES public.cor1440_gen_actividadtipo(id);


--
-- Name: sip_departamento departamento_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT departamento_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sivel2_sjr_derecho_respuesta derecho_respuesta_id_derecho_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_derecho_respuesta
    ADD CONSTRAINT derecho_respuesta_id_derecho_fkey FOREIGN KEY (id_derecho) REFERENCES public.sivel2_sjr_derecho(id);


--
-- Name: sivel2_sjr_derecho_respuesta derecho_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_derecho_respuesta
    ADD CONSTRAINT derecho_respuesta_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_expulsion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_expulsion_fkey FOREIGN KEY (id_expulsion) REFERENCES public.sip_ubicacion(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_expulsion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_expulsion_fkey FOREIGN KEY (id_expulsion) REFERENCES public.sip_ubicacion(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_llegada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_llegada_fkey FOREIGN KEY (id_llegada) REFERENCES public.sip_ubicacion(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_tipodesp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_tipodesp_fkey FOREIGN KEY (id_tipodesp) REFERENCES public.sivel2_sjr_tipodesp(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_llegada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_llegada_fkey FOREIGN KEY (id_llegada) REFERENCES public.sip_ubicacion(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_paisdecl_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_paisdecl_fkey FOREIGN KEY (paisdecl) REFERENCES public.sip_pais(id);


--
-- Name: sivel2_gen_etnia_victimacolectiva etnia_victimacolectiva_etnia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia_victimacolectiva
    ADD CONSTRAINT etnia_victimacolectiva_etnia_id_fkey FOREIGN KEY (etnia_id) REFERENCES public.sivel2_gen_etnia(id);


--
-- Name: sivel2_gen_etnia_victimacolectiva etnia_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia_victimacolectiva
    ADD CONSTRAINT etnia_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_gen_filiacion_victimacolectiva filiacion_victimacolectiva_id_filiacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion_victimacolectiva
    ADD CONSTRAINT filiacion_victimacolectiva_id_filiacion_fkey FOREIGN KEY (id_filiacion) REFERENCES public.sivel2_gen_filiacion(id);


--
-- Name: sivel2_gen_filiacion_victimacolectiva filiacion_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion_victimacolectiva
    ADD CONSTRAINT filiacion_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_gen_anexo_victima fk_rails_003eee651b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_victima
    ADD CONSTRAINT fk_rails_003eee651b FOREIGN KEY (id_anexo) REFERENCES public.sip_anexo(id);


--
-- Name: cor1440_gen_actividad_valorcampotind fk_rails_0104bf757c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_valorcampotind
    ADD CONSTRAINT fk_rails_0104bf757c FOREIGN KEY (valorcampotind_id) REFERENCES public.cor1440_gen_valorcampotind(id);


--
-- Name: sivel2_gen_anexo_victima fk_rails_01da62195c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_victima
    ADD CONSTRAINT fk_rails_01da62195c FOREIGN KEY (id_victima) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: sivel2_sjr_motivosjr_derecho fk_rails_02f5fb9150; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_derecho
    ADD CONSTRAINT fk_rails_02f5fb9150 FOREIGN KEY (derecho_id) REFERENCES public.sivel2_sjr_derecho(id);


--
-- Name: cor1440_gen_anexo_efecto fk_rails_037289a77c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_efecto
    ADD CONSTRAINT fk_rails_037289a77c FOREIGN KEY (efecto_id) REFERENCES public.cor1440_gen_efecto(id);


--
-- Name: cor1440_gen_mindicadorpf fk_rails_06564b910d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_mindicadorpf
    ADD CONSTRAINT fk_rails_06564b910d FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_resultadopf fk_rails_06ba24bd54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_resultadopf
    ADD CONSTRAINT fk_rails_06ba24bd54 FOREIGN KEY (objetivopf_id) REFERENCES public.cor1440_gen_objetivopf(id);


--
-- Name: sip_municipio fk_rails_089870a38d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT fk_rails_089870a38d FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: cor1440_gen_actividad_actividadpf fk_rails_08b9aa072b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_actividadpf
    ADD CONSTRAINT fk_rails_08b9aa072b FOREIGN KEY (actividadpf_id) REFERENCES public.cor1440_gen_actividadpf(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_0b10834ba7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_0b10834ba7 FOREIGN KEY (resultadopf_id) REFERENCES public.cor1440_gen_resultadopf(id);


--
-- Name: cor1440_gen_actividad_respuestafor fk_rails_0b4fb6fceb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_respuestafor
    ADD CONSTRAINT fk_rails_0b4fb6fceb FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_efecto_respuestafor fk_rails_0ba7ab4660; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto_respuestafor
    ADD CONSTRAINT fk_rails_0ba7ab4660 FOREIGN KEY (efecto_id) REFERENCES public.cor1440_gen_efecto(id);


--
-- Name: cor1440_gen_financiador_proyectofinanciero fk_rails_0cd09d688c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_financiador_proyectofinanciero
    ADD CONSTRAINT fk_rails_0cd09d688c FOREIGN KEY (financiador_id) REFERENCES public.cor1440_gen_financiador(id);


--
-- Name: cor1440_gen_mindicadorpf fk_rails_0fbac6136b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_mindicadorpf
    ADD CONSTRAINT fk_rails_0fbac6136b FOREIGN KEY (indicadorpf_id) REFERENCES public.cor1440_gen_indicadorpf(id);


--
-- Name: sivel2_gen_sectorsocialsec_victima fk_rails_0feb0e70eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocialsec_victima
    ADD CONSTRAINT fk_rails_0feb0e70eb FOREIGN KEY (sectorsocial_id) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sip_etiqueta_municipio fk_rails_10d88626c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_10d88626c3 FOREIGN KEY (etiqueta_id) REFERENCES public.sip_etiqueta(id);


--
-- Name: sivel2_gen_caso_presponsable fk_rails_118837ae4c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT fk_rails_118837ae4c FOREIGN KEY (id_presponsable) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: cor1440_gen_caracterizacionpersona fk_rails_119f5dffb4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona
    ADD CONSTRAINT fk_rails_119f5dffb4 FOREIGN KEY (ulteditor_id) REFERENCES public.usuario(id);


--
-- Name: cor1440_gen_efecto_orgsocial fk_rails_12f7139ec8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto_orgsocial
    ADD CONSTRAINT fk_rails_12f7139ec8 FOREIGN KEY (orgsocial_id) REFERENCES public.sip_orgsocial(id);


--
-- Name: cor1440_gen_actividad_rangoedadac fk_rails_1366d14fb8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_rangoedadac
    ADD CONSTRAINT fk_rails_1366d14fb8 FOREIGN KEY (rangoedadac_id) REFERENCES public.cor1440_gen_rangoedadac(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_16d8cc3b46; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_16d8cc3b46 FOREIGN KEY (heredade_id) REFERENCES public.cor1440_gen_actividadpf(id);


--
-- Name: mr519_gen_encuestausuario fk_rails_1b24d10e82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT fk_rails_1b24d10e82 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: heb412_gen_formulario_plantillahcr fk_rails_1bdf79898c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr
    ADD CONSTRAINT fk_rails_1bdf79898c FOREIGN KEY (plantillahcr_id) REFERENCES public.heb412_gen_plantillahcr(id);


--
-- Name: cor1440_gen_efecto fk_rails_1d0050a070; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto
    ADD CONSTRAINT fk_rails_1d0050a070 FOREIGN KEY (registradopor_id) REFERENCES public.usuario(id);


--
-- Name: cor1440_gen_caracterizacionpf fk_rails_1d1caee38f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpf
    ADD CONSTRAINT fk_rails_1d1caee38f FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: heb412_gen_campohc fk_rails_1e5f26c999; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campohc
    ADD CONSTRAINT fk_rails_1e5f26c999 FOREIGN KEY (doc_id) REFERENCES public.heb412_gen_doc(id);


--
-- Name: cor1440_gen_caracterizacionpersona fk_rails_240640f30e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona
    ADD CONSTRAINT fk_rails_240640f30e FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: cor1440_gen_anexo_proyectofinanciero fk_rails_26e56f96f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_proyectofinanciero
    ADD CONSTRAINT fk_rails_26e56f96f9 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_campotind fk_rails_2770ce966d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_campotind
    ADD CONSTRAINT fk_rails_2770ce966d FOREIGN KEY (tipoindicador_id) REFERENCES public.cor1440_gen_tipoindicador(id);


--
-- Name: cor1440_gen_informe fk_rails_294895347e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_294895347e FOREIGN KEY (filtroproyecto) REFERENCES public.cor1440_gen_proyecto(id);


--
-- Name: cor1440_gen_informe fk_rails_2bd685d2b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_2bd685d2b3 FOREIGN KEY (filtroresponsable) REFERENCES public.usuario(id);


--
-- Name: mr519_gen_encuestausuario fk_rails_2cb09d778a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT fk_rails_2cb09d778a FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sip_bitacora fk_rails_2db961766c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_bitacora
    ADD CONSTRAINT fk_rails_2db961766c FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: heb412_gen_doc fk_rails_2dd6d3dac3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_doc
    ADD CONSTRAINT fk_rails_2dd6d3dac3 FOREIGN KEY (dirpapa) REFERENCES public.heb412_gen_doc(id);


--
-- Name: sip_ubicacionpre fk_rails_2e86701dfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_2e86701dfb FOREIGN KEY (departamento_id) REFERENCES public.sip_departamento(id);


--
-- Name: cor1440_gen_actividad_rangoedadac fk_rails_2f8fe7fdca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_rangoedadac
    ADD CONSTRAINT fk_rails_2f8fe7fdca FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_valorcampoact fk_rails_3060a94455; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_valorcampoact
    ADD CONSTRAINT fk_rails_3060a94455 FOREIGN KEY (campoact_id) REFERENCES public.cor1440_gen_campoact(id);


--
-- Name: sivel2_sjr_oficina_proyectofinanciero fk_rails_3479b42b5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_oficina_proyectofinanciero
    ADD CONSTRAINT fk_rails_3479b42b5c FOREIGN KEY (oficina_id) REFERENCES public.sip_oficina(id);


--
-- Name: cor1440_gen_proyectofinanciero fk_rails_3792591d9e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero
    ADD CONSTRAINT fk_rails_3792591d9e FOREIGN KEY (sectorapc_id) REFERENCES public.cor1440_gen_sectorapc(id);


--
-- Name: sivel2_sjr_aspsicosocial_respuesta fk_rails_389ca79c21; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aspsicosocial_respuesta
    ADD CONSTRAINT fk_rails_389ca79c21 FOREIGN KEY (id_respuesta) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf fk_rails_390cd96f7c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti_pmindicadorpf
    ADD CONSTRAINT fk_rails_390cd96f7c FOREIGN KEY (pmindicadorpf_id) REFERENCES public.cor1440_gen_pmindicadorpf(id);


--
-- Name: cor1440_gen_actividad_proyecto fk_rails_395faa0882; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyecto
    ADD CONSTRAINT fk_rails_395faa0882 FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: sip_ubicacionpre fk_rails_3b59c12090; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_3b59c12090 FOREIGN KEY (clase_id) REFERENCES public.sip_clase(id);


--
-- Name: cor1440_gen_informe fk_rails_40cb623d50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_40cb623d50 FOREIGN KEY (filtroproyectofinanciero) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_actividad fk_rails_4426fc905e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad
    ADD CONSTRAINT fk_rails_4426fc905e FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_actividad_casosjr fk_rails_4499c9b012; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actividad_casosjr
    ADD CONSTRAINT fk_rails_4499c9b012 FOREIGN KEY (casosjr_id) REFERENCES public.sivel2_sjr_casosjr(id_caso);


--
-- Name: cor1440_gen_informeauditoria fk_rails_44cf03d3e2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informeauditoria
    ADD CONSTRAINT fk_rails_44cf03d3e2 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sip_orgsocial_persona fk_rails_4672f6cbcd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_persona
    ADD CONSTRAINT fk_rails_4672f6cbcd FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: cor1440_gen_actividad_sip_anexo fk_rails_49ec1ae361; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_sip_anexo
    ADD CONSTRAINT fk_rails_49ec1ae361 FOREIGN KEY (anexo_id) REFERENCES public.sip_anexo(id);


--
-- Name: cor1440_gen_indicadorpf fk_rails_4a0bd96143; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT fk_rails_4a0bd96143 FOREIGN KEY (objetivopf_id) REFERENCES public.cor1440_gen_objetivopf(id);


--
-- Name: sip_ubicacion fk_rails_4dd7a7f238; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT fk_rails_4dd7a7f238 FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: cor1440_gen_efecto fk_rails_4ebe8f74fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto
    ADD CONSTRAINT fk_rails_4ebe8f74fc FOREIGN KEY (indicadorpf_id) REFERENCES public.cor1440_gen_indicadorpf(id);


--
-- Name: cor1440_gen_valorcampotind fk_rails_4f2fc96457; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_valorcampotind
    ADD CONSTRAINT fk_rails_4f2fc96457 FOREIGN KEY (campotind_id) REFERENCES public.cor1440_gen_campotind(id);


--
-- Name: cor1440_gen_caracterizacionpf fk_rails_4fcf0ffb4f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpf
    ADD CONSTRAINT fk_rails_4fcf0ffb4f FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero fk_rails_524486e06b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyectofinanciero
    ADD CONSTRAINT fk_rails_524486e06b FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_54b3e0ed5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_54b3e0ed5c FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: sip_etiqueta_municipio fk_rails_5672729520; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_5672729520 FOREIGN KEY (municipio_id) REFERENCES public.sip_municipio(id);


--
-- Name: cor1440_gen_objetivopf fk_rails_57b4fd8780; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_objetivopf
    ADD CONSTRAINT fk_rails_57b4fd8780 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_formulario_mindicadorpf fk_rails_590a6d182f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_formulario_mindicadorpf
    ADD CONSTRAINT fk_rails_590a6d182f FOREIGN KEY (mindicadorpf_id) REFERENCES public.cor1440_gen_mindicadorpf(id);


--
-- Name: sivel2_gen_caso_presponsable fk_rails_5a8abbdd31; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT fk_rails_5a8abbdd31 FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sip_orgsocial fk_rails_5b21e3a2af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial
    ADD CONSTRAINT fk_rails_5b21e3a2af FOREIGN KEY (grupoper_id) REFERENCES public.sip_grupoper(id);


--
-- Name: cor1440_gen_informenarrativo fk_rails_629d2a2cb8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informenarrativo
    ADD CONSTRAINT fk_rails_629d2a2cb8 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_plantillahcm_proyectofinanciero fk_rails_62c9243a43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_plantillahcm_proyectofinanciero
    ADD CONSTRAINT fk_rails_62c9243a43 FOREIGN KEY (plantillahcm_id) REFERENCES public.heb412_gen_plantillahcm(id);


--
-- Name: sivel2_gen_combatiente fk_rails_6485d06d37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_6485d06d37 FOREIGN KEY (id_vinculoestado) REFERENCES public.sivel2_gen_vinculoestado(id);


--
-- Name: mr519_gen_opcioncs fk_rails_656b4a3ca7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs
    ADD CONSTRAINT fk_rails_656b4a3ca7 FOREIGN KEY (campo_id) REFERENCES public.mr519_gen_campo(id);


--
-- Name: sivel2_sjr_oficina_proyectofinanciero fk_rails_669494cbb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_oficina_proyectofinanciero
    ADD CONSTRAINT fk_rails_669494cbb1 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_datointermedioti fk_rails_669ada0c54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti
    ADD CONSTRAINT fk_rails_669ada0c54 FOREIGN KEY (mindicadorpf_id) REFERENCES public.cor1440_gen_mindicadorpf(id);


--
-- Name: heb412_gen_formulario_plantillahcr fk_rails_696d27d6f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr
    ADD CONSTRAINT fk_rails_696d27d6f5 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: cor1440_gen_caracterizacionpersona fk_rails_6a82dffb63; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona
    ADD CONSTRAINT fk_rails_6a82dffb63 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: heb412_gen_formulario_plantillahcm fk_rails_6e214a7168; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcm
    ADD CONSTRAINT fk_rails_6e214a7168 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: cor1440_gen_actividadpf_mindicadorpf fk_rails_6e9cbecf02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf_mindicadorpf
    ADD CONSTRAINT fk_rails_6e9cbecf02 FOREIGN KEY (mindicadorpf_id) REFERENCES public.cor1440_gen_mindicadorpf(id);


--
-- Name: sip_ubicacion fk_rails_6ed05ed576; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT fk_rails_6ed05ed576 FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: cor1440_gen_pmindicadorpf fk_rails_701d924c54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_pmindicadorpf
    ADD CONSTRAINT fk_rails_701d924c54 FOREIGN KEY (mindicadorpf_id) REFERENCES public.cor1440_gen_mindicadorpf(id);


--
-- Name: cor1440_gen_efecto_orgsocial fk_rails_72ba94182e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto_orgsocial
    ADD CONSTRAINT fk_rails_72ba94182e FOREIGN KEY (efecto_id) REFERENCES public.cor1440_gen_efecto(id);


--
-- Name: sip_grupo_usuario fk_rails_734ee21e62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo_usuario
    ADD CONSTRAINT fk_rails_734ee21e62 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_motivosjr_derecho fk_rails_74442b8f19; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_derecho
    ADD CONSTRAINT fk_rails_74442b8f19 FOREIGN KEY (motivosjr_id) REFERENCES public.sivel2_sjr_motivosjr(id);


--
-- Name: sip_orgsocial fk_rails_7bc2a60574; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial
    ADD CONSTRAINT fk_rails_7bc2a60574 FOREIGN KEY (pais_id) REFERENCES public.sip_pais(id);


--
-- Name: sip_orgsocial_persona fk_rails_7c335482f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_persona
    ADD CONSTRAINT fk_rails_7c335482f6 FOREIGN KEY (orgsocial_id) REFERENCES public.sip_orgsocial(id);


--
-- Name: mr519_gen_respuestafor fk_rails_805efe6935; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor
    ADD CONSTRAINT fk_rails_805efe6935 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: mr519_gen_valorcampo fk_rails_819cf17399; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT fk_rails_819cf17399 FOREIGN KEY (campo_id) REFERENCES public.mr519_gen_campo(id);


--
-- Name: cor1440_gen_tipomoneda fk_rails_82fd06de79; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipomoneda
    ADD CONSTRAINT fk_rails_82fd06de79 FOREIGN KEY (pais_id) REFERENCES public.sip_pais(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_83755e20b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_83755e20b9 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sivel2_gen_caso fk_rails_850036942a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso
    ADD CONSTRAINT fk_rails_850036942a FOREIGN KEY (ubicacion_id) REFERENCES public.sip_ubicacion(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_88eeb03074; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_88eeb03074 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: cor1440_gen_formulario_tipoindicador fk_rails_8978582d8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_formulario_tipoindicador
    ADD CONSTRAINT fk_rails_8978582d8a FOREIGN KEY (tipoindicador_id) REFERENCES public.cor1440_gen_tipoindicador(id);


--
-- Name: cor1440_gen_actividad_orgsocial fk_rails_8ba599a224; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_orgsocial
    ADD CONSTRAINT fk_rails_8ba599a224 FOREIGN KEY (orgsocial_id) REFERENCES public.sip_orgsocial(id);


--
-- Name: mr519_gen_valorcampo fk_rails_8bb7650018; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT fk_rails_8bb7650018 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: cor1440_gen_informefinanciero fk_rails_8bd007af77; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informefinanciero
    ADD CONSTRAINT fk_rails_8bd007af77 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sip_grupo_usuario fk_rails_8d24f7c1c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_grupo_usuario
    ADD CONSTRAINT fk_rails_8d24f7c1c0 FOREIGN KEY (sip_grupo_id) REFERENCES public.sip_grupo(id);


--
-- Name: sip_departamento fk_rails_92093de1a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_departamento
    ADD CONSTRAINT fk_rails_92093de1a1 FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sivel2_sjr_ayudasjr_derecho fk_rails_93fdde2014; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_derecho
    ADD CONSTRAINT fk_rails_93fdde2014 FOREIGN KEY (derecho_id) REFERENCES public.sivel2_sjr_derecho(id);


--
-- Name: cor1440_gen_resultadopf fk_rails_95485cfc7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_resultadopf
    ADD CONSTRAINT fk_rails_95485cfc7a FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_efecto_respuestafor fk_rails_95a3aff09f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto_respuestafor
    ADD CONSTRAINT fk_rails_95a3aff09f FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sivel2_gen_combatiente fk_rails_95f4a0b8f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_95f4a0b8f6 FOREIGN KEY (id_profesion) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sip_orgsocial_sectororgsocial fk_rails_9f61a364e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_9f61a364e0 FOREIGN KEY (sectororgsocial_id) REFERENCES public.sip_sectororgsocial(id);


--
-- Name: mr519_gen_campo fk_rails_a186e1a8a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo
    ADD CONSTRAINT fk_rails_a186e1a8a0 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: sip_ubicacion fk_rails_a1d509c79a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT fk_rails_a1d509c79a FOREIGN KEY (id_clase) REFERENCES public.sip_clase(id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero fk_rails_a8489e0d62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyectofinanciero
    ADD CONSTRAINT fk_rails_a8489e0d62 FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_actividad_respuestafor fk_rails_abc0cafc05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_respuestafor
    ADD CONSTRAINT fk_rails_abc0cafc05 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: cor1440_gen_beneficiariopf fk_rails_ac70e973ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_beneficiariopf
    ADD CONSTRAINT fk_rails_ac70e973ee FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sivel2_gen_combatiente fk_rails_af43e915a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_af43e915a6 FOREIGN KEY (id_filiacion) REFERENCES public.sivel2_gen_filiacion(id);


--
-- Name: sivel2_sjr_actividad_casosjr fk_rails_b2461f538f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actividad_casosjr
    ADD CONSTRAINT fk_rails_b2461f538f FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_indicadorpf fk_rails_b5b70fb7f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT fk_rails_b5b70fb7f7 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sip_ubicacion fk_rails_b82283d945; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT fk_rails_b82283d945 FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: cor1440_gen_actividad_actividadpf fk_rails_baad271930; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_actividadpf
    ADD CONSTRAINT fk_rails_baad271930 FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_anexo_efecto fk_rails_bcd8d7b7ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_efecto
    ADD CONSTRAINT fk_rails_bcd8d7b7ad FOREIGN KEY (anexo_id) REFERENCES public.sip_anexo(id);


--
-- Name: sivel2_gen_combatiente fk_rails_bfb49597e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_bfb49597e1 FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: cor1440_gen_informe fk_rails_c02831dd89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_c02831dd89 FOREIGN KEY (filtroactividadarea) REFERENCES public.cor1440_gen_actividadarea(id);


--
-- Name: sip_ubicacionpre fk_rails_c08a606417; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_c08a606417 FOREIGN KEY (municipio_id) REFERENCES public.sip_municipio(id);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf fk_rails_c5ec912cc3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti_pmindicadorpf
    ADD CONSTRAINT fk_rails_c5ec912cc3 FOREIGN KEY (datointermedioti_id) REFERENCES public.cor1440_gen_datointermedioti(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_c68e2278b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_c68e2278b2 FOREIGN KEY (actividadtipo_id) REFERENCES public.cor1440_gen_actividadtipo(id);


--
-- Name: cor1440_gen_proyectofinanciero_usuario fk_rails_c6f8d7af05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero_usuario
    ADD CONSTRAINT fk_rails_c6f8d7af05 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sip_ubicacionpre fk_rails_c8024a90df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_c8024a90df FOREIGN KEY (tsitio_id) REFERENCES public.sip_tsitio(id);


--
-- Name: cor1440_gen_desembolso fk_rails_c858edd00a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_desembolso
    ADD CONSTRAINT fk_rails_c858edd00a FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_financiador_proyectofinanciero fk_rails_ca93eb04dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_financiador_proyectofinanciero
    ADD CONSTRAINT fk_rails_ca93eb04dc FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: usuario fk_rails_cc636858ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_rails_cc636858ad FOREIGN KEY (tema_id) REFERENCES public.sip_tema(id);


--
-- Name: cor1440_gen_actividad_sip_anexo fk_rails_cc9d44f9de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_sip_anexo
    ADD CONSTRAINT fk_rails_cc9d44f9de FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_campoact fk_rails_ceb6f1a7f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_campoact
    ADD CONSTRAINT fk_rails_ceb6f1a7f0 FOREIGN KEY (actividadtipo_id) REFERENCES public.cor1440_gen_actividadtipo(id);


--
-- Name: cor1440_gen_actividad_proyecto fk_rails_cf5d592625; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyecto
    ADD CONSTRAINT fk_rails_cf5d592625 FOREIGN KEY (proyecto_id) REFERENCES public.cor1440_gen_proyecto(id);


--
-- Name: cor1440_gen_indicadorpf fk_rails_cf888d1b56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT fk_rails_cf888d1b56 FOREIGN KEY (tipoindicador_id) REFERENCES public.cor1440_gen_tipoindicador(id);


--
-- Name: sivel2_sjr_progestado_derecho fk_rails_cff2ad554d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_derecho
    ADD CONSTRAINT fk_rails_cff2ad554d FOREIGN KEY (derecho_id) REFERENCES public.sivel2_sjr_derecho(id);


--
-- Name: cor1440_gen_actividadpf_mindicadorpf fk_rails_cfff77ad98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf_mindicadorpf
    ADD CONSTRAINT fk_rails_cfff77ad98 FOREIGN KEY (actividadpf_id) REFERENCES public.cor1440_gen_actividadpf(id);


--
-- Name: cor1440_gen_proyectofinanciero fk_rails_d0ff83bfc6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero
    ADD CONSTRAINT fk_rails_d0ff83bfc6 FOREIGN KEY (tipomoneda_id) REFERENCES public.cor1440_gen_tipomoneda(id);


--
-- Name: cor1440_gen_indicadorpf fk_rails_d264d408b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT fk_rails_d264d408b0 FOREIGN KEY (resultadopf_id) REFERENCES public.cor1440_gen_resultadopf(id);


--
-- Name: cor1440_gen_plantillahcm_proyectofinanciero fk_rails_d56d245f70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_plantillahcm_proyectofinanciero
    ADD CONSTRAINT fk_rails_d56d245f70 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_informe fk_rails_daf0af8605; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_daf0af8605 FOREIGN KEY (filtrooficina) REFERENCES public.sip_oficina(id);


--
-- Name: cor1440_gen_proyectofinanciero_usuario fk_rails_dc664c3eaf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero_usuario
    ADD CONSTRAINT fk_rails_dc664c3eaf FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_gen_sectorsocialsec_victima fk_rails_e04ef7c3e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocialsec_victima
    ADD CONSTRAINT fk_rails_e04ef7c3e5 FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: cor1440_gen_formulario_mindicadorpf fk_rails_e07a0a8650; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_formulario_mindicadorpf
    ADD CONSTRAINT fk_rails_e07a0a8650 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: heb412_gen_campoplantillahcm fk_rails_e0e38e0782; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcm
    ADD CONSTRAINT fk_rails_e0e38e0782 FOREIGN KEY (plantillahcm_id) REFERENCES public.heb412_gen_plantillahcm(id);


--
-- Name: sivel2_gen_combatiente fk_rails_e2d01a5a99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_e2d01a5a99 FOREIGN KEY (id_sectorsocial) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: cor1440_gen_valorcampoact fk_rails_e36cf046d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_valorcampoact
    ADD CONSTRAINT fk_rails_e36cf046d1 FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: sivel2_sjr_ayudasjr_derecho fk_rails_e645a3e73c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_derecho
    ADD CONSTRAINT fk_rails_e645a3e73c FOREIGN KEY (ayudasjr_id) REFERENCES public.sivel2_sjr_ayudasjr(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_e69a8b5822; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_e69a8b5822 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: cor1440_gen_beneficiariopf fk_rails_e6ba73556e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_beneficiariopf
    ADD CONSTRAINT fk_rails_e6ba73556e FOREIGN KEY (persona_id) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_sjr_aspsicosocial_respuesta fk_rails_e8410c8faa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aspsicosocial_respuesta
    ADD CONSTRAINT fk_rails_e8410c8faa FOREIGN KEY (id_aspsicosocial) REFERENCES public.sivel2_sjr_aspsicosocial(id);


--
-- Name: sivel2_sjr_progestado_derecho fk_rails_e8743fd8f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_derecho
    ADD CONSTRAINT fk_rails_e8743fd8f6 FOREIGN KEY (progestado_id) REFERENCES public.sivel2_sjr_progestado(id);


--
-- Name: cor1440_gen_actividad_valorcampotind fk_rails_e8cd697f5d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_valorcampotind
    ADD CONSTRAINT fk_rails_e8cd697f5d FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: heb412_gen_carpetaexclusiva fk_rails_ea1add81e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_carpetaexclusiva
    ADD CONSTRAINT fk_rails_ea1add81e6 FOREIGN KEY (grupo_id) REFERENCES public.sip_grupo(id);


--
-- Name: sip_ubicacionpre fk_rails_eba8cc9124; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacionpre
    ADD CONSTRAINT fk_rails_eba8cc9124 FOREIGN KEY (pais_id) REFERENCES public.sip_pais(id);


--
-- Name: cor1440_gen_actividad_orgsocial fk_rails_ecdad5c731; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_orgsocial
    ADD CONSTRAINT fk_rails_ecdad5c731 FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: sip_orgsocial_sectororgsocial fk_rails_f032bb21a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_f032bb21a6 FOREIGN KEY (orgsocial_id) REFERENCES public.sip_orgsocial(id);


--
-- Name: sivel2_gen_combatiente fk_rails_f0cf2a7bec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_f0cf2a7bec FOREIGN KEY (id_resagresion) REFERENCES public.sivel2_gen_resagresion(id);


--
-- Name: cor1440_gen_actividadtipo_formulario fk_rails_f17af6bf9c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadtipo_formulario
    ADD CONSTRAINT fk_rails_f17af6bf9c FOREIGN KEY (actividadtipo_id) REFERENCES public.cor1440_gen_actividadtipo(id);


--
-- Name: cor1440_gen_datointermedioti fk_rails_f2e0ba2f26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti
    ADD CONSTRAINT fk_rails_f2e0ba2f26 FOREIGN KEY (tipoindicador_id) REFERENCES public.cor1440_gen_tipoindicador(id);


--
-- Name: sivel2_gen_combatiente fk_rails_f77dda7a40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_f77dda7a40 FOREIGN KEY (id_organizacion) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_f941b0c512; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_f941b0c512 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_actividadtipo_formulario fk_rails_faf663ab7f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadtipo_formulario
    ADD CONSTRAINT fk_rails_faf663ab7f FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: sivel2_gen_combatiente fk_rails_fb02819ec4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_fb02819ec4 FOREIGN KEY (id_rangoedad) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: sip_clase fk_rails_fb09f016e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT fk_rails_fb09f016e4 FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: heb412_gen_formulario_plantillahcm fk_rails_fc3149fc44; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcm
    ADD CONSTRAINT fk_rails_fc3149fc44 FOREIGN KEY (plantillahcm_id) REFERENCES public.heb412_gen_plantillahcm(id);


--
-- Name: cor1440_gen_formulario_tipoindicador fk_rails_fd2fbcd1b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_formulario_tipoindicador
    ADD CONSTRAINT fk_rails_fd2fbcd1b8 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: cor1440_gen_anexo_proyectofinanciero fk_rails_fd94296801; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_proyectofinanciero
    ADD CONSTRAINT fk_rails_fd94296801 FOREIGN KEY (anexo_id) REFERENCES public.sip_anexo(id);


--
-- Name: cor1440_gen_proyectofinanciero lf_proyectofinanciero_responsable; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero
    ADD CONSTRAINT lf_proyectofinanciero_responsable FOREIGN KEY (responsable_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_motivosjr_respuesta motivosjr_respuesta_id_motivosjr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_respuesta
    ADD CONSTRAINT motivosjr_respuesta_id_motivosjr_fkey FOREIGN KEY (id_motivosjr) REFERENCES public.sivel2_sjr_motivosjr(id);


--
-- Name: sivel2_sjr_motivosjr_respuesta motivosjr_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_respuesta
    ADD CONSTRAINT motivosjr_respuesta_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_gen_organizacion_victimacolectiva organizacion_victimacolectiva_id_organizacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion_victimacolectiva
    ADD CONSTRAINT organizacion_victimacolectiva_id_organizacion_fkey FOREIGN KEY (id_organizacion) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: sivel2_gen_organizacion_victimacolectiva organizacion_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion_victimacolectiva
    ADD CONSTRAINT organizacion_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sip_persona persona_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sip_persona persona_nacionalde_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_nacionalde_fkey FOREIGN KEY (nacionalde) REFERENCES public.sip_pais(id);


--
-- Name: sip_persona persona_tdocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT persona_tdocumento_id_fkey FOREIGN KEY (tdocumento_id) REFERENCES public.sip_tdocumento(id);


--
-- Name: sip_persona_trelacion persona_trelacion_id_trelacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_id_trelacion_fkey FOREIGN KEY (id_trelacion) REFERENCES public.sip_trelacion(id);


--
-- Name: sip_persona_trelacion persona_trelacion_persona1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona1_fkey FOREIGN KEY (persona1) REFERENCES public.sip_persona(id);


--
-- Name: sip_persona_trelacion persona_trelacion_persona2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona2_fkey FOREIGN KEY (persona2) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_gen_presponsable presponsable_papa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_presponsable
    ADD CONSTRAINT presponsable_papa_fkey FOREIGN KEY (papa_id) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_profesion_victimacolectiva profesion_victimacolectiva_id_profesion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victimacolectiva
    ADD CONSTRAINT profesion_victimacolectiva_id_profesion_fkey FOREIGN KEY (id_profesion) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sivel2_gen_profesion_victimacolectiva profesion_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victimacolectiva
    ADD CONSTRAINT profesion_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_sjr_progestado_respuesta progestado_respuesta_id_progestado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_respuesta
    ADD CONSTRAINT progestado_respuesta_id_progestado_fkey FOREIGN KEY (id_progestado) REFERENCES public.sivel2_sjr_progestado(id);


--
-- Name: sivel2_sjr_progestado_respuesta progestado_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_respuesta
    ADD CONSTRAINT progestado_respuesta_id_respuesta_fkey FOREIGN KEY (id_respuesta) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva rangoedad_victimacolectiva_id_rangoedad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad_victimacolectiva
    ADD CONSTRAINT rangoedad_victimacolectiva_id_rangoedad_fkey FOREIGN KEY (id_rangoedad) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva rangoedad_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad_victimacolectiva
    ADD CONSTRAINT rangoedad_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_sjr_respuesta respuesta_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_respuesta
    ADD CONSTRAINT respuesta_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_sjr_casosjr(id_caso);


--
-- Name: sivel2_sjr_respuesta respuesta_id_personadesea_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_respuesta
    ADD CONSTRAINT respuesta_id_personadesea_fkey FOREIGN KEY (id_personadesea) REFERENCES public.sivel2_sjr_personadesea(id);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva sectorsocial_victimacolectiva_id_sectorsocial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial_victimacolectiva
    ADD CONSTRAINT sectorsocial_victimacolectiva_id_sectorsocial_fkey FOREIGN KEY (id_sectorsocial) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva sectorsocial_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial_victimacolectiva
    ADD CONSTRAINT sectorsocial_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sip_clase sip_clase_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_clase
    ADD CONSTRAINT sip_clase_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sip_municipio sip_municipio_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_municipio
    ADD CONSTRAINT sip_municipio_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: sip_persona sip_persona_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT sip_persona_id_clase_fkey FOREIGN KEY (id_clase) REFERENCES public.sip_clase(id);


--
-- Name: sip_persona sip_persona_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT sip_persona_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: sip_persona sip_persona_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_persona
    ADD CONSTRAINT sip_persona_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sip_ubicacion sip_ubicacion_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT sip_ubicacion_id_clase_fkey FOREIGN KEY (id_clase) REFERENCES public.sip_clase(id);


--
-- Name: sip_ubicacion sip_ubicacion_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT sip_ubicacion_id_departamento_fkey FOREIGN KEY (id_departamento) REFERENCES public.sip_departamento(id);


--
-- Name: sip_ubicacion sip_ubicacion_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT sip_ubicacion_id_municipio_fkey FOREIGN KEY (id_municipio) REFERENCES public.sip_municipio(id);


--
-- Name: sivel2_gen_caso_fotra sivel2_gen_caso_fotra_anexo_caso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT sivel2_gen_caso_fotra_anexo_caso_id_fkey FOREIGN KEY (anexo_caso_id) REFERENCES public.sivel2_gen_anexo_caso(id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_anexo_caso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_anexo_caso_id_fkey FOREIGN KEY (anexo_caso_id) REFERENCES public.sivel2_gen_anexo_caso(id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_fuenteprensa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_fuenteprensa_id_fkey FOREIGN KEY (fuenteprensa_id) REFERENCES public.sip_fuenteprensa(id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_categoria sivel2_gen_categoria_supracategoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT sivel2_gen_categoria_supracategoria_id_fkey FOREIGN KEY (supracategoria_id) REFERENCES public.sivel2_gen_supracategoria(id);


--
-- Name: sivel2_gen_observador_filtrodepartamento sivel2_gen_observador_filtrodepartamento_d_idx; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_observador_filtrodepartamento
    ADD CONSTRAINT sivel2_gen_observador_filtrodepartamento_d_idx FOREIGN KEY (departamento_id) REFERENCES public.sip_departamento(id);


--
-- Name: sivel2_gen_observador_filtrodepartamento sivel2_gen_observador_filtrodepartamento_u_idx; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_observador_filtrodepartamento
    ADD CONSTRAINT sivel2_gen_observador_filtrodepartamento_u_idx FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_gen_supracategoria supracategoria_id_tviolencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT supracategoria_id_tviolencia_fkey FOREIGN KEY (id_tviolencia) REFERENCES public.sivel2_gen_tviolencia(id);


--
-- Name: sip_ubicacion ubicacion_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sip_ubicacion ubicacion_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sip_ubicacion ubicacion_id_tsitio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sip_ubicacion
    ADD CONSTRAINT ubicacion_id_tsitio_fkey FOREIGN KEY (id_tsitio) REFERENCES public.sip_tsitio(id);


--
-- Name: sivel2_sjr_casosjr vcontacto_lfor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT vcontacto_lfor FOREIGN KEY (id_caso, contacto_id) REFERENCES public.sivel2_gen_victima(id_caso, id_persona);


--
-- Name: sivel2_gen_victima victima_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_victima victima_id_etnia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_etnia_fkey FOREIGN KEY (id_etnia) REFERENCES public.sivel2_gen_etnia(id);


--
-- Name: sivel2_gen_victima victima_id_iglesia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_iglesia_fkey FOREIGN KEY (id_iglesia) REFERENCES public.sivel2_gen_iglesia(id);


--
-- Name: sivel2_gen_victima victima_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.sip_persona(id);


--
-- Name: sivel2_gen_victima victima_id_profesion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_profesion_fkey FOREIGN KEY (id_profesion) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sivel2_gen_victima victima_id_rangoedad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_rangoedad_fkey FOREIGN KEY (id_rangoedad) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: sivel2_gen_victima victima_id_sectorsocial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_sectorsocial_fkey FOREIGN KEY (id_sectorsocial) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sivel2_gen_victima victima_organizacionarmada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_organizacionarmada_fkey FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_victimacolectiva victimacolectiva_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_victimacolectiva victimacolectiva_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES public.sip_grupoper(id);


--
-- Name: sivel2_gen_victimacolectiva victimacolectiva_organizacionarmada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_organizacionarmada_fkey FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado victimacolectiva_vinculoestado_id_vinculoestado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva_vinculoestado
    ADD CONSTRAINT victimacolectiva_vinculoestado_id_vinculoestado_fkey FOREIGN KEY (id_vinculoestado) REFERENCES public.sivel2_gen_vinculoestado(id);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado victimacolectiva_vinculoestado_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva_vinculoestado
    ADD CONSTRAINT victimacolectiva_vinculoestado_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_actividadoficio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_actividadoficio_fkey FOREIGN KEY (id_actividadoficio) REFERENCES public.sivel2_gen_actividadoficio(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_escolaridad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_escolaridad_fkey FOREIGN KEY (id_escolaridad) REFERENCES public.sivel2_gen_escolaridad(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_estadocivil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_estadocivil_fkey FOREIGN KEY (id_estadocivil) REFERENCES public.sivel2_gen_estadocivil(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_maternidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_maternidad_fkey FOREIGN KEY (id_maternidad) REFERENCES public.sivel2_gen_maternidad(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.sip_pais(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_rolfamilia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_rolfamilia_fkey FOREIGN KEY (id_rolfamilia) REFERENCES public.sivel2_sjr_rolfamilia(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_victima_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_victima_fkey FOREIGN KEY (id_victima) REFERENCES public.sivel2_gen_victima(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20131128151014'),
('20131204135932'),
('20131204140000'),
('20131204143718'),
('20131204183530'),
('20131205233111'),
('20131206081531'),
('20131210221541'),
('20131220103409'),
('20131223175141'),
('20140117212555'),
('20140129151136'),
('20140207102709'),
('20140207102739'),
('20140211162355'),
('20140211164659'),
('20140211172443'),
('20140217100541'),
('20140313012209'),
('20140317121823'),
('20140514142421'),
('20140518120059'),
('20140527110223'),
('20140528043115'),
('20140611111020'),
('20140613044320'),
('20140613200951'),
('20140620112004'),
('20140704035033'),
('20140804194616'),
('20140804200235'),
('20140804202100'),
('20140804202101'),
('20140804202958'),
('20140804210000'),
('20140805030341'),
('20140814184537'),
('20140815111351'),
('20140815111352'),
('20140815121224'),
('20140815123542'),
('20140815124157'),
('20140815124606'),
('20140827142659'),
('20140901105741'),
('20140901106000'),
('20140902101425'),
('20140904033941'),
('20140904211823'),
('20140904213327'),
('20140905121420'),
('20140909141336'),
('20140909165233'),
('20140918115412'),
('20140922102737'),
('20140922110956'),
('20141002140242'),
('20141111102451'),
('20141111203313'),
('20141112111129'),
('20141126085907'),
('20141222174237'),
('20141222174247'),
('20141222174257'),
('20141222174267'),
('20141225174739'),
('20150213114933'),
('20150217185859'),
('20150225140336'),
('20150313153722'),
('20150317084149'),
('20150317084737'),
('20150317090631'),
('20150413000000'),
('20150413160156'),
('20150413160157'),
('20150413160158'),
('20150413160159'),
('20150416074423'),
('20150416090140'),
('20150416095646'),
('20150416101228'),
('20150417071153'),
('20150417180000'),
('20150417180314'),
('20150419000000'),
('20150420104520'),
('20150420110000'),
('20150420125522'),
('20150420153835'),
('20150420200255'),
('20150503120915'),
('20150510125926'),
('20150513112126'),
('20150513130058'),
('20150513130510'),
('20150513160835'),
('20150520115257'),
('20150521092657'),
('20150521181918'),
('20150521191227'),
('20150528100944'),
('20150602094513'),
('20150602095241'),
('20150602104342'),
('20150609094809'),
('20150609094815'),
('20150609094820'),
('20150612160810'),
('20150612203808'),
('20150615024318'),
('20150616095023'),
('20150616100351'),
('20150616100551'),
('20150624200701'),
('20150707164448'),
('20150709203137'),
('20150710012947'),
('20150710114451'),
('20150716085420'),
('20150716171420'),
('20150716192356'),
('20150717101243'),
('20150717161539'),
('20150720115701'),
('20150720120236'),
('20150724003736'),
('20150724024110'),
('20150803082520'),
('20150809032138'),
('20150826000000'),
('20150929112313'),
('20151006105402'),
('20151020203420'),
('20151020203421'),
('20151030094611'),
('20151124110943'),
('20151127102425'),
('20151130101417'),
('20160308213334'),
('20160316093659'),
('20160316094627'),
('20160316100620'),
('20160316100621'),
('20160316100622'),
('20160316100623'),
('20160316100624'),
('20160316100625'),
('20160316100626'),
('20160519195544'),
('20160719195853'),
('20160719214520'),
('20160724160049'),
('20160724164110'),
('20160725123242'),
('20160725125929'),
('20160725131347'),
('20160805103310'),
('20161009111443'),
('20161010152631'),
('20161026110802'),
('20161027233011'),
('20161103080156'),
('20161103081041'),
('20161103083352'),
('20161108102349'),
('20170405104322'),
('20170406213334'),
('20170413185012'),
('20170414035328'),
('20170503145808'),
('20170526100040'),
('20170526124219'),
('20170526131129'),
('20170529020218'),
('20170529154413'),
('20170607125033'),
('20170609131212'),
('20170712205819'),
('20171011212156'),
('20171011213037'),
('20171011213405'),
('20171011213548'),
('20171019133203'),
('20171128234148'),
('20171130125044'),
('20171130133741'),
('20171212001011'),
('20171217135318'),
('20180126035129'),
('20180126055129'),
('20180212223621'),
('20180219032546'),
('20180220103644'),
('20180220104234'),
('20180223091622'),
('20180225152848'),
('20180307125759'),
('20180320230847'),
('20180427194732'),
('20180509111948'),
('20180519102415'),
('20180611222635'),
('20180612024009'),
('20180612030340'),
('20180626123640'),
('20180627031905'),
('20180717134314'),
('20180717135811'),
('20180718094829'),
('20180719015902'),
('20180720140443'),
('20180720171842'),
('20180724135332'),
('20180724202353'),
('20180726213123'),
('20180726234755'),
('20180801105304'),
('20180810220807'),
('20180810221619'),
('20180812220011'),
('20180813110808'),
('20180905031342'),
('20180905031617'),
('20180910132139'),
('20180912114413'),
('20180914153010'),
('20180914170936'),
('20180917072914'),
('20180918195008'),
('20180918195821'),
('20180920031351'),
('20180921120954'),
('20181011104537'),
('20181012110629'),
('20181017094456'),
('20181018003945'),
('20181111181411'),
('20181113025055'),
('20181130112320'),
('20181213103204'),
('20181218165548'),
('20181218165559'),
('20181218215222'),
('20181219085236'),
('20181224112813'),
('20181227093834'),
('20181227094559'),
('20181227095037'),
('20181227100523'),
('20181227114431'),
('20181227210510'),
('20181228014507'),
('20190109125417'),
('20190110191802'),
('20190111092816'),
('20190111102201'),
('20190116133230'),
('20190128032125'),
('20190205203619'),
('20190206005635'),
('20190208103518'),
('20190225143501'),
('20190308195346'),
('20190322102311'),
('20190326150948'),
('20190331111015'),
('20190401175521'),
('20190403202049'),
('20190406141156'),
('20190406164301'),
('20190418011743'),
('20190418014012'),
('20190418123920'),
('20190418142712'),
('20190426125052'),
('20190426131119'),
('20190430112229'),
('20190603213842'),
('20190603234145'),
('20190605143420'),
('20190612101211'),
('20190612111043'),
('20190612113734'),
('20190612198000'),
('20190612200000'),
('20190613155738'),
('20190613155843'),
('20190618135559'),
('20190625112649'),
('20190625140232'),
('20190703044126'),
('20190715083916'),
('20190715182611'),
('20190718032712'),
('20190726203302'),
('20190804223012'),
('20190818013251'),
('20190924013712'),
('20190924112646'),
('20190926104116'),
('20190926104551'),
('20190926133640'),
('20190926143845'),
('20190926165901'),
('20190926170423'),
('20191012014000'),
('20191012014823'),
('20191012042159'),
('20191016100031'),
('20191205200007'),
('20191205202150'),
('20191205204511'),
('20191219011910'),
('20191231102721'),
('20200116003807'),
('20200211105331'),
('20200211112230'),
('20200212103617'),
('20200221181049'),
('20200224134339'),
('20200228235200'),
('20200229005951'),
('20200302194744'),
('20200314033958'),
('20200319183515'),
('20200320152017'),
('20200324164130'),
('20200326212919'),
('20200327004702'),
('20200330174434'),
('20200330180854'),
('20200331210411'),
('20200411094012'),
('20200411095105'),
('20200411100013'),
('20200415021859'),
('20200415102103'),
('20200422103916'),
('20200427091939'),
('20200430101709'),
('20200522142932'),
('20200622193241'),
('20200706113547'),
('20200720005020'),
('20200720013144'),
('20200722210144'),
('20200723133542'),
('20200727021707'),
('20200802112451'),
('20200810164753'),
('20200907165157'),
('20200907174303'),
('20200916022934'),
('20200919003430'),
('20200921123831'),
('20201009004421'),
('20201031182132'),
('20201119125643'),
('20201121162913'),
('20201130020715'),
('20201201015501'),
('20201205041350'),
('20201205213317'),
('20201214215209'),
('20201231194433'),
('20210108202122'),
('20210116090353'),
('20210116104426'),
('20210117234541'),
('20210201101144'),
('20210201112227'),
('20210202144410'),
('20210202201520'),
('20210202201530'),
('20210206191033'),
('20210226155035'),
('20210308183041'),
('20210308211112'),
('20210308214507'),
('20210401194637'),
('20210401210102'),
('20210414201956'),
('20210417152053'),
('20210419161145'),
('20210428143811'),
('20210430160739'),
('20210514201449'),
('20210524121112'),
('20210531223906'),
('20210601023450'),
('20210601023557'),
('20210608180736'),
('20210609024118'),
('20210614120835'),
('20210614212220'),
('20210616003251'),
('20210619191706'),
('20210727111355'),
('20210728214424'),
('20210730120340'),
('20210823162356'),
('20210823162357'),
('20210924022913'),
('20211011214752'),
('20211011233005'),
('20211019121200');


