--
-- PostgreSQL database dump
--

-- Dumped from database version 12.8 (Debian 12.8-1.pgdg100+1)
-- Dumped by pg_dump version 12.18 (Ubuntu 12.18-0ubuntu0.20.04.1)

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

DROP DATABASE sig;
--
-- Name: sig; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE sig WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';


\connect sig

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
-- Name: sig; Type: DATABASE PROPERTIES; Schema: -; Owner: -
--

ALTER DATABASE sig SET search_path TO 'public', 'topology';


\connect sig

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
-- Name: sit_hydre; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA sit_hydre;


--
-- Name: urba_plui_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA urba_plui_public;


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: gest_bdd_contact_referents; Type: TABLE; Schema: sit_hydre; Owner: -
--

CREATE TABLE sit_hydre.gest_bdd_contact_referents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nom text NOT NULL,
    prenom text NOT NULL,
    mail text NOT NULL
);


--
-- Name: gest_bdd_objets; Type: TABLE; Schema: sit_hydre; Owner: -
--

CREATE TABLE sit_hydre.gest_bdd_objets (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nom_objet text NOT NULL,
    type_objet text NOT NULL,
    descriptions text,
    proprietaire text,
    proprio_ldap text,
    acces_communes boolean DEFAULT false,
    rgpd boolean DEFAULT false,
    schema_id uuid
);


--
-- Name: gest_bdd_rel_objets_thematique; Type: TABLE; Schema: sit_hydre; Owner: -
--

CREATE TABLE sit_hydre.gest_bdd_rel_objets_thematique (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    objet_id uuid NOT NULL,
    thematique_id uuid NOT NULL,
    metadonnees_id uuid DEFAULT public.uuid_generate_v4(),
    metadonnees_lien text,
    metadonnees_titre text,
    metadonnees_commentaire text,
    metadonnees jsonb DEFAULT (json_build_object('themes_inspire', NULL::unknown, 'mots_clefs', NULL::unknown, 'categories', NULL::unknown, 'licences', NULL::unknown))::jsonb,
    metadonnees_contact jsonb DEFAULT (json_build_object('nom', NULL::unknown, 'prenom', NULL::unknown, 'mail', NULL::unknown, 'adresse', NULL::unknown, 'role', NULL::unknown))::jsonb,
    niveau smallint
);


--
-- Name: COLUMN gest_bdd_rel_objets_thematique.niveau; Type: COMMENT; Schema: sit_hydre; Owner: -
--

COMMENT ON COLUMN sit_hydre.gest_bdd_rel_objets_thematique.niveau IS 'Niveau de la thématique 1 = principale 2 = sous-thématique ...';


--
-- Name: gest_bdd_rel_thematique_contact_referents; Type: TABLE; Schema: sit_hydre; Owner: -
--

CREATE TABLE sit_hydre.gest_bdd_rel_thematique_contact_referents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    thematique_id uuid NOT NULL,
    contact_referent_id uuid NOT NULL,
    type_ref text NOT NULL
);


--
-- Name: gest_bdd_schemas; Type: TABLE; Schema: sit_hydre; Owner: -
--

CREATE TABLE sit_hydre.gest_bdd_schemas (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nom_schema text NOT NULL,
    description text,
    public boolean DEFAULT false,
    proprietaire text NOT NULL
);


--
-- Name: gest_bdd_thematique; Type: TABLE; Schema: sit_hydre; Owner: -
--

CREATE TABLE sit_hydre.gest_bdd_thematique (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    thematique text NOT NULL,
    description text,
    metadonnees jsonb DEFAULT (json_build_object('themes_inspire', NULL::unknown, 'mots_clefs', NULL::unknown, 'categories', NULL::unknown))::jsonb,
    id_thematique uuid
);


--
-- Name: COLUMN gest_bdd_thematique.id_thematique; Type: COMMENT; Schema: sit_hydre; Owner: -
--

COMMENT ON COLUMN sit_hydre.gest_bdd_thematique.id_thematique IS 'identifiant de la thématique mère';


--
-- Name: temp_rel_thematique_schema; Type: TABLE; Schema: sit_hydre; Owner: -
--

CREATE TABLE sit_hydre.temp_rel_thematique_schema (
    schema character varying,
    thematique character varying,
    id_thematique uuid,
    id_schema uuid
);


--
-- Name: v_liste_metadonnees; Type: VIEW; Schema: sit_hydre; Owner: -
--

CREATE VIEW sit_hydre.v_liste_metadonnees AS
 SELECT gest_bdd_rel_objets_thematique.metadonnees_id,
    (gest_bdd_rel_objets_thematique.metadonnees ->> 'categorie'::text) AS categorie,
    (gest_bdd_rel_objets_thematique.metadonnees ->> 'licences'::text) AS licences,
    (gest_bdd_rel_objets_thematique.metadonnees ->> 'mots_clefs'::text) AS mots_clefs,
    (gest_bdd_rel_objets_thematique.metadonnees ->> 'themes_inspire'::text) AS themes_inspire
   FROM sit_hydre.gest_bdd_rel_objets_thematique;


--
-- Name: v_liste_metadonnees_contactes; Type: VIEW; Schema: sit_hydre; Owner: -
--

CREATE VIEW sit_hydre.v_liste_metadonnees_contactes AS
 SELECT gest_bdd_rel_objets_thematique.metadonnees_id,
    (gest_bdd_rel_objets_thematique.metadonnees_contact ->> 'nom'::text) AS nom,
    (gest_bdd_rel_objets_thematique.metadonnees_contact ->> 'mail'::text) AS mail,
    (gest_bdd_rel_objets_thematique.metadonnees_contact ->> 'role'::text) AS role,
    (gest_bdd_rel_objets_thematique.metadonnees_contact ->> 'prenom'::text) AS prenom,
    (gest_bdd_rel_objets_thematique.metadonnees_contact ->> 'adresse'::text) AS adresse
   FROM sit_hydre.gest_bdd_rel_objets_thematique;


--
-- Name: v_liste_nom_schema_objet; Type: VIEW; Schema: sit_hydre; Owner: -
--

CREATE VIEW sit_hydre.v_liste_nom_schema_objet AS
 SELECT objets.id AS id_objet,
    gest_bdd_schemas.nom_schema,
    objets.nom_objet
   FROM (sit_hydre.gest_bdd_objets objets
     JOIN sit_hydre.gest_bdd_schemas ON ((objets.schema_id = gest_bdd_schemas.id)))
  WHERE (gest_bdd_schemas.public IS TRUE);


--
-- Name: v_liste_nom_schema_objet_thema_meta; Type: VIEW; Schema: sit_hydre; Owner: -
--

CREATE VIEW sit_hydre.v_liste_nom_schema_objet_thema_meta AS
 SELECT objets.id AS id_objet,
    rel_ob_th.metadonnees_id,
    sc.nom_schema,
    objets.nom_objet,
    th.thematique
   FROM (((sit_hydre.gest_bdd_objets objets
     JOIN sit_hydre.gest_bdd_schemas sc ON ((objets.schema_id = sc.id)))
     JOIN sit_hydre.gest_bdd_rel_objets_thematique rel_ob_th ON ((objets.id = rel_ob_th.objet_id)))
     JOIN sit_hydre.gest_bdd_thematique th ON ((rel_ob_th.thematique_id = th.id)));


--
-- Name: plan_2_c2_inf_99_decheterie_surf; Type: TABLE; Schema: urba_plui_public; Owner: -
--

CREATE TABLE urba_plui_public.plan_2_c2_inf_99_decheterie_surf (
    idinformation integer NOT NULL,
    idurba character varying(30),
    libelle character varying(254),
    txt character varying(10),
    typeinf character varying(2),
    nomfic character varying(80),
    urlfic character varying(254),
    datevalid date,
    stypeinf character varying(5),
    lib_cnig_epci text,
    lib_code_insee text,
    lib_etiquette text,
    lib_idinfo text,
    lib_labeling_positionx text,
    lib_labeling_positiony text,
    lib_legende text,
    lib_modif text,
    lib_modif_comment text,
    geom public.geometry(Polygon,3945)
);


--
-- Name: plan_b3_psc_02_captage_pct; Type: TABLE; Schema: urba_plui_public; Owner: -
--

CREATE TABLE urba_plui_public.plan_b3_psc_02_captage_pct (
    idprescription integer NOT NULL,
    idurba character varying(30),
    libelle character varying(254),
    txt character varying(10),
    typepsc character(2),
    nomfic character varying(80),
    urlfic character varying(254),
    datevalid date,
    stypepsc character varying(5),
    lib_cnig_epci text,
    lib_code_insee text,
    lib_etiquette text,
    lib_idpsc text,
    lib_labeling_positionx text,
    lib_labeling_positiony text,
    lib_legende text,
    lib_modif text,
    lib_modif_comment text,
    geom public.geometry(Point,3945)
);


--
-- Name: plan_b3_psc_18_oap_air_lin; Type: TABLE; Schema: urba_plui_public; Owner: -
--

CREATE TABLE urba_plui_public.plan_b3_psc_18_oap_air_lin (
    idprescription integer NOT NULL,
    idurba character varying(30),
    libelle character varying(254),
    txt character varying(10),
    typepsc character(2),
    nomfic character varying(80),
    urlfic character varying(254),
    datevalid date,
    stypepsc character varying(5),
    lib_cnig_epci text,
    lib_code_insee text,
    lib_etiquette text,
    lib_idpsc text,
    lib_labeling_positionx text,
    lib_labeling_positiony text,
    lib_legende text,
    lib_modif text,
    lib_modif_comment text,
    geom public.geometry(LineString,3945)
);


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: gest_bdd_contact_referents; Type: TABLE DATA; Schema: sit_hydre; Owner: -
--

COPY sit_hydre.gest_bdd_contact_referents (id, nom, prenom, mail) FROM stdin;
\.


--
-- Data for Name: gest_bdd_objets; Type: TABLE DATA; Schema: sit_hydre; Owner: -
--

COPY sit_hydre.gest_bdd_objets (id, nom_objet, type_objet, descriptions, proprietaire, proprio_ldap, acces_communes, rgpd, schema_id) FROM stdin;
78acade9-448b-4371-9b82-7ab43610aea0	plan_4_b_inf_07_reseau_chaleur_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
6fe8fe02-7ebe-4df7-bc53-bd069c654373	plan_6_b_inf_30_pup_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
9d11477f-4c1a-4d31-a4e6-c54b38365396	v_prescriptionurbatype	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
c55e2d75-7fcd-419c-a667-e8f542eb9809	plan_4_b_inf_25_paen_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
cdf6bbd7-5222-4b83-a029-56cf6d573cb2	plan_2_a1_inf_19_eau_potable_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
aa4870c3-e810-42e2-8b4a-ce974f374fd1	plan_a_psc_16_chgt_destination_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
2e4acdca-9758-4c07-b807-46a1fc4d8dcf	plan_4_b_inf_09_mine_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
05cd1b2a-2e4f-40b4-b223-4f51451cc607	plan_b2_psc_02_perim_minier_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
ceb8446b-db74-461d-8ab7-59a315ae68fc	plan_5_b_inf_04_dpur_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
9348492d-9d40-480d-a764-4cb7a9eab1d0	plan_8_a_inf_16_archeo_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
c787bd77-26e2-42a7-b598-0f22156434ca	plan_b3_psc_18_oap_air_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
8ce71261-1940-4b64-9514-4bae9a1a8e97	plan_f2_psc_01_ebc_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
a85d61b0-9326-4b6f-879a-7688652dbc39	plan_b1_psc_02_ppri_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
77087fad-f5f6-4248-97cf-97abe7b4b35f	carroyage_a0_2500	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
6af73799-41b5-41c4-acfb-94c98af6ec56	plan_2_c2_inf_99_decheterie_pct	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
56a27369-96a7-412b-ae77-6021ee4f7fde	plan_b3_psc_02_captage_pct	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
bd618af4-3090-4ed5-aa06-f5532821eb86	plan_b1_psc_02_alea_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
dd624538-9740-4524-b5ad-c0ded95d398c	plan_d1_psc_15_pfu_implantation_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
c599927e-0ec9-4622-af71-64231ab10447	plan_b3_psc_02_apac_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
3c96a6e7-4dad-4948-b315-cf4bceef4e29	plan_f2_psc_01_ebc_pct	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
7a977c98-b6dc-4435-b188-4362f06456b2	plan_8_c_inf_99_bati_agricole_pct	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
ed3211fe-8411-40ac-82cd-1d5860dffbac	plan_6_b_inf_13_pae_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
c51936fd-979a-48ee-a445-6889ba3ced29	plan_f2_psc_07_patrimoine_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
d312438a-82c6-4e0d-9761-e22a617aa7e9	plan_99_na_inf_99_zone_urbanisee_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
41106058-c536-4510-9d39-d38aa25ff2bd	plan_b2_psc_02_pprt_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
151fafda-89c8-45e9-b85a-0ff0399b0406	plan_b1_psc_02_bde_prec_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
78958362-8a96-453c-96c2-122b9ff84854	plan_f2_inf_99_monuments_historiques_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
2fc40ce2-9d50-4e53-976c-d3a2eb46316d	plan_j_psc_05_er_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
39856775-28f2-47b0-bad4-f48af7105df4	plan_j_psc_28_condition_desserte_pct	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
4663863e-9e19-4dda-b25e-8748f20efcb5	plan_a_psc_26_perf_energetique_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
79e3533b-6848-4e76-b415-a1d85ec8f7fd	plan_d1_psc_15_pfu_implantation_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
2456e4bb-3d4e-4a06-a498-1dd6c6ae3d87	plan_b3_psc_47_assainissement_collectif_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
2321555d-ac06-4190-87d7-ed0968838465	plan_b2_psc_02_autre_risque_techno_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
835137dd-01b1-4aae-a019-f79a6d70560d	plan_c1_psc_22_mix_commerciale_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
24261d12-c9e9-4e9e-b6fb-3d0084699f1c	plan_b1_psc_02_depot_sonnant_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
ca8bbb51-82c3-4a1d-a9c1-8b2f44e48930	plan_2_b1_inf_19_assainissement_pct	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
307d7bed-546c-4345-8489-4075e3302a56	plan_f2_psc_01_ebc_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
aa9a3ab5-4d2d-48af-8262-170e39e0248e	plan_3_c_inf_27_peb_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
fd71573b-8e35-47df-a44e-43b436110505	plan_6_b_inf_32_tam_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
9b91c1ca-b60e-4a08-8330-726659b2e9ad	plan_4_b_inf_08_boisement_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
99cb68e6-9263-4676-bdf8-54060346b5c5	carroyage_a0_5000	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
8fe49aee-aa6f-4ccb-b9c3-f60239b21900	plan_f2_psc_07_patrimoine_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
f8fdfba2-1b92-4dcc-90ea-f6bc2a3bd64a	plan_3_c_inf_14_classement_sonore_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
6b15ce4b-3f9b-4f98-a79a-852cddac919d	plan_8_c_inf_99_bati_agricole_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
fbb98518-b328-448e-a70a-a7a9317bd4b8	plan_9_inf_20_rlpi_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
2496ce56-43d5-42af-bc82-74e6b6f0d044	plan_4_b_inf_99_reserve_naturelle_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
de650a02-5ed1-4a8e-a662-ea40abab8c0f	informationurbatype	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
59aaa40f-c53b-43cb-a017-6a4af282c122	plan_c1_psc_22_mix_commerciale_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
e04cb471-897a-40d6-856b-89ffff37dd7e	plan_2_c2_inf_99_decheterie_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
5948470c-eb3a-49ea-8e12-13322e883d73	plan_b1_psc_02_pprn_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
82a9a7d5-549a-4c45-b073-6d199cd80ea8	v_informationurbatype	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
62a61d16-a038-405e-b642-ae4917ec8a7e	plan_a_psc_02_constr_limitee_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
ab7de1a2-637c-4c9b-9444-70aa64873f32	plan_2_a1_inf_19_eau_potable_pct	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
be2a4bee-5bf6-4c32-9cdd-9ba1d2c1d475	plan_h_psc_44_stationnement_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
8425fe06-4a33-4517-ac6f-92558b8b3966	plan_d1_psc_42_pfu_biotope_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
b470094c-cbc8-457b-aec9-3768992df18a	plan_f2_psc_07_patrimoine_pct	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
3aa7f54c-eceb-4e35-8282-c6e0366b7e72	plan_g1_psc_14_plan_masse_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
326dc6b8-7017-4a65-a712-111cfd5d058b	plan_6_b_inf_02_zac_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
1f5eff81-083c-4d88-b62e-554a8dd8c2ec	plan_b3_psc_02_captage_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
f215a514-73d6-4e20-ac22-dd0055af7129	parcelle_planche	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
15f6dace-778d-4cf6-a739-3ef27030d9a6	plan_c1_psc_37_mix_fonctionnelle_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
591716e3-1a83-4592-9b9c-ce92c399a484	carroyage_a3_2500_paysage	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
95840272-f6a5-4496-9870-1929c9127e38	plan_g1_psc_05_papa_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
c958c7ec-dd5c-490d-a6f2-849064f6a53f	plan_e_psc_29_intensification_urbaine_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
b2a2e7a1-4901-47e6-8cff-818dc5a146f5	plan_c2_psc_05_ers_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
c8810bb6-67c2-438e-9bb7-d2dd87cded42	carroyage_a3_5000_paysage	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
fc356bad-2da4-4322-8add-7d8767c7a4ba	plan_3_c_inf_14_classement_sonore_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
b99f610b-f1b4-4b57-af63-63caa9b4256c	prescriptionurbatype	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
98334b58-b07d-4a3d-ab9f-4b2968f82632	plan_g1_psc_18_oap_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
7c4bd358-4919-4473-b0d0-16ed4e20cf2d	plan_6_b_inf_12_perim_sursis_statuer_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
e740863d-71d8-4bcf-91e0-2fa5e9da7aac	plan_f2_psc_25_cours_eau_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
727fd260-a427-4a09-ab88-b8c9559bbfa9	plan_c2_psc_17_sms_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
2bcb8db4-a0c4-4a11-805d-fc3ee30584db	plan_d2_psc_39_pfu_hauteur_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
00c9097a-a734-4e72-9815-c5072c869b87	plan_a_psc_19_carriere_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
72ba382d-18bf-45c1-b237-fdb828c2aef2	plan_2_b1_inf_19_assainissement_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
8b73e648-fd9a-47a6-80ba-24f28498d3ba	plan_4_b_inf_38_sis_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
8c27117a-2c9d-4069-92f3-14be5c7c12ab	plan_f1_psc_18_oap_paysages_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
899a8d1c-c0a8-4a9d-b3e9-e0ec235f180e	plan_d2_psc_39_pfu_hauteur_lin	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
ce98c513-6d6b-4720-8d09-4457aff11f95	plan_b2_psc_02_tmd_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
55f0e259-6ccb-46c0-8054-75df8a310818	plan_4_b_inf_37_regime_forestier_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
fe275838-5326-4b39-8c09-fa8fb838b79f	plan_a_zoneurba	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
85d86044-41b6-41dd-bee5-a3e358f70e8b	plan_b3_psc_18_oap_air_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
ada082c6-e65b-4cde-b8f2-b73e78fc5cfc	plan_5_b_inf_05_zad_surf	table	\N	apps-base centrale sit-admin	\N	f	f	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
\.


--
-- Data for Name: gest_bdd_rel_objets_thematique; Type: TABLE DATA; Schema: sit_hydre; Owner: -
--

COPY sit_hydre.gest_bdd_rel_objets_thematique (id, objet_id, thematique_id, metadonnees_id, metadonnees_lien, metadonnees_titre, metadonnees_commentaire, metadonnees, metadonnees_contact, niveau) FROM stdin;
653fff45-ffe9-4b7c-a033-bed691afc983	be2a4bee-5bf6-4c32-9cdd-9ba1d2c1d475	8b58e822-cbc5-4f95-8af5-0dc007a0a440	0c46a160-7b5d-4595-9dcb-04a4e062d574	\N		\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
b42adb74-d72f-45df-b393-57f83bbf3896	5948470c-eb3a-49ea-8e12-13322e883d73	8b58e822-cbc5-4f95-8af5-0dc007a0a440	6b291b01-824e-4801-83c1-7dd26ba7d38f	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/6b291b01-824e-4801-83c1-7dd26ba7d38f	02_PPRN	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
2e5269ae-55f4-45fc-ac2f-b6be088a7747	fe275838-5326-4b39-8c09-fa8fb838b79f	8b58e822-cbc5-4f95-8af5-0dc007a0a440	1031e99c-cd4d-444c-8be9-82848956c599	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/1031e99c-cd4d-444c-8be9-82848956c599	Zonage	\N	{"licences": "Licence ouverte (OpenDATA)", "categories": ["planningCadastre", "utilitiesCommunication"], "mots_clefs": ["PLUI GAM", " zonage réglementaire"], "themes_inspire": ["Géologie", "Usage des sols"]}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
1d01ed42-7e95-48eb-b071-47e6102e2e7f	b2a2e7a1-4901-47e6-8cff-818dc5a146f5	8b58e822-cbc5-4f95-8af5-0dc007a0a440	5cc3f593-561c-4452-8ae1-8e0c7d774ce8	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/5cc3f593-561c-4452-8ae1-8e0c7d774ce8	05_ER mixité sociale	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
0a8b15ea-c379-491d-980a-0abd40785fb3	00c9097a-a734-4e72-9815-c5072c869b87	8b58e822-cbc5-4f95-8af5-0dc007a0a440	e225416c-de95-49bd-b698-3936f2142bb2	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/e225416c-de95-49bd-b698-3936f2142bb2	19_Carrière protégée	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
af007b39-5457-4477-8f7d-20aa239a0939	151fafda-89c8-45e9-b85a-0ff0399b0406	8b58e822-cbc5-4f95-8af5-0dc007a0a440	e65bb96c-d02b-4346-ab34-897533ef7f5f	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/e65bb96c-d02b-4346-ab34-897533ef7f5f	02_Bande de précaution	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
16a6f686-afbc-4060-9a49-e80ac92da912	aa4870c3-e810-42e2-8b4a-ce974f374fd1	8b58e822-cbc5-4f95-8af5-0dc007a0a440	5d5c3130-b578-42fd-8330-a704d0cb1e43	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/5d5c3130-b578-42fd-8330-a704d0cb1e43	16_Bâtiment changement de destination	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
dc07a8bc-d947-4a5d-819b-f6925bd4053d	a85d61b0-9326-4b6f-879a-7688652dbc39	8b58e822-cbc5-4f95-8af5-0dc007a0a440	83e79802-d87a-458c-9150-7017aae8272a	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/83e79802-d87a-458c-9150-7017aae8272a	02_PPRI	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
fba36703-d653-44a9-b11a-e141d7d221db	4663863e-9e19-4dda-b25e-8748f20efcb5	8b58e822-cbc5-4f95-8af5-0dc007a0a440	26acecc5-15d4-49cb-b5bf-5a8fa470ee0e	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/26acecc5-15d4-49cb-b5bf-5a8fa470ee0e	26_Secteur à performances énergétiques	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
b1888af1-c7cd-4785-8763-b919690a5952	24261d12-c9e9-4e9e-b6fb-3d0084699f1c	8b58e822-cbc5-4f95-8af5-0dc007a0a440	0f0ebf8d-6f85-426a-b243-1db36e389d00	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/0f0ebf8d-6f85-426a-b243-1db36e389d00	02_Dépôt sonnant	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
eef84f2e-1ad1-45d0-958a-dff95a87dc4e	bd618af4-3090-4ed5-aa06-f5532821eb86	8b58e822-cbc5-4f95-8af5-0dc007a0a440	a64b1d86-c664-4d80-91a0-89a7604fce9c	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/a64b1d86-c664-4d80-91a0-89a7604fce9c	02_Aléa	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
17651559-01d9-461a-8a46-4a1bbf3abe39	62a61d16-a038-405e-b642-ae4917ec8a7e	8b58e822-cbc5-4f95-8af5-0dc007a0a440	0341f309-5f91-4382-85f3-2ecffedb7f49	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/0341f309-5f91-4382-85f3-2ecffedb7f49	02_Secteur de constructibilité limitée	\N	{"licences": "Licence ouverte (OpenDATA)", "categories": ["planningCadastre"], "mots_clefs": null, "themes_inspire": ["Usage des sols"]}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
b6a6d9b0-801d-41fa-b44e-d6ce01b98dc7	2321555d-ac06-4190-87d7-ed0968838465	8b58e822-cbc5-4f95-8af5-0dc007a0a440	13ff2ec9-1c2d-48f5-94da-8474ba35fb3c	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/13ff2ec9-1c2d-48f5-94da-8474ba35fb3c	02_Autres risques techno	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
94b49837-199c-442f-a6a6-d1f82a508723	ce98c513-6d6b-4720-8d09-4457aff11f95	8b58e822-cbc5-4f95-8af5-0dc007a0a440	bb77c72c-8445-4675-bf63-1e9b987b2029	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/bb77c72c-8445-4675-bf63-1e9b987b2029	02_Transport de matière dangereuses	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
9b06553c-b3f9-4769-bedc-9d139ea149b5	41106058-c536-4510-9d39-d38aa25ff2bd	8b58e822-cbc5-4f95-8af5-0dc007a0a440	fbce7a6f-8748-45bd-bac6-57d82f20ebe5	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/fbce7a6f-8748-45bd-bac6-57d82f20ebe5	02_PPRT	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
b475bf88-7688-459f-8793-f2bc0e6ccc98	05cd1b2a-2e4f-40b4-b223-4f51451cc607	8b58e822-cbc5-4f95-8af5-0dc007a0a440	34693c8c-bcb2-4266-abd5-66a74d675b3c	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/34693c8c-bcb2-4266-abd5-66a74d675b3c	02_Périmètre minier	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
5a744736-2af0-4a37-ba90-37e463e91cb3	727fd260-a427-4a09-ab88-b8c9559bbfa9	8b58e822-cbc5-4f95-8af5-0dc007a0a440	3b69794c-09c9-4a04-9cbd-aa55656f4583	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/3b69794c-09c9-4a04-9cbd-aa55656f4583	17_Secteur à programme de logements mixité sociale	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
0a4a9a1c-439c-4b32-9a62-f99ba3194890	9d11477f-4c1a-4d31-a4e6-c54b38365396	8b58e822-cbc5-4f95-8af5-0dc007a0a440	6b068c2f-c7f2-4fd9-8eac-58247d894434	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
69f5aa86-21c5-421a-8c51-ae6e0941237e	c55e2d75-7fcd-419c-a667-e8f542eb9809	8b58e822-cbc5-4f95-8af5-0dc007a0a440	3dbb0019-e264-4a13-905e-348f60e0814c	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
dd803e7e-1c33-48d8-9499-ac0a95ef99f3	cdf6bbd7-5222-4b83-a029-56cf6d573cb2	8b58e822-cbc5-4f95-8af5-0dc007a0a440	eefe8731-dace-4613-bf3f-f03533271322	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
17337997-f164-4fc7-95b3-b7e4fdab64f6	ceb8446b-db74-461d-8ab7-59a315ae68fc	8b58e822-cbc5-4f95-8af5-0dc007a0a440	f4c4c410-65eb-48c3-bff3-d1f797d3fcff	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
f0cac46e-c594-42a3-807b-9f9c7dab96b9	c787bd77-26e2-42a7-b598-0f22156434ca	8b58e822-cbc5-4f95-8af5-0dc007a0a440	2cf5c306-448a-4aab-aaa1-561b715765e1	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
6c43cba7-2aa3-4bb6-aa1d-240800e230e6	8ce71261-1940-4b64-9514-4bae9a1a8e97	8b58e822-cbc5-4f95-8af5-0dc007a0a440	b7d90456-216c-4858-b2d7-7bf7a366a7d9	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
8dd12288-e4c9-4a51-ace0-32821453e2e8	77087fad-f5f6-4248-97cf-97abe7b4b35f	8b58e822-cbc5-4f95-8af5-0dc007a0a440	7b551f7f-e057-40b1-adbd-1b66e461e7af	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
4b99dd24-b693-4d77-b50c-6df5f6bd0c23	56a27369-96a7-412b-ae77-6021ee4f7fde	8b58e822-cbc5-4f95-8af5-0dc007a0a440	269f8f0c-7695-43f3-9239-f6e39eba59fd	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
f0a6dfef-eaaf-4d9e-bdb0-86eabdeadf33	dd624538-9740-4524-b5ad-c0ded95d398c	8b58e822-cbc5-4f95-8af5-0dc007a0a440	7f8ba2ab-cb09-4e91-b9a2-192f5ab0760b	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
0cbb2d79-26c8-4579-8261-bdcafa2381f3	c599927e-0ec9-4622-af71-64231ab10447	8b58e822-cbc5-4f95-8af5-0dc007a0a440	5d7f1291-8011-4a41-a4c3-f5b553be1646	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
93d95162-5247-4924-8746-00a6dbddfc94	3c96a6e7-4dad-4948-b315-cf4bceef4e29	8b58e822-cbc5-4f95-8af5-0dc007a0a440	c3519f5c-b199-460c-8fd1-e71fd3319d11	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
e0d3ae9e-d232-4d20-b2dc-75ca136c8bb9	7a977c98-b6dc-4435-b188-4362f06456b2	8b58e822-cbc5-4f95-8af5-0dc007a0a440	46b59747-5ac0-4ed6-9c3c-1e761714f173	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
57b23ae5-6b6b-4ee4-ba4f-35c337e031c2	d312438a-82c6-4e0d-9761-e22a617aa7e9	8b58e822-cbc5-4f95-8af5-0dc007a0a440	cbc9963f-9bb4-414f-9f08-77aeccc8c499	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
e88b9b0b-2b6b-4e9e-9c7f-06ddbed9f53f	78958362-8a96-453c-96c2-122b9ff84854	8b58e822-cbc5-4f95-8af5-0dc007a0a440	e9bcfe79-ef1b-41f0-81df-ae3edd654f32	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
bda428fa-c356-41b3-90c2-543f0a598dbc	2fc40ce2-9d50-4e53-976c-d3a2eb46316d	8b58e822-cbc5-4f95-8af5-0dc007a0a440	5a1246c7-5879-42a2-a54c-d89557b3561f	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
95fb1d69-a024-48a6-a53a-7e5c36d2b524	39856775-28f2-47b0-bad4-f48af7105df4	8b58e822-cbc5-4f95-8af5-0dc007a0a440	c396a5e4-1236-4cec-8af3-a2bc0d7f8bf2	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
d3d05bb8-cf5a-4895-856f-81ca3836b19f	79e3533b-6848-4e76-b415-a1d85ec8f7fd	8b58e822-cbc5-4f95-8af5-0dc007a0a440	289aca69-c494-4c3a-b3fb-26497d0e5f22	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
53ac45fe-6862-4a3c-9362-8d310d6a289d	2456e4bb-3d4e-4a06-a498-1dd6c6ae3d87	8b58e822-cbc5-4f95-8af5-0dc007a0a440	b4b1eada-bed6-466e-a2ab-d1ae220ed87b	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
b65d2934-3900-40c8-9fea-4cf9913d1846	835137dd-01b1-4aae-a019-f79a6d70560d	8b58e822-cbc5-4f95-8af5-0dc007a0a440	194d7a23-2b2e-4131-a253-f3bf433dfc28	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
9cb2186c-bab1-4016-ad3e-c2bdda062f45	307d7bed-546c-4345-8489-4075e3302a56	8b58e822-cbc5-4f95-8af5-0dc007a0a440	4e6c1161-ca06-4f4a-84d2-4ae841771df2	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
f47e4a26-aa92-4b3c-8b69-caee238bebba	9b91c1ca-b60e-4a08-8330-726659b2e9ad	8b58e822-cbc5-4f95-8af5-0dc007a0a440	a111a3c4-83f4-4a5d-b8e6-f1fdb970fcfb	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
a2037127-be75-451d-97fe-50a59aeb6fb4	99cb68e6-9263-4676-bdf8-54060346b5c5	8b58e822-cbc5-4f95-8af5-0dc007a0a440	bc9d3866-a66d-4d2a-89e1-aff32f3ff2f7	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
773c0c66-cef8-4744-8798-ca6b39136ff0	6b15ce4b-3f9b-4f98-a79a-852cddac919d	8b58e822-cbc5-4f95-8af5-0dc007a0a440	8ce41e93-9d8b-4ba4-ba6e-742f06621575	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
90a1be79-97d1-48f3-9209-16c575f37f4d	fbb98518-b328-448e-a70a-a7a9317bd4b8	8b58e822-cbc5-4f95-8af5-0dc007a0a440	572101ad-2b10-4a44-b886-a91f71ec10c4	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
0f124cec-59d1-4ce9-ae39-200fede7c5e9	2496ce56-43d5-42af-bc82-74e6b6f0d044	8b58e822-cbc5-4f95-8af5-0dc007a0a440	d6a41f38-3b77-4f43-86a0-25855235a98e	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
6c0cafcf-95b4-4067-b8d9-d2907dac52ad	de650a02-5ed1-4a8e-a662-ea40abab8c0f	8b58e822-cbc5-4f95-8af5-0dc007a0a440	3767f380-e291-4eeb-9503-86d83f41650a	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
caf8b51d-7192-4c81-90c8-e1cd022c9ada	59aaa40f-c53b-43cb-a017-6a4af282c122	8b58e822-cbc5-4f95-8af5-0dc007a0a440	0955d06d-7229-4d94-b3be-08a6dc13fca9	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
478020d0-55c4-4fc0-b264-1dbad1afbf2f	82a9a7d5-549a-4c45-b073-6d199cd80ea8	8b58e822-cbc5-4f95-8af5-0dc007a0a440	4645f993-1485-474f-97d4-20245f2af07f	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
594efb7f-a40a-4622-8a8d-e0b520db2a25	ab7de1a2-637c-4c9b-9444-70aa64873f32	8b58e822-cbc5-4f95-8af5-0dc007a0a440	819d147f-02a0-443f-b9a9-3f610eb84ddb	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
1a21a95a-2504-43f8-be1b-2b0234f16b97	8425fe06-4a33-4517-ac6f-92558b8b3966	8b58e822-cbc5-4f95-8af5-0dc007a0a440	7cf002ce-01aa-483f-b434-1a686b7dda83	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
2910f416-6c31-4f85-87eb-3cda1a26b4b2	326dc6b8-7017-4a65-a712-111cfd5d058b	8b58e822-cbc5-4f95-8af5-0dc007a0a440	734b6590-c37a-4cd3-affe-63188ed3d9ad	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
a11c39b7-b3f2-408a-a173-bea7a104e4a5	1f5eff81-083c-4d88-b62e-554a8dd8c2ec	8b58e822-cbc5-4f95-8af5-0dc007a0a440	e03c7de7-1098-48f7-85b4-d6cecde19a71	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
b0962c03-9279-49f8-bdb9-bc76408258ca	f215a514-73d6-4e20-ac22-dd0055af7129	8b58e822-cbc5-4f95-8af5-0dc007a0a440	d321bb68-e4ae-4cce-9a7f-33c8a1686f35	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
037551a0-d6c3-4ca5-8e6a-7c1f3d6097ee	15f6dace-778d-4cf6-a739-3ef27030d9a6	8b58e822-cbc5-4f95-8af5-0dc007a0a440	29cac9f8-4c3a-4044-8252-62d3f9fb7815	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
069a1985-dd78-4467-992c-413ace859dd3	591716e3-1a83-4592-9b9c-ce92c399a484	8b58e822-cbc5-4f95-8af5-0dc007a0a440	735ba959-87b0-4960-b360-6459f85b143f	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
dbf76889-24c8-4403-9cea-865f63f7c7c9	c958c7ec-dd5c-490d-a6f2-849064f6a53f	8b58e822-cbc5-4f95-8af5-0dc007a0a440	2402bb2b-ed02-4f94-86b6-aaec2f8c7a44	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
35b3d73e-6ee7-4b30-942f-0d84b0212ecb	c8810bb6-67c2-438e-9bb7-d2dd87cded42	8b58e822-cbc5-4f95-8af5-0dc007a0a440	954d53f0-435f-42d7-b458-c3a744258a2a	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
b7fb4171-7ca9-4518-9826-176cd7ccaed5	fc356bad-2da4-4322-8add-7d8767c7a4ba	8b58e822-cbc5-4f95-8af5-0dc007a0a440	96322852-ced7-4139-8522-a2454a2dd57f	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
2a04588d-c7f8-40b6-8f3d-e94d69ca803f	b99f610b-f1b4-4b57-af63-63caa9b4256c	8b58e822-cbc5-4f95-8af5-0dc007a0a440	083882a3-c7db-49c0-b635-d1a8e2cdeb1c	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
4e4ec7b4-47d7-439c-af57-88e7399ae7c4	98334b58-b07d-4a3d-ab9f-4b2968f82632	8b58e822-cbc5-4f95-8af5-0dc007a0a440	cb48b3ff-4680-4cd7-a66e-14cf0d252384	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
002ff2f0-d1d8-4696-abe1-8144aa3ba522	2bcb8db4-a0c4-4a11-805d-fc3ee30584db	8b58e822-cbc5-4f95-8af5-0dc007a0a440	1c8acca3-57ff-4b46-85e7-c87b497c1454	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
978300f3-6b36-494a-b0ff-1abeaf52287b	72ba382d-18bf-45c1-b237-fdb828c2aef2	8b58e822-cbc5-4f95-8af5-0dc007a0a440	bd799c19-bc98-499f-b61b-b3e4abfcf6b4	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
4aea1423-69e6-4fac-800e-e14766249785	8b73e648-fd9a-47a6-80ba-24f28498d3ba	8b58e822-cbc5-4f95-8af5-0dc007a0a440	6fae5c78-4cf8-417c-b8e3-d41855921221	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
4a4cee44-2de1-4dd6-9bcc-b81063d3235e	8c27117a-2c9d-4069-92f3-14be5c7c12ab	8b58e822-cbc5-4f95-8af5-0dc007a0a440	b1d3edd4-a01c-4130-9d5c-23aca2aa7fb9	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
05fe22b4-4e9f-4aa9-8ca0-edcbb8c3b4a0	899a8d1c-c0a8-4a9d-b3e9-e0ec235f180e	8b58e822-cbc5-4f95-8af5-0dc007a0a440	cd9aaac0-cc3e-44ce-91d6-76c74a3bb910	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
a5b9146f-1dbd-4984-9550-46c68dc899a9	55f0e259-6ccb-46c0-8054-75df8a310818	8b58e822-cbc5-4f95-8af5-0dc007a0a440	1a4414dd-254b-46bc-a1e7-00eedc818d90	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
9c96096a-251b-4cf4-a104-02a161cb6c9e	85d86044-41b6-41dd-bee5-a3e358f70e8b	8b58e822-cbc5-4f95-8af5-0dc007a0a440	26a67045-bab4-49b3-8580-aa9b4810f4b2	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
d99b3b38-cc27-4492-adae-3a6bb5991360	ada082c6-e65b-4cde-b8f2-b73e78fc5cfc	8b58e822-cbc5-4f95-8af5-0dc007a0a440	d84b3018-69e6-4e14-9add-d06f1a882584	\N	\N	\N	{"licences": null, "categories": null, "mots_clefs": null, "themes_inspire": null}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
170d9ec4-a829-41fd-9092-f74035fce2b3	78acade9-448b-4371-9b82-7ab43610aea0	8b58e822-cbc5-4f95-8af5-0dc007a0a440	7e04cbbe-48b0-4686-8660-fadfe85b5f7c	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/7e04cbbe-48b0-4686-8660-fadfe85b5f7c	plan_4_b_inf_07_reseau_chaleur_surf	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
3d69185a-cc13-4635-b547-22dd7a4069b3	2e4acdca-9758-4c07-b807-46a1fc4d8dcf	8b58e822-cbc5-4f95-8af5-0dc007a0a440	1639b4a5-d387-409f-b7cd-219915f7c0a0	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/1639b4a5-d387-409f-b7cd-219915f7c0a0	plan_4_b_inf_09_mine_surf	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
904602a6-be1b-4291-b097-f3d0dae82074	fd71573b-8e35-47df-a44e-43b436110505	8b58e822-cbc5-4f95-8af5-0dc007a0a440	10b783d5-a1b5-4fbe-a3dc-fae9cad24c55	http://geonetwork:8080/geonetwork/srv/fre/catalog.search#/metadata/10b783d5-a1b5-4fbe-a3dc-fae9cad24c55	plan_6_b_inf_32_tam_surf	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
91574b31-4595-479e-b34e-0e854ce8b83b	9348492d-9d40-480d-a764-4cb7a9eab1d0	8b58e822-cbc5-4f95-8af5-0dc007a0a440	7b7c68dd-0b97-4b23-aac5-80645a3b6b18	http://geonetwork:8080/geonetwork/srv/fre/catalog.search#/metadata/7b7c68dd-0b97-4b23-aac5-80645a3b6b18	plan_8_a_inf_16_archeo_surf	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
543b8ae7-b1d9-402a-ba13-87fd911b521e	95840272-f6a5-4496-9870-1929c9127e38	8b58e822-cbc5-4f95-8af5-0dc007a0a440	39553aaa-26e3-49c5-b1f5-1f88d31651fa	\N		\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
234a59a1-1fee-45b6-8041-dbe78e6a92d8	3aa7f54c-eceb-4e35-8282-c6e0366b7e72	8b58e822-cbc5-4f95-8af5-0dc007a0a440	1034f377-a11c-4693-b553-c3f288aa6098	\N		\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
eb88a050-b7df-4f67-a1de-d0efa375a2cb	8fe49aee-aa6f-4ccb-b9c3-f60239b21900	8b58e822-cbc5-4f95-8af5-0dc007a0a440	a1a6ae8e-216e-4ae2-9a83-d84ccaa1994b	\N		\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
0326884d-34b0-4ee4-b8d5-84bb3768c402	aa9a3ab5-4d2d-48af-8262-170e39e0248e	8b58e822-cbc5-4f95-8af5-0dc007a0a440	b02f48b3-c538-4ef1-a504-e3458fdbaa44	https://geonetwork.grenoblealpesmetropole.fr/geonetwork/srv/fre/catalog.search#/metadata/b02f48b3-c538-4ef1-a504-e3458fdbaa44	plan_3_c_inf_27_peb_surf	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
c3c00d50-631e-405b-8fc8-7be0761dd1d4	7c4bd358-4919-4473-b0d0-16ed4e20cf2d	8b58e822-cbc5-4f95-8af5-0dc007a0a440	1ad42aff-335d-42a4-8dbc-100c86659daa	\N		\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
a766e2b3-9921-4583-9884-1d19c93c645e	b470094c-cbc8-457b-aec9-3768992df18a	8b58e822-cbc5-4f95-8af5-0dc007a0a440	bd7b556c-d038-45f3-a8d2-194a648a680e	\N		\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
5ff6c392-7cc4-4871-908d-b42ca56cdade	ed3211fe-8411-40ac-82cd-1d5860dffbac	8b58e822-cbc5-4f95-8af5-0dc007a0a440	2f6d5bc9-e3ef-4269-afc9-120017f0cb60	\N	toto	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
1eb20b3e-f95c-4410-a3e1-fda6cb7a845a	c51936fd-979a-48ee-a445-6889ba3ced29	8b58e822-cbc5-4f95-8af5-0dc007a0a440	cce7210d-3474-4101-b730-d688d0b547d1	\N	toto	\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
ff2aea2e-fb6e-43dc-8225-11aacd9831f6	6fe8fe02-7ebe-4df7-bc53-bd069c654373	8b58e822-cbc5-4f95-8af5-0dc007a0a440	2f0b1f96-0429-4e29-9a98-6e9abaf4823f	\N		\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
dd76867a-90ff-4280-a421-b274441736c7	e740863d-71d8-4bcf-91e0-2fa5e9da7aac	8b58e822-cbc5-4f95-8af5-0dc007a0a440	3d6d0e6c-556e-41eb-9711-a8b518f48529	\N		\N	{"licences": "", "categories": [], "mots_clefs": null, "themes_inspire": []}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
13089663-c5cd-4988-b477-417073ef2eac	e04cb471-897a-40d6-856b-89ffff37dd7e	8b58e822-cbc5-4f95-8af5-0dc007a0a440	50e3a04d-4744-46a0-8a70-09da72860a3f	http://geonetwork:8080/geonetwork/srv/fre/catalog.search#/metadata/50e3a04d-4744-46a0-8a70-09da72860a3f	plan_2_c2_inf_99_decheterie_surf	\N	{"licences": "", "categories": [], "mots_clefs": ["a", "b", "c"], "themes_inspire": ["Altitude", "Occupation des terres", "Ortho-imagerie", "Géologie", "Unités statistiques", "Installations de suivi environnemental"]}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
6e33b133-2e5a-4ba1-9888-1c7d27917e81	ca8bbb51-82c3-4a1d-a9c1-8b2f44e48930	8b58e822-cbc5-4f95-8af5-0dc007a0a440	9f954aa6-b3c7-4fce-9691-8d6ea073ac46	http://geonetwork:8080/geonetwork/srv/fre/catalog.search#/metadata/9f954aa6-b3c7-4fce-9691-8d6ea073ac46	plan_2_b1_inf_19_assainissement_pct	\N	{"licences": "", "categories": [], "mots_clefs": ["a", "c"], "themes_inspire": ["Ortho-imagerie", "Bâtiments"]}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
fc44b438-d1c4-4408-9f03-27e81021426c	6af73799-41b5-41c4-acfb-94c98af6ec56	8b58e822-cbc5-4f95-8af5-0dc007a0a440	875fecd4-5882-4cf5-9325-1dd805fad6eb	http://geonetwork:8080/geonetwork/srv/fre/catalog.search#/metadata/875fecd4-5882-4cf5-9325-1dd805fad6eb	plan_2_c2_inf_99_decheterie_pct	dechetterie	{"licences": "", "categories": [], "mots_clefs": ["c", "x"], "themes_inspire": ["Unités statistiques", "Installations de suivi environnemental", "Bâtiments", "Usage des sols"]}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
c55ae6dc-fa3d-4bfe-9387-bd022105a2c5	f8fdfba2-1b92-4dcc-90ea-f6bc2a3bd64a	8b58e822-cbc5-4f95-8af5-0dc007a0a440	d2a9a78d-4cb1-42b9-a0cf-8174914b5a29	http://geonetwork:8080/geonetwork/srv/fre/catalog.search#/metadata/d2a9a78d-4cb1-42b9-a0cf-8174914b5a29	plan_3_c_inf_14_classement_sonore_lin	sonore	{"licences": "Licence ouverte (OpenDATA)", "categories": [], "mots_clefs": ["a", "b", "c", "d"], "themes_inspire": ["Occupation des terres", "Ortho-imagerie", "Bâtiments", "Sols"]}	{"nom": null, "mail": null, "role": null, "prenom": null, "adresse": null}	1
\.


--
-- Data for Name: gest_bdd_rel_thematique_contact_referents; Type: TABLE DATA; Schema: sit_hydre; Owner: -
--

COPY sit_hydre.gest_bdd_rel_thematique_contact_referents (id, thematique_id, contact_referent_id, type_ref) FROM stdin;
\.


--
-- Data for Name: gest_bdd_schemas; Type: TABLE DATA; Schema: sit_hydre; Owner: -
--

COPY sit_hydre.gest_bdd_schemas (id, nom_schema, description, public, proprietaire) FROM stdin;
6fb38740-2e5c-4a69-b6a1-fb24d06dffaa	urba_plui_public	\N	t	apps-base centrale sit-admin
\.


--
-- Data for Name: gest_bdd_thematique; Type: TABLE DATA; Schema: sit_hydre; Owner: -
--

COPY sit_hydre.gest_bdd_thematique (id, thematique, description, metadonnees, id_thematique) FROM stdin;
8b58e822-cbc5-4f95-8af5-0dc007a0a440	URBANISME	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
7669ae0b-3178-4054-88b5-853ce8503a6e	AMENAGEMENT	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
94952bbb-248b-4c55-9d82-dac8ecc588ff	TELECOM	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
d3e74e6f-eee7-4e29-9f7a-ca1337b18208	EAU ET ASSAINISSEMENT	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
07026678-6c22-483a-ada2-034262a0fa87	ECONOMIE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
e47d2973-0bfb-4a82-8521-e7b0161ec189	ADMIN DATA	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
a8290230-71a0-4518-828e-b7803be1218a	PATRIMOINE BATI	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
a5b393a8-65bc-4467-89f0-10d12aaea502	PATRIMOINE ET ESPACE NATUREL	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
4860e3d5-649d-457b-8923-cffdb6e8a02e	AGRICULTURE ALIMENTATION FORÊT ET MONTAGNE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
a1dea4db-fee5-4ba9-99ca-8cd9744101dd	BIODIVERSITE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
a6d7712a-a856-4744-a58a-4bc9df8f7bb6	PATRIMOINE ARBORE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
c73362e8-6127-4b6d-9ea3-5ab6441b5522	DECHETS/COLLECTE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
b5b5776d-095f-487e-ae5c-0fee359a75ca	COOPERATION	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
1a2a9ef3-2f4e-4029-8f98-92091bfd8883	MOBILITE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
8d363836-1662-48c9-84ef-1071711320e4	REF_EXTERNE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
27c40644-8da6-4e3b-a0db-1a5af177e5ce	REF_INTERNE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
04a530fc-f2e0-4db5-932e-5e16f1c8e002	MILIEUX AQUATIQUES	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
8fabdf8f-0b67-4c67-bc2c-7eaba586e4df	ENERGIE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
2310e0be-02ad-48cc-b1ac-0082905b3950	FONCIER	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
71c411cf-8e01-4fd1-8c31-1383e7e65930	HABITAT	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
034405a3-089f-4eb4-a8a2-b276f257a57c	RISQUE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
c4a37507-2605-443c-82a8-628fe8e5c4b4	FINANCE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
00d5754e-dba7-4f0c-84b2-5de8cc2484c8	ADMIN USAGE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
2e361f84-f374-4691-8958-fd5e0bcda15b	VOIRIE ET ESPACE PUBLIC	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
dea16781-fe21-41fe-b42e-c982a858c707	OBSERVATOIRE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
36f05f12-ddf3-4360-a291-228d243e6193	COHESION SOCIALE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
8faa3724-9ff5-4724-975b-b991c284465f	RESSOURCES HUMAINES	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
17d29926-ff38-4a1b-a915-a3e1b1a56a59	ESPACE NATUREL SPORT CULTURE	\N	{"categories": null, "mots_clefs": null, "themes_inspire": null}	\N
\.


--
-- Data for Name: temp_rel_thematique_schema; Type: TABLE DATA; Schema: sit_hydre; Owner: -
--

COPY sit_hydre.temp_rel_thematique_schema (schema, thematique, id_thematique, id_schema) FROM stdin;
batiments_public	PATRIMOINE BATI	a8290230-71a0-4518-828e-b7803be1218a	\N
collecte_des_dechets_pilotage	DECHETS/COLLECTE	c73362e8-6127-4b6d-9ea3-5ab6441b5522	\N
cron	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	\N
dmtcep_bruit_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	\N
dmtcep_emd_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	\N
dmtcep_evaluation_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	\N
dmtcep_modelisation_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	\N
donnees_referentiels_dreal	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	\N
eau_deci	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	\N
equipements_solidaires	PATRIMOINE BATI	a8290230-71a0-4518-828e-b7803be1218a	\N
equipements_solidaires_public	PATRIMOINE BATI	a8290230-71a0-4518-828e-b7803be1218a	\N
espaces_naturel_loisir	ESPACE NATUREL SPORT CULTURE	17d29926-ff38-4a1b-a915-a3e1b1a56a59	\N
fdw_dref_td	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	\N
fdw_dref_td_t	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	\N
fdw_esri2sit_new	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	\N
fdw_oxalis_prod	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	\N
fdw_sig_topo_pcrsm	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	\N
fdw_test	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	\N
finances_public	FINANCE	c4a37507-2605-443c-82a8-628fe8e5c4b4	\N
geo_mobile	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	\N
geokey_insee	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	\N
gestion_relation_citoyen_public	COHESION SOCIALE	36f05f12-ddf3-4360-a291-228d243e6193	\N
gima	PATRIMOINE BATI	a8290230-71a0-4518-828e-b7803be1218a	\N
habitat_geokey	HABITAT	71c411cf-8e01-4fd1-8c31-1383e7e65930	\N
mobilite_et_transports_qualif	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	\N
observatoire_public	OBSERVATOIRE	dea16781-fe21-41fe-b42e-c982a858c707	\N
patrimoine_metro_public	PATRIMOINE BATI	a8290230-71a0-4518-828e-b7803be1218a	\N
pilotage_et_evaluation_public	OBSERVATOIRE	dea16781-fe21-41fe-b42e-c982a858c707	\N
rea_ass_anc	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	\N
rea_ass_gdi	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	\N
rea_ass_gpa	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	\N
rea_ass_res	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	\N
rea_eau_gdi	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	\N
rea_eau_res	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	\N
rea_ged	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	\N
rea_old	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	\N
sports_public	ESPACE NATUREL SPORT CULTURE	17d29926-ff38-4a1b-a915-a3e1b1a56a59	\N
topology	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	\N
urba_paysages	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	\N
donnees_referentielles_cerema	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	\N
espconf_energie	ENERGIE	8fabdf8f-0b67-4c67-bc2c-7eaba586e4df	a663af0f-b7db-4762-8263-d2ca9d7fc84a
amenagement	AMENAGEMENT	7669ae0b-3178-4054-88b5-853ce8503a6e	c5a844cb-85f4-4f7b-bbec-cf3cea3daa3f
amenagement_numerique	TELECOM	94952bbb-248b-4c55-9d82-dac8ecc588ff	34d7b84f-78ad-4fad-b9c3-2f5c475836df
amenagement_numerique_public	TELECOM	94952bbb-248b-4c55-9d82-dac8ecc588ff	b09cfeff-0434-49b4-82e9-10b47878f31c
amenagement_public	AMENAGEMENT	7669ae0b-3178-4054-88b5-853ce8503a6e	4f0cdb9d-22e6-4f20-ae91-7908f24e8dfd
assainissement	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	00b2ea0b-3f29-4c26-b58e-b2d3d6cb4b43
assainissement_public	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	19c35918-7831-4e5b-9f22-6ed330dbfd21
assainissement_rejets_industriels	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	7664bb24-923e-48de-8eeb-47055ec82004
aurg_atlas_eco_foncier	ECONOMIE	07026678-6c22-483a-ada2-034262a0fa87	24e337f9-5af1-409d-88d3-f0b676407301
aurg_atlas_eco_foncier_public	ECONOMIE	07026678-6c22-483a-ada2-034262a0fa87	94ae39e9-366a-4c4a-bcae-934755b3e60a
aurg_transferts	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	521ed3a9-8662-41b3-b75d-fefba6b9a648
batiments	PATRIMOINE BATI	a8290230-71a0-4518-828e-b7803be1218a	b0c3386f-f637-48dd-8058-a462c183c0b8
biodiv	BIODIVERSITE	a1dea4db-fee5-4ba9-99ca-8cd9744101dd	f8fb92a9-f332-481c-92f6-658afe1827f5
biodiv_foret	BIODIVERSITE	a1dea4db-fee5-4ba9-99ca-8cd9744101dd	98ac0a49-95a8-4f7c-8845-bc86390d85f7
biodiv_public	BIODIVERSITE	a1dea4db-fee5-4ba9-99ca-8cd9744101dd	fc9d552a-4168-4750-939e-64f4f6585316
biodiv_tvb	BIODIVERSITE	a1dea4db-fee5-4ba9-99ca-8cd9744101dd	f54fec64-d82b-4965-965b-5d5762967591
cameras_videoprotection	COHESION SOCIALE	36f05f12-ddf3-4360-a291-228d243e6193	c1a178ec-c2a3-4cce-9705-eb30cbb2bf4f
collecte_des_dechets	DECHETS/COLLECTE	c73362e8-6127-4b6d-9ea3-5ab6441b5522	e8495279-03d6-4181-b4df-b0a2b38f754f
collecte_des_dechets_circuits	DECHETS/COLLECTE	c73362e8-6127-4b6d-9ea3-5ab6441b5522	17f2e36e-c672-4e71-84be-f962f540c072
collecte_des_dechets_pav	DECHETS/COLLECTE	c73362e8-6127-4b6d-9ea3-5ab6441b5522	e4ba73ea-bde6-4790-b06b-76d15d62dc33
collecte_des_dechets_public	DECHETS/COLLECTE	c73362e8-6127-4b6d-9ea3-5ab6441b5522	d4aa59f8-5aa6-4301-a6b9-35d810c802b0
cooperation	COOPERATION	b5b5776d-095f-487e-ae5c-0fee359a75ca	43c95847-43c0-479a-bd2c-6def14ebd7a4
dmtcep_accessibilite	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	697aec3e-2068-4407-9d19-70fdf23cf64e
dmtcep_accessibilite_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	b49e6122-3686-42e1-9c17-384fe8e7fb9a
dmtcep_air	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	eff95a1e-eb61-4f0c-83b9-8049245024cd
dmtcep_air_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	42a841df-de2c-4e05-b054-c8a4e6490eac
dmtcep_bruit	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	89cdffa9-2f4c-4200-b382-92cddf5d8a0f
dmtcep_comptages_enquetes	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	24e9d382-c9f2-4405-a82e-16fbe54db56e
dmtcep_comptages_enquetes_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	f98a61e7-4cc7-4c2f-831c-51bd4a3f74b2
dmtcep_emd	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	99e7e1be-ebe1-491c-83fb-a08ad529f4dc
dmtcep_evaluation	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	bab200d4-c6f0-486f-b7bb-828571d8b56d
dmtcep_intermodalite	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	2469c609-c83c-4fb4-a754-ba33cc527e77
dmtcep_intermodalite_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	ebab5a0e-5768-401b-8b0b-3bc10c297c63
dmtcep_modelisation	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	685b763a-b1a8-4580-8d29-699295d69179
dmtcep_od_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	a9196f56-ac45-4b8f-b6d4-116b9d98412a
dmtcep_pieton	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	e1bf6cca-2b7a-403a-b04a-1792248874d1
dmtcep_pieton_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	96fc049c-4d8b-4fe9-91bd-565ea1141d3f
dmtcep_securite_routiere	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	748aa9cc-edc2-4d6a-82be-a36356e360ea
dmtcep_securite_routiere_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	86a41f89-1fa4-4a6d-832a-26c5a662de53
dmtcep_stationnement	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	3afb864e-9d95-4af1-b157-7f9bdd911597
sit_gestion	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	d86ef535-e1ca-4c54-821b-205feb595cf4
dmtcep_stationnement_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	7b98215e-9d1f-4c54-b9aa-93ce7f4f44d7
dmtcep_tc	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	afe83051-c637-4703-9e4d-a87c605d5039
dmtcep_tc_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	93c8f7fc-29d5-4d2e-908f-b7163c94b4b1
dmtcep_velo	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	b278de24-5567-4602-b66e-65224e4456d4
dmtcep_velo_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	0b02b3a1-8d12-4724-9bf0-bc67c42bd133
dmtcep_voirie	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	9e9b7461-baaa-4a08-afbe-b0fe6d9aff5e
dmtcep_voirie_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	26108af5-cc51-4448-b218-835cb19780f0
donnees_referentielles_ademe_dpe	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	84801bdb-1ed8-45d1-9e51-4ab4f02d807f
donnees_referentielles_adresses	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	33cbe1a4-0f02-4770-9239-01bd37254e1a
donnees_referentielles_agence_bio	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	feb383ac-d5db-4c98-a823-c130636b64e1
donnees_referentielles_batiments	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	61471d64-fd63-4ae7-9dc6-165c7d1994f5
donnees_referentielles_cadastrales	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	590480cd-e61e-40c9-9034-341b31f02fdb
donnees_referentielles_dreal	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	23d89e5c-caa9-423c-9143-ce53c1066b1d
donnees_referentielles_dvf	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	42d848c0-ff99-4730-a897-c28dfa20d043
donnees_referentielles_eau	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	cf4ed768-cb96-4d41-99fe-66f8c33c791b
donnees_referentielles_energie	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	9d851ce9-c2ec-4041-9be7-650be6c9b0a2
donnees_referentielles_environnement	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	edab18a1-681e-4428-a40e-6370b7ec2262
donnees_referentielles_france_europe	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	1cd4cb24-87f9-4df8-be37-6af62a309ef3
donnees_referentielles_geologie	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	d4fad8e8-3a1c-4ddf-b0cb-116a3f7ce10c
donnees_referentielles_ign	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	461b81ce-0009-48d0-9c6a-17d52eac839d
donnees_referentielles_ign_adresse_premium	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	6f5abcf5-acf9-49d4-967b-f42cf78eee3e
donnees_referentielles_ign_bdtopo	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	bf5c99c8-e16b-4c07-9890-7b78b39c343f
donnees_referentielles_ign_bdtopo_v3	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	d18eea85-0b4a-47e6-b5b6-ed799aad8b58
donnees_referentielles_ign_rpg	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	94ca5e9f-c48d-443d-b496-38ab2387200f
donnees_referentielles_insee	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	4e476e11-65fd-4800-a1fb-82ccaae65693
donnees_referentielles_limites_admin	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	eb43d3c7-7dd4-4ff5-a305-4d800c09bf03
donnees_referentielles_metro	REF_INTERNE	27c40644-8da6-4e3b-a0db-1a5af177e5ce	60c3473d-7ea5-4b59-8c56-cb1ae7231bfd
donnees_referentielles_ministere_agriculture	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	6de4f921-0d0c-40a4-bd73-e7d9e56205f0
donnees_referentielles_ministere_ecologie	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	5f96364a-be48-4529-abfa-34484eb47b0b
donnees_referentielles_mnt	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	ff21e6ee-e4fa-431e-9916-376da9d5bbbc
donnees_referentielles_occupation_sol	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	4a2917f6-85ae-4fc9-aa25-da062ce23cd7
donnees_referentielles_osm	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	17954c39-7387-447e-bea9-31262986e618
donnees_referentielles_pcrs	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	feea5859-aaff-4bcc-b5d4-4dc8e5b85127
donnees_referentielles_public	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	baf8f372-9c9d-49ad-9fd1-0401641c0ce0
donnees_referentielles_rge	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	b31f8eee-b8be-4961-94ca-0e560567cea9
donnees_referentielles_risques	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	679dc816-7ca3-4ca3-bf7c-d3e18924cd46
donnees_referentielles_scot	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	0c2ee97a-61ac-439b-9ade-88c95167f16d
donnees_referentielles_topo	REF_INTERNE	27c40644-8da6-4e3b-a0db-1a5af177e5ce	ed73e5c3-6591-4734-a226-33b56cea07c7
donnees_referentielles_ville_de_grenoble	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	7ae08dcb-603b-4581-ba5f-a481fc3fba6e
eau	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	dfc12e51-f844-4ca5-b27e-b1d155bebfbc
eau_artelia	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	b502f25d-4977-4a31-a6dd-d8e10ea48c64
eau_cadastre	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	9dad67de-c5e2-4ea2-b293-70a32338b53c
eau_captage	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	91197435-2771-4508-be48-8d8414e72f25
eau_covadis	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	84f7fa41-f516-4524-836c-fb5e3bb44f66
eau_covadis_2	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	89143787-163e-4db7-8495-481fb512bd81
eau_domanialite	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	d241f5f8-b050-49f8-9b2a-a91765787c9e
eau_gemapi	MILIEUX AQUATIQUES	04a530fc-f2e0-4db5-932e-5e16f1c8e002	70ec8b90-c049-4550-aa2e-d9ae0daf5c37
eau_gemapi_filaire	MILIEUX AQUATIQUES	04a530fc-f2e0-4db5-932e-5e16f1c8e002	9c7951fc-3fff-465a-bf80-247c3e2f345a
eau_gemapi_ppre_gam_diag	MILIEUX AQUATIQUES	04a530fc-f2e0-4db5-932e-5e16f1c8e002	4ed7e0b5-d7d4-47c6-9d21-5ccb2a32155b
eau_gemapi_public	MILIEUX AQUATIQUES	04a530fc-f2e0-4db5-932e-5e16f1c8e002	513a57c1-6c88-4871-8981-d296867daebf
eau_public	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	551e01d5-c2be-497d-a541-67d046655ffa
eau_reconquete	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	65c4b812-fa95-469e-9987-d926948d8b46
eau_test	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	ddbceb51-6cd9-4688-b73b-89d624ae4649
eclairagepublic	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	cfd8af0d-fccd-4743-a0a8-cba1aedb29ec
eclairagepublic_public	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	7e657625-7438-45e8-a5f6-7a2bd789730e
economie	ECONOMIE	07026678-6c22-483a-ada2-034262a0fa87	c494abf3-9529-4831-a4aa-eef143f89df0
economie_marches	ECONOMIE	07026678-6c22-483a-ada2-034262a0fa87	9ddc1aef-3b45-4116-8909-10bf1b1c520e
economie_public	ECONOMIE	07026678-6c22-483a-ada2-034262a0fa87	28130fac-da40-4b59-bb07-1f77923f487c
economie_subventions	ECONOMIE	07026678-6c22-483a-ada2-034262a0fa87	66447d50-9928-4cf4-8612-ac44f94724a4
economie_tertiaire	ECONOMIE	07026678-6c22-483a-ada2-034262a0fa87	c397d824-a3ca-47ee-87ba-8f01e2d503a3
energie	ENERGIE	8fabdf8f-0b67-4c67-bc2c-7eaba586e4df	106a4b56-a687-4f12-b0b1-916c23bef4dd
energie_public	ENERGIE	8fabdf8f-0b67-4c67-bc2c-7eaba586e4df	daedc7d8-fbda-4fe1-8610-36bab1b4fa78
energie_reseaux	ENERGIE	8fabdf8f-0b67-4c67-bc2c-7eaba586e4df	5f1ee708-e4f7-4ed7-8d92-9b8135cdc035
environnement	AGRICULTURE ALIMENTATION FORÊT ET MONTAGNE	4860e3d5-649d-457b-8923-cffdb6e8a02e	33bc5691-638c-4906-94c2-77149fc9b88d
environnement_public	AGRICULTURE ALIMENTATION FORÊT ET MONTAGNE	4860e3d5-649d-457b-8923-cffdb6e8a02e	27f4f07b-a72e-4bfc-9425-f119b87f72d5
epfl	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	0dbbdbb9-015b-4715-bd15-c88391c52119
epfl_cadastre	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	7ef664ad-06af-45e1-948d-00fb8accb3e6
epfl_cadastre2020	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	44e074c1-4238-40d8-b07d-20a1e96f9567
epfl_cadastre2021	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	33bdd7ea-f585-4c94-b342-3524ef445064
epfl_etudes	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	3564c4fb-e40f-437f-8278-e9f4de7cdb61
epfl_new	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	cfb47869-f243-4424-8c61-046c53c7344d
epfl_plu	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	5d113e2e-7ef6-44e5-9108-63b38ba48ece
epfl_public	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	d9afbc3c-da3c-4355-8848-95dcbcd4be8d
espaces_naturels	ESPACE NATUREL SPORT CULTURE	17d29926-ff38-4a1b-a915-a3e1b1a56a59	85a758f2-9462-4428-a262-90eca3180e54
espaces_naturels_public	ESPACE NATUREL SPORT CULTURE	17d29926-ff38-4a1b-a915-a3e1b1a56a59	3c819d77-6ed8-43ac-8867-ef68d709007c
espconf_ads	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	784fbe33-6c34-451d-b8e0-51f7ba6f75a6
espconf_cadastre2022	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	622c36e9-fef1-49d8-95bf-5cd213e73102
espconf_cadastre2023	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	be319bf3-c938-4db4-9d5c-1df9514e4732
espconf_cadastre_cerema	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	659df260-82ae-493e-addb-7e1eb3fedee0
espconf_cadastre_outils	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	6857fdae-c79b-4264-92f8-02c6a03c0b9c
espconf_cadastre_restreint	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	199b961d-c8d1-464d-ad75-17e4cfded68a
espconf_cerema_ff_2019	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	dae9a958-424d-475c-a39b-05904ccb1d8d
espconf_dv3f_2023	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	266ce685-df31-4f13-b352-b2249cbbe513
espconf_dvf_annexe_2023	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	c9f44684-8779-48d2-8b6f-355b2036dcff
espconf_dvf_d38_part_2023	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	4757cc5f-46b8-4311-8f00-2a8c10f4295e
espconf_eau_captages	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	015d0414-dcbf-4b4f-8f5e-fb9d989d5fc3
espconf_epfl	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	785dd6ee-8aca-4c2c-b707-5b02e535d5b6
espconf_ff2021_cclg	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	9aea5c18-8842-4497-887e-088f34675eca
espconf_ff2021_dep_cclg	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	181915a1-e9a9-4481-bb9c-ff59849c9c3a
espconf_habitat_maraude	HABITAT	71c411cf-8e01-4fd1-8c31-1383e7e65930	d2479104-1825-4e50-acf4-3f506dd0e889
espconf_rfp_2022	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	48fc8098-7a04-4029-81d2-bb8d688a7360
espconf_risques_infrastructure	RISQUE	034405a3-089f-4eb4-a8a2-b276f257a57c	9f206124-d04b-4b81-a15b-4006ba7461fd
espconf_sit_parcel_nomprop	REF_EXTERNE	8d363836-1662-48c9-84ef-1071711320e4	e4fe3a0a-4cf8-4e8c-b631-0642b65aa90f
espconf_transport_matiere_dangereuse	RISQUE	034405a3-089f-4eb4-a8a2-b276f257a57c	4f949044-0103-4513-9997-2c144a8e649d
fdw_esri2sit	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	329a7c7b-d5d2-4988-8811-47f53dd60712
fdw_gpv_sir	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	3c7f2a59-8fce-4631-b3f4-1bf270a76c88
fdw_oracle_dsi	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	ec803dd1-24df-4d6a-9fbb-ad7cba83d809
fdw_orchestra	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	0f1652af-6bf7-4962-885d-9ce7988a7cf1
fdw_oxalis_test	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	3ede12bc-c057-4043-98b5-002a0ac4da76
fdw_sir_sir	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	897cf10e-0608-47f7-abe6-50398d15962a
fdw_sit2esri	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	a70d97c6-5f93-45fd-878a-a4ecfc3fdf1e
fdw_test_prod	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	1d874526-9944-4a8c-bae0-c024b04957c5
finance_coefficients	FINANCE	c4a37507-2605-443c-82a8-628fe8e5c4b4	981e3ccd-10c7-4f84-a737-2b1c76ffe323
finances	FINANCE	c4a37507-2605-443c-82a8-628fe8e5c4b4	934f7da1-b44a-4b8a-a09c-e777664f9a97
foncier	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	b7c71f63-55b2-42b1-9c96-4037e3f48c1f
foncier_dia	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	ebd1639c-6223-4f74-be47-e6f36aee754c
foncier_public	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	2854e79e-856f-449c-9cf6-46293fb9359c
foncier_regul_voirie	FONCIER	2310e0be-02ad-48cc-b1ac-0082905b3950	35b757f1-ffa5-47b0-89b9-3a16108441e0
geo_edigeo	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	5ab6bc56-36dd-4aa8-bc12-8dcb5b3ca325
geo_edigeo_2020	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	6e916d90-9181-479e-b268-6010e7783094
geo_edigeo_2021	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	691d49c7-2f1b-4b12-a2ec-ae8debb97078
geo_grand_public	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	c2721384-831a-463d-a110-f2da6a3dc983
geo_majic	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	9bea07b1-9632-4e90-906e-67a5cd11d4b6
geo_majic_2020	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	3d832d1e-b0a7-491e-b0db-1609e2c0c7b0
geo_majic_2021	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	146494bd-5089-456f-9327-0fed7ae27254
geo_oxalis_ads	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	ecba7712-d9be-417b-8713-fbfe36946425
geo_oxalis_certif	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	593a2230-ec6e-4de6-8d5e-c83612bf462f
geo_oxalis_ddc	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	a168ce46-38e7-459b-8521-b944d60a72df
geo_risques	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	71941cce-8dfd-4835-b2f3-77df2d388862
geo_stats	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	11ba3a99-d1b6-448b-9dc9-3396fc0826ba
geo_zonage_plui	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	0e0ea1e3-f267-4677-bd5e-fa7f0423bbae
geothermie	ENERGIE	8fabdf8f-0b67-4c67-bc2c-7eaba586e4df	a33dffbf-e27a-4850-94f0-d3df6a167908
geothermie_public	ENERGIE	8fabdf8f-0b67-4c67-bc2c-7eaba586e4df	b2fc17a4-45d4-4f89-9d3e-9162c788416e
gestion_patrimoine	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	b96642e2-b1c1-4104-9f1a-bd5b33fb0a3b
gestion_patrimoine_public	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	34ac2124-e438-4464-9776-ee163cbbf429
gestion_relation_citoyen	COHESION SOCIALE	36f05f12-ddf3-4360-a291-228d243e6193	3993c000-e29b-4b62-9515-c312de73449d
gima_test	PATRIMOINE BATI	a8290230-71a0-4518-828e-b7803be1218a	188a04d6-b0de-4c0c-8f4a-f84fe9150c6d
habitat	HABITAT	71c411cf-8e01-4fd1-8c31-1383e7e65930	3c14e2e0-a7c6-4bb6-b632-896ae7e4b4b3
habitat_obs_vacance	HABITAT	71c411cf-8e01-4fd1-8c31-1383e7e65930	9484de31-9a5f-45a9-871a-4a3ba5c7ff37
habitat_public	HABITAT	71c411cf-8e01-4fd1-8c31-1383e7e65930	333489e3-2cfa-4079-b7ee-316f8b6d5314
igoa	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	c37802ad-86ab-47df-8c11-b7c7d4a89b5c
mobilite_et_transports	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	d09fc2f4-12df-4013-bfd8-1cf5f5914a6f
mobilite_et_transports_public	MOBILITE	1a2a9ef3-2f4e-4029-8f98-92091bfd8883	973442bf-7007-4529-bbb6-065169623a1e
observatoire_ads_dia	OBSERVATOIRE	dea16781-fe21-41fe-b42e-c982a858c707	083294b7-70b1-4660-ad2c-16a1e905b4da
occupation_commerciale	ECONOMIE	07026678-6c22-483a-ada2-034262a0fa87	d0f28c3c-63ae-4f35-8690-0686fce5a49a
opendata	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	9ee68c9f-2a9e-49b9-a3b6-6e9ead506ab4
oprn	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	6a536c77-c9c0-44ff-ad73-e8f66e28fbbf
ouvrage_art	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	f6d022db-7df4-4f19-9f2d-d800f697887f
ouvrage_art_public	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	586cce2b-0c22-49e5-b139-a4d23fc5d9f0
pait_aurg	AGRICULTURE ALIMENTATION FORÊT ET MONTAGNE	4860e3d5-649d-457b-8923-cffdb6e8a02e	a5a0b696-4801-4abf-b41b-db2a52913acb
patrimoine_metro	PATRIMOINE BATI	a8290230-71a0-4518-828e-b7803be1218a	66385c79-a914-4693-aa04-f8be561da803
pilotage_et_evaluation	OBSERVATOIRE	dea16781-fe21-41fe-b42e-c982a858c707	0908e345-29c3-48a2-af85-212189b9dd88
politique_ville	COHESION SOCIALE	36f05f12-ddf3-4360-a291-228d243e6193	c1fbd4d0-f465-4750-9147-c8dc79bc3369
politique_ville_public	COHESION SOCIALE	36f05f12-ddf3-4360-a291-228d243e6193	e28533b6-2214-4a45-a5ae-81f215597c61
projets_orchestra	COOPERATION	b5b5776d-095f-487e-ae5c-0fee359a75ca	137293db-ce15-4cd8-aa5f-eb30c6a9c20d
projets_orchestra_public	COOPERATION	b5b5776d-095f-487e-ae5c-0fee359a75ca	1aa918e7-31c6-485e-ba0b-ea32759ec0b8
projets_territoriaux	COOPERATION	b5b5776d-095f-487e-ae5c-0fee359a75ca	28a8cb99-912d-4ab5-98ef-e461f933c550
projets_territoriaux_public	COOPERATION	b5b5776d-095f-487e-ae5c-0fee359a75ca	060ec0d5-481a-47d7-8980-81c6432da156
public	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	78542dc1-4906-480b-b7dd-d14087c15f9b
rea_archiv2020_eau_reconquete	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	a57930ca-f747-400c-a973-97ad50e5699a
rea_ass	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	cc7d0fbd-836d-47ff-9d09-00c54bbe4402
rea_cat	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	5afa8fc6-6e4f-460b-8c80-3e9e3a74244f
rea_cea	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	573c29dd-93ac-474a-8b3a-085938ac239c
rea_cea_sgl	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	3e8503a4-e8e9-4493-9404-e4d3bf9e9e37
rea_cea_tvx	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	2b1acfe1-955d-463e-8d52-a446a4f54bce
rea_eau	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	85b7ff2a-c85f-4030-a1c3-d2df11f9c154
rea_eau_cap	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	6ecf3038-07ff-4681-b833-ae2c42b75554
rea_eau_gpa	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	a7d3533b-2c9d-4fcc-8cf5-87e341da4019
rea_eau_inc	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	7148ef5f-a9a4-48b9-a02b-196441d9dc15
rea_eau_va	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	06c3df64-bb15-4767-afca-7220ce1bb241
rea_public	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	5a92f11e-0f64-4740-9737-1ba628c9394e
rea_ref	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	5d57308f-3853-4de9-b2d7-bf1aab650057
rea_tpw	EAU ET ASSAINISSEMENT	d3e74e6f-eee7-4e29-9f7a-ca1337b18208	1a612eca-0329-4988-93d8-78c35452a6bd
renouvellement_urbain	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	3098f2b3-aa60-4f78-9ed9-e71e8a2b4e06
renouvellement_urbain_public	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	e48856dc-a1c2-46a4-bdfc-6910618e2ba1
resources	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	c8994444-48f2-44d5-851b-5076b4c7a8da
ressources_humaines	RESSOURCES HUMAINES	8faa3724-9ff5-4724-975b-b991c284465f	40ca0bf7-23b5-480f-8e77-85795b860d05
ressources_humaines_agents	RESSOURCES HUMAINES	8faa3724-9ff5-4724-975b-b991c284465f	fa0fd90c-7e9e-40f5-a511-f2f4b9e2e05c
ressources_humaines_public	RESSOURCES HUMAINES	8faa3724-9ff5-4724-975b-b991c284465f	eed75c6e-16d4-4e9d-b9d4-d97feedef788
risques	RISQUE	034405a3-089f-4eb4-a8a2-b276f257a57c	24608a0b-bfbe-428a-a81f-2046f0bed14e
risques_archive	RISQUE	034405a3-089f-4eb4-a8a2-b276f257a57c	c8cd74df-0cc1-494a-9b44-82dc7598f43d
risques_etude_sonnant	RISQUE	034405a3-089f-4eb4-a8a2-b276f257a57c	9e806f74-30d3-4a86-8551-a6ea564b3ab0
risques_gresivaudan	RISQUE	034405a3-089f-4eb4-a8a2-b276f257a57c	25319a12-adfe-4d4c-8d79-505d0257b4b7
risques_import	RISQUE	034405a3-089f-4eb4-a8a2-b276f257a57c	90535d6c-3b68-454a-b8eb-2d0646c10654
risques_public	RISQUE	034405a3-089f-4eb4-a8a2-b276f257a57c	39b3e7de-913b-412b-8331-7785c5a67cae
signalisation	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	a9a0584e-5a3c-4394-a912-1a693afed41a
signalisation_public	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	c08da02a-cef5-4a4c-89a6-59615479bc6c
sit	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	089cf38d-45dd-4811-97b4-5ec55d17e9a3
sit_ads	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	bbd7962c-dd73-4c5b-b1d2-811c2f3018ae
sit_atelier_geokey	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	a0c20764-7015-4239-92c2-856f55477d5a
sit_decoupafacon	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	06c62619-5d68-453d-b36f-981b477adf99
sit_decoupafacon_data	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	a7e54517-69d4-491f-9a27-591cc5e2bf48
sit_gestion_ref	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	704bda8d-24fe-4bd7-8366-3402ed0acd6b
sit_metadonnees	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	acf7485d-1e1f-44cf-a77c-d7c61c2d18fd
sit_plan_topo	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	5a163d38-f6b5-406c-bea3-c760b1137cb0
sit_public	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	c9d3eab9-71e4-4708-aba3-f97c626bc061
sit_stats	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	6f06e9f4-0517-49a2-9a95-9c1429d8a70b
sit_utilitaires	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	83d3d019-20b3-4edc-a068-f0d71b3eb135
sit_verification_donnees	ADMIN DATA	e47d2973-0bfb-4a82-8521-e7b0161ec189	2561ca6c-cf5c-4077-861f-ec8376572801
slt_signalisation	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	0bed9290-a58d-4bb6-81e4-3f3b9dcd89aa
sports	ESPACE NATUREL SPORT CULTURE	17d29926-ff38-4a1b-a915-a3e1b1a56a59	0f74d867-19d1-4a0a-8f1c-45dc6ecd4e27
stationnement	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	9b80e47a-4a35-4c7b-850a-edbadcff07a9
stationnement_public	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	6a485e76-93d1-45d4-b54a-dad3ab93df15
stockage_medias	ADMIN USAGE	00d5754e-dba7-4f0c-84b2-5de8cc2484c8	e7002fbd-ea6c-4308-aa3f-fa0731bf35bd
urba	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	6a6095f3-8fbd-481f-97c4-f0018fa9aa9a
urba_plu_qualif	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	d99a78fd-cad9-4eee-bde3-261967591d42
urba_plui	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	611ab5d8-fed7-4edc-8b38-723d4545a355
urba_plui_appro_20191219_public	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	754a5911-c31e-438f-a22d-a7a9e78e5771
urba_plui_atlas_m1	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	3ffb9fd2-0a80-4a1b-b1c9-3e2a6ca22e15
urba_plui_atlas_m1_ph1	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	d13cfaae-d94e-45fe-80e9-81b5e6944569
urba_plui_atlas_m2_ph1	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	33a43bfc-389e-42d4-9802-701819069803
urba_plui_atlas_m3_ph1	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	c3e2fe25-e70e-4d9b-8880-4d56d95faddb
urba_plui_atlas_mj2	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	fe5fb21c-3236-4a58-bf62-a3a7d08bda8b
urba_plui_atlas_mj3	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	4b0ca015-990b-415f-872d-625108585aa8
urba_plui_atlas_mj4	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	a2dbbf69-4efd-425c-a0c6-d3c2e57f59fc
urba_plui_atlas_modeles	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	8943520c-547c-4a0a-acf1-e53e56365e51
urba_plui_atlas_ms1	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	d0cf29d3-1650-40a1-b153-369fa7d25ae2
urba_plui_certif	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	5459bf1e-11e8-4521-b003-9bf0c886d5a5
urba_plui_demande	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	a6fee23b-6203-40bd-8715-074761823655
urba_plui_donnees_oppo	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	358af583-0bc5-4dc2-a123-977cc2b978dd
urba_plui_ecriture	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	748f4b47-94be-4f6d-ba1d-a12b3bffaabc
urba_plui_numerisation_urba	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	ab34843f-7dca-41ec-984e-1472a68d4f47
urba_plui_partage	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	d781ebb9-4a7c-4448-94ff-2e6e986aaf93
urba_plui_public	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	6fb38740-2e5c-4a69-b6a1-fb24d06dffaa
urba_plui_public_200528_mj1	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	45b9b8a1-f4a4-4abf-b426-ff6dcd4a6029
urba_plui_public_210301_mj2	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	3b856a5b-b516-4a0f-9f69-36954ca629c5
urba_plui_public_210702_ms1	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	dc95ea55-7281-4bb9-ad51-126c51aecfc9
urba_plui_public_220601_mj3	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	c96ec4b7-642d-4a1c-b45e-c906c87e49f9
urba_plui_public_221216_m1	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	b6663858-f07e-49ca-8ad2-67394ab9796d
urba_plui_qualif	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	0c8677a7-d09f-48df-9427-6d05a1bdf3e4
urba_plui_reglement_ecrit	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	da270cff-5242-4ef4-a25f-a3bc4532e367
urba_ref_plui	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	53535067-d5f9-4d21-982b-146a5623a48f
urba_reglements_opposable	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	6be236dc-a7ad-4137-a79e-764e279a5c47
urba_spr	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	72ea9abc-f685-40fc-8da6-82f3567b54cf
urbanisme	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	2fe98271-f291-4be8-9bf9-68bd8de74730
urbanisme_public	URBANISME	8b58e822-cbc5-4f95-8af5-0dc007a0a440	f98d8ce8-d918-45b9-8907-221ced416ffb
voiries	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	78e0101e-5e50-4733-8e6f-9014a2a51211
voiries_cycles	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	17eb1fa3-bdb1-4927-b599-86b7bf8bd963
voiries_cycles_public	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	ca3d48c7-08b4-4414-b2bd-c522da0d7c15
voiries_public	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	621bf88d-f778-4efd-b61c-2939a810bf7e
voiries_sir_histo	VOIRIE ET ESPACE PUBLIC	2e361f84-f374-4691-8958-fd5e0bcda15b	1fee4db1-52f5-460b-9bf1-e1459a954f2c
\.


--
-- Data for Name: plan_2_c2_inf_99_decheterie_surf; Type: TABLE DATA; Schema: urba_plui_public; Owner: -
--

COPY urba_plui_public.plan_2_c2_inf_99_decheterie_surf (idinformation, idurba, libelle, txt, typeinf, nomfic, urlfic, datevalid, stypeinf, lib_cnig_epci, lib_code_insee, lib_etiquette, lib_idinfo, lib_labeling_positionx, lib_labeling_positiony, lib_legende, lib_modif, lib_modif_comment, geom) FROM stdin;
7101501	C06_I99_003_02	Points d'apport volontaire (OMR-CS-Verre)	\N	99	\N	\N	2019-12-20	00	99-00-04	38516 / 38471 / 38170 / 38126 / 38281 / 38328 / 38423 / 38472 / 38229 / 38258 / 38325 / 38382	\N	IS628648	\N	\N	\N	N	\N	0103000020690F0000010000005D000000B2797180583A3D41A553502C32235041CBB3E74E933A3D41A585E3C4BD225041E7B237D0EE383D411A97374310225041B13D1EE8E0383D41A01BF6A376225041390742B689363D410F2C1B2AB42250414F24FA7CDB333D416BEF42F0C2225041C9DB32B952323D41A1B4F748B7225041647ED405D9313D4180023AF3F2225041FFD808C7882F3D416CF60AFADD2250412F83DBCD912E3D4153A7F8838A235041F4713D2A102D3D41ADCCCCD46E235041E9B81E95C92B3D41A5F52814B6235041863616303C2B3D41D23F75B8A22350413C52B89EE52A3D41A31E85EFC6235041CF20FC6B452A3D410CDF9BFEA9235041B50EB67A9D293D411153C8B447235041F3F528ACD7283D41823D0A974F2350418609D7E35A283D413885EB21712350417C1E851B79283D41EEFFFFDBE0235041AC2AE668C2273D415FD3810C062450412ACD1A49D8263D4177FB9DE0B5235041A43C8D9068253D414B0BA7A3FF235041D40943E6F4233D41768CED459623504133326212AE223D418002752CA023504182890DC8CC1E3D41E5B01279052350411830E210051D3D41B7891E3DC323504114AE47A1D2193D4152B81E658124504185EB5138CD1C3D41295C8F12DC2450411F85EB91551E3D41AE47E18AE22450413D0AD7E3F61F3D4152B81ED50E2550410AD7A3F050203D4114AE4761BC255041CDCCCC4CB7203D41AE47E1DAAE255041D7A3707DA1203D4152B81E55C625504152B81EC5C4213D41000000E0362650419A99995954223D417B14AEF735275041713D0A97CA223D41713D0AF73D275041295C8FC23E233D419A99995972275041AE47E1FA91243D411F85EBA182275041EC51B8DEC2243D41C3F528BCA527504100000080FF253D4148E17A74E7275041B81E852B18273D41C3F5285C622850419A999959FE273D41AE47E11A83285041C3F5289C1D283D4152B81EC5B7285041EC51B81EBE283D41CDCCCCACDA28504114AE476148293D4133333353572950415C8FC235412A3D411F85EB01A7295041AE47E13A782A3D41713D0AA7AF295041D8E8D2B10A2B3D415C0B742F95295041E17A142E322C3D4100000050172A50411F85EB9133313D415C8FC245FD2A5041666666663B333D41B81E851B0A2C5041A4703D8A79343D41CDCCCCBCA82B5041D7A3703D32353D41EC51B86ED62B50410000004096373D41C3F528CC0F2C5041AE47E1FAFF383D415C8FC265C52B5041A4703D0A093A3D411F85EBC1062B50410AD7A3706E3B3D41CDCCCC7CD82A504152B81E85683B3D41B81E85EBA22A5041EC51B8DE223A3D41E17A14FE642A504133333373BA383D411F85EB1173295041C7948DB725393D41BDA4B75765295041EC51B8DEB53A3D41C3F528CC9C295041713D0A97083D3D41333333D3A62950418FC2F5A8813D3D413D0AD753972950417B14AE47FA3E3D41E17A14FEA72950411F85EB1100413D41713D0A0753295041B81E856B6A423D413D0AD7B3EF28504186B4CFB4AB463D41977B68D56528504148E17A54CF483D41CDCCCC8C9D2850410AD7A3F0FE4E3D41000000B0412850418FC2F5E8104F3D4166666646B72750417B14AE07A84F3D41B81E85EB4327504152B81EC53F4F3D410AD7A3B0EB265041AE47E1FA1C4B3D41713D0A07D5255041666666A6A04A3D41666666567A2550413D0AD7E34A493D411F85EB6127255041F6285C4F30473D4100000000462450418FC2F5E82B463D411F85EB9115245041713D0A9712463D41C3F528BCEA235041F44CA2AD09433D41F71C0979142350412BC1F87FC2413D41458EE938CF225041A03A029CA13F3D419E51580FA122504196AE2C5F213F3D4195254411E522504155578314893F3D41ED538D2EBB2350412E60108BA13D3D41B72896CEA6235041430677D7043D3D415BE2D49781235041DC4F0C3A333C3D415C9B94DBA123504147CDAF5EEC3B3D41E77BBE9E842350413892A74A3F3B3D4180F792C19E23504159263D83D13A3D41A7978A67D1235041DCEEC5AA003A3D41A7878FC6E523504137D57DF2FC393D41BBD1B55D4C235041B2797180583A3D41A553502C32235041
7101519	C06_I99_003_02	Porte à porte (OMR) et points d'apport volontaire (CS-Verre)	\N	99	\N	\N	2019-12-20	00	99-00-06	38057 / 38059 / 38068 / 38179 / 38188 / 38200 / 38317 / 38252 / 38151 / 38071 / 38364 / 38388 / 38421 / 38445 / 38524 / 38528 / 38529 / 38545 / 38478 / 38562 / 38158 / 38309 / 38277 / 38279	\N	IS628650	\N	\N	\N	N	\N	0103000020690F000001000000A50000007219EAC88A393D414C7B98B9AA185041CC7A1C80053A3D4152674ADBB81850410EACB4BD8E3A3D41D09B25678B185041B37D5295B23B3D41DFDCB8548B185041FDAA8413DE3C3D41AE942F7D6F185041A946047AFD3E3D412515BB7E76185041000000007B3F3D41B81E85CB30185041533FC1D438403D41B4B77CC040185041560B26BF09423D418B25BF1129195041E3C4BFDF93433D416A017D26DC1850414DCE9C9121453D41C95B40A91E195041333333B341453D41EC51B80E5C195041094D3DA227483D4147926CD6821A5041B142A54C154A3D415945463BAC1A5041329A587E864A3D4175F4DF31CE1A504163A789F7904C3D41CC2E0BBFC61A50411F85EB91AD4D3D41C3F528FCF6195041295C8F42864E3D413D0AD733DE19504152B81EC507513D4148E17AA427195041F6285C4FE4503D419A999909F5185041000000803C513D4152B81E35C21850417B14AE47DE503D41A4703D5A5C185041333333B352513D411F85EBB12B185041383202BA3D523D41F7F72BC418185041A4703D4A94523D41EC51B80E4C1850419A99999926533D41AE47E15A51185041E17A14EE78533D418FC2F5988C1850415C8FC275B6553D41333333D31818504114AE4721F0563D4148E17A14F5175041B81E85ABB8573D41B81E857BA417504114AE47A1B8583D41713D0AD771175041713D0A57A9593D41F6285C9F5A1750413D0AD7A3895B3D4114AE472168175041F6285CCF465D3D41333333F33F17504133333373265F3D4185EB5148E7165041713D0AD75F603D41EC51B8AE81165041666666662E613D413333336368165041B81E852BC8623D4114AE47F1831650419A9999D93E643D417B14AE57C11650415C8FC2F515643D41295C8FB274165041D7A3703D61633D41CDCCCCBC1A165041B81E852BE2633D41E17A146EA2155041EC51B8DEE3623D41F6285C8F031550410AD7A330F2633D4166666606C2145041000000C0F5633D41C3F528EC95145041D7A3703DCF643D419A9999294A145041B81E85ABA9633D41000000C013145041B81E852BE5643D41EC51B84EA81350418FC2F56877653D41000000D0EA13504148E17A140F663D417B14AE57DB135041EC51B89E62663D41A4703D4A7D135041B81E852BEA653D419A9999F961135041AE47E1BAAF653D415C8FC255ED1250415C8FC2B513623D41713D0A778E125041333333F381603D41AE47E19A85125041AE47E1FAD5603D41713D0A777E125041C3F5281C0D613D413D0AD74350125041A4703D8ACD603D41AE47E11A2A1250417B14AEC738613D41333333C322125041E17A142E20613D41A4703D9AF711504148E17AD49F603D41295C8FD2EF115041295C8F4248613D418FC2F578DB115041E17A142E94603D4133333303B31150417B14AE07FC603D4166666636AC115041666666E64C603D41D7A370CD951150410AD7A370DB5F3D4100000000551150411F85EB11FC5F3D41666666F6241150415C8FC2358F5F3D410AD7A350F51050411F85EB919B5E3D41CDCCCC4CC2105041C3F5281C8E5E3D410AD7A3204E105041666666662C5D3D41A4703D2A241050415C8FC275315D3D41C3F5280CEF0F5041D7A3703D625A3D41713D0A873F0F5041D6FF344F715A3D413AFBF44E2D0F5041A4703D0AEA5F3D4100000010560E50418FC2F568225E3D4100000010BD0D5041B81E85EB8F5C3D4148E17A349A0D5041666666262F5A3D41713D0A178C0D504152B81E4557583D413D0AD723170C5041D7A3703DBD573D41EC51B81E470B5041713D0A978F553D41666666B6CB0A5041EC51B85EF1513D41CDCCCC6C320C5041EC51B85E1B503D41E17A146E720C5041AE47E1FA0D4F3D41C3F528EC380D5041F6285C8F3A4F3D4100000010710D50410AD7A370654E3D4185EB5108D80D50419BD62DD22D4D3D4102D01575D70D50418FC2F528F1443D418FC2F5981D0D5041295C8F820D453D41CDCCCC3C0F0D50411F85EBD123443D41A4703DBA3B0D5041C3F5289CE5423D411F85EBB1B50D5041C3F528DCFC403D41A4703D5A750D504114AE472142403D41D7A3704D820D50418FC2F568283C3D41295C8FD21E0E50415DCE6B4DE23A3D41F2C350AE720E504133333373463E3D41000000C0560D50413D0AD763A23C3D413D0AD7B3DB0C504148E17A14E23B3D41EC51B87E3D0C5041713D0AD7173C3D419A999989180C504148E17AD4E53B3D41713D0AE7BE0B504152B81E85443B3D41E17A148E750B50419A999959293A3D41EC51B8BE3D0B5041AE47E13AF8383D41A4703DCA720B5041AE47E1FA87383D417B14AED7720B504152B81EC5CB393D4133333353D80A50410AD7A370A7393D4166666646B40A5041295C8F8250393D41713D0A27B20A504148E17AD46D393D4114AE47D1950A50411F85EBD1D7383D41CDCCCC2C200A50418FC2F56897373D4148E17AF41C0A5041F6285C0F9D373D415C8FC215D0095041295C8F82D1363D4148E17AA4C1095041B81E85ABBF353D411F85EB31CC0950418FC2F5A8F2343D41EC51B8CE81095041295C8FC2F0343D417B14AE37FE085041D7A3703DFC333D411F85EBE1FD085041295C8F4251333D4148E17AF4AB085041000000C05F313D418FC2F518D4085041D7A3703DC72D3D4133333373F0085041C3F528DC2A2E3D41000000100E095041C3F5281C072E3D41E17A140E37095041A4703D8A282D3D41D7A3701D7B095041241C856DAB2B3D4131E3E8E8B109504151A3DC871A2C3D41B8CE744E940A5041E02C18058F2C3D413992EEC0C10A504143DCD5AEE92D3D41B408D6D2FF0A5041E727CC24A32E3D41F2109E77A00B50418B5444E4982D3D41DCA9C13C760C5041618DFC47C02D3D41D687ED04220D5041C839F1D09F2E3D41DBEB8A52F80D5041DD326770AF2E3D413819CB5FD20E5041E69D774DFE2E3D4104C972152C0F504187335127862F3D41CDDBAEB1900F5041FBF2A55095313D41192E18FE7210504159F19CAEF2323D41A8F4C570E51050413399C08741333D41D3411F0AD91050414C630FA12E353D41AAEB9EA3D711504194E4A2722E363D41551ABBDCBE1250410AD7A3B03D363D413D0AD7C3F2125041853BD3C2602F3D4110F321F44A1450416673895427313D410CB509EF0C1550412ABA370CCD303D417CFE119B54155041BBC1F0A520313D412D741D2F3515504188CEE78155323D417AB00DCAA3155041980215F7D0323D41C13F8005B415504146625DA286323D41255B5C5976165041D01EC5472A323D4140A471489F16504146E3FC7E63323D419DED3220BC1650419C9CE8A9B3313D41F365D246111750416A8634A891313D41B4E6A05E7A175041EC51B81E72323D41E17A149EB5175041F6285C0F75333D417B14AE474F175041EE990119EE343D41AA756543FE1650412166972B6F353D41987B0A662A175041AC15D094B6343D41C4B16EA7BA175041036FA62555353D415A9E4003DC175041938A09B127373D41B47C2E96061850415E2782D03B373D41BC844FBC34185041C4DF4C907D373D4166DE27C63D185041D9610C8D37383D413D03C8CF1F1850418FC2F5E87E3A3D4152B81E950118504185DD38CA39393D4197400C8C601850410B5C08906D383D4102DB4F6A731850413CD991AC5D383D41E1DD33578F1850417219EAC88A393D414C7B98B9AA185041
7101520	C06_I99_003_02	Porte à porte (OMR-CS) et points d'apport volontaire (Verre)	\N	99	\N	\N	2019-12-20	00	99-00-05	38057 / 38059 / 38068 / 38169 / 38179 / 38185 / 38188 / 38200 / 38516 / 38317 / 38471 / 38151 / 38187 / 38071 / 38111 / 38170 / 38235 / 38126 / 38281 / 38328 / 38388 / 38421 / 38423 / 38436 / 38474 / 38485 / 38486 / 38524 / 38540 / 38545 / 38533 / 38158 / 38309 / 38150 / 38229 / 38271 / 38277 / 38325 / 38382	\N	IS628649	\N	\N	\N	N	\N	0103000020690F0000010000004B010000FFD808C7882F3D416CF60AFADD225041647ED405D9313D4180023AF3F2225041C9DB32B952323D41A1B4F748B72250414F24FA7CDB333D416BEF42F0C2225041390742B689363D410F2C1B2AB4225041B13D1EE8E0383D41A01BF6A37622504115F85AD0F7383D41871A87651022504148E17AF4973A3D4114AE4711C5225041FF55E9B38D3A3D41CF9F45812B23504137D57DF2FC393D41BBD1B55D4C2350416DA60E49F9393D41385B5EEDE423504159263D83D13A3D41A7978A67D12350413892A74A3F3B3D4180F792C19E23504147CDAF5EEC3B3D41E77BBE9E84235041DC4F0C3A333C3D415C9B94DBA1235041430677D7043D3D415BE2D497812350412E60108BA13D3D41B72896CEA623504155578314893F3D41ED538D2EBB23504196AE2C5F213F3D4195254411E5225041E4BAAA63A43F3D410D6621DEA022504142D202992B423D41B572F002DF22504148E17A94AC443D413333330383235041F6285C8F9E493D4185EB51C8E52150411F85EB11584A3D4185EB512868215041D7A370BD3C4C3D4152B81E9524215041CDCCCCCC3F4C3D4185EB5138C7205041295C8F828F4C3D4148E17A14A72050417B14AEC7A04D3D410AD7A33056205041A4703D0A8F4E3D41AE47E1AA5C20504185EB51B8B64E3D4100000040372050416E285C6F504E3D41DA7A14EC332050416466661ED34E3D41245C8FF4052050415C8FC2F5964E3D41CDCCCCEC012050410AD7A3F0B64E3D41E17A142EED1F50410AD7A330344F3D413D0AD733E61F5041F6285C8FF24E3D41E17A14AEF61F50418FC2F5A8BA4F3D41EC51B8CE2D2050415C8FC2B5CE4F3D41B81E85ABF31F5041713D0A1746513D41AE47E1DAA41F50419A9999998B513D41B81E855BAD1F504148E17A14F9513D41E17A148E661F5041DED3B44A67513D4120BA5ECE561F504185EB5178D8513D41D7A3704D561F5041A4703D0A7D523D41666666E6771F5041AE47E1FAA7553D4185EB5178A7205041B81E85AB36583D41EC51B8BE3B215041E17A14EEA7583D4148E17AC4FF205041C3F528DC09593D41295C8FE2FC20504185EB517874593D41000000E0AE20504133333373AF5A3D41C3F5288CBE2050415C8FC2F5875B3D41713D0A37922050417B14AE07905A3D41713D0A2736205041A4703D0AA95B3D4148E17A14F31F504133333373055D3D41F6285CFFD11F50413D0AD7632F5E3D41000000808A1F504148E17A942D5D3D41E17A14CE931F5041713D0A57F55B3D41295C8FB2731F50418FC2F5E8E85B3D419A9999794D1F5041B81E85EB125B3D418FC2F5080D1F5041333333335A5B3D41E17A147EE61E5041F6285C8F815A3D41295C8FB2F41E504152B81EC5E85A3D41EC51B87EC01E50413D0AD7A3415A3D4185EB5128921E504133333373A75A3D41EC51B8CE791E5041CDCCCCCCF7593D41F6285CAFFE1D5041CDCCCC0C275A3D41C3F5289CEC1D504166666666BE593D4114AE4791DF1D50417B14AE478C593D419A999939911D5041C3F528DC77583D41E17A14BE121D5041EC51B81E34593D4114AE4751BB1C504152B81E85A7583D41C3F528CC721C50413D0AD723A9573D41D7A3708D3B1C5041AE47E13A8E563D41A4703D6A121C504165C2F59889553D41478FC287141C504119B81ED5FC533D416E3D0A17571C5041A1C2F5A0F5533D41668FC273A71C5041096666FE3F533D416C14AE7DE31C5041F308928BED513D41A7682FEFB61C504108AE47F177513D4127000086C51C50416DF5282489503D41E8D6A3C6091D5041E809D7BBAE4F3D410F52B8C2741D5041E6D88441B24D3D4170B7379E031D5041DBD25A147A4D3D41B739B73A101D504146DC82AE5F4B3D41CAD06201CE1C504113BFF10DE6493D41CF4C40707F1C5041771B1940C2493D417A64C06B171C504128087632644A3D419FC7E4DAC51B504199BD3B4B114D3D41A9D687A66A1B5041C0A514A3E94C3D41AE8F89EE481B5041EB81B1416A4D3D418C9309A33C1B504169E17AD4B84C3D417CC2F594C01A504118E41500A84B3D41C3BE1975D51A50410BEE4FD8584B3D41D6407B01C21A5041329A587E864A3D4175F4DF31CE1A5041B142A54C154A3D415945463BAC1A5041094D3DA227483D4147926CD6821A5041333333B341453D41EC51B80E5C1950414DCE9C9121453D41C95B40A91E195041CA58F29760443D41A11E85BFEF185041E3C4BFDF93433D416A017D26DC185041560B26BF09423D418B25BF1129195041AFE8A2A74D403D4138BADD6C45185041C87F85397E3F3D41ADF157E330185041A946047AFD3E3D412515BB7E76185041FDAA8413DE3C3D41AE942F7D6F185041B37D5295B23B3D41DFDCB8548B1850410EACB4BD8E3A3D41D09B25678B185041CC7A1C80053A3D4152674ADBB81850413CD991AC5D383D41E1DD33578F18504160882FAF75383D41187391476F18504185DD38CA39393D4197400C8C601850418FC2F5E87E3A3D4152B81E9501185041D9610C8D37383D413D03C8CF1F185041C4DF4C907D373D4166DE27C63D1850415E2782D03B373D41BC844FBC34185041938A09B127373D41B47C2E9606185041036FA62555353D415A9E4003DC175041AC15D094B6343D41C4B16EA7BA1750412166972B6F353D41987B0A662A175041EE990119EE343D41AA756543FE165041F6285C0F75333D417B14AE474F175041EC51B81E72323D41E17A149EB5175041D1C6A43F9C313D41CC8D591F7E1750419C9CE8A9B3313D41F365D2461117504146E3FC7E63323D419DED3220BC165041D01EC5472A323D4140A471489F16504146625DA286323D41255B5C5976165041980215F7D0323D41C13F8005B415504188CEE78155323D417AB00DCAA3155041BBC1F0A520313D412D741D2F351550412ABA370CCD303D417CFE119B541550416673895427313D410CB509EF0C155041853BD3C2602F3D4110F321F44A1450410AD7A3B03D363D413D0AD7C3F212504194E4A2722E363D41551ABBDCBE1250414C630FA12E353D41AAEB9EA3D71150413399C08741333D41D3411F0AD910504159F19CAEF2323D41A8F4C570E5105041FBF2A55095313D41192E18FE7210504187335127862F3D41CDDBAEB1900F5041E69D774DFE2E3D4104C972152C0F5041DD326770AF2E3D413819CB5FD20E5041C839F1D09F2E3D41DBEB8A52F80D5041618DFC47C02D3D41D687ED04220D50418B5444E4982D3D41DCA9C13C760C5041E727CC24A32E3D41F2109E77A00B504143DCD5AEE92D3D41B408D6D2FF0A5041E02C18058F2C3D413992EEC0C10A504151A3DC871A2C3D41B8CE744E940A504178E81B6EB32B3D410C53C710AB09504152B81EC5992A3D41713D0A077F09504152B81EC5F2283D411F85EBB19B09504114AE47A17F273D4100000050D30950411F85EB5175273D41F6285C5F0F0A5041CDCCCC0C25263D4114AE4751E6095041CDCCCCCCD7253D41295C8F62380A5041666666A611233D41EC51B80E910A5041E17A146E10233D411F85EB11BF0A5041CDCCCC0CA8213D417B14AE67CA0A5041EC51B85E05213D41A4703D4ABA0A50410AD7A3B0E31F3D41D7A370CD280A5041295C8F820B1F3D411F85EBF17B095041A4703D4A571F3D41EC51B84E4309504148E17A14CA1D3D415C8FC2B56B0850411F85EBD1C41D3D41666666561E085041333333F3751E3D4185EB5118CE075041A4703DCA6F1E3D410AD7A3E0430750413D0AD7A3AF1D3D41295C8FA202075041B81E852B201D3D41295C8F9274065041AE47E17A761C3D41713D0A2759065041CDCCCC4C731C3D41EC51B85E27065041713D0AD7891B3D417B14AE57F805504152B81E45AC1B3D41B81E85FBCD0550418FC2F5A8E51A3D417B14AEA797055041D7A3707D041B3D4152B81E3573055041CDCCCC4CA61A3D410AD7A3A0470550417B14AE4749193D41713D0A673C0550418FC2F528E0183D418FC2F59814055041000000C061173D41333333A3E8045041C3F528DC7E163D4152B81EC5F60450417B14AE07C4153D4100000090E8045041666666A641133D41D7A3706D97045041000000C094123D419A9999898F04504133333333B8113D4152B81E85A8045041AE47E1FA10113D41AE47E1AA680450417B14AEC7F30F3D41713D0A774E0450417B14AEC7170E3D4133333313770450413D0AD7E3740B3D410000003003045041CDCCCC4C68093D41713D0A57F4035041C3F5281C90083D41D7A370DD45045041CDCCCC8C42083D410AD7A3408A0450413D0AD763E8083D4114AE47017804504185EB51F8420A3D413D0AD7E397045041666666E6710D3D41E17A143E92055041CDCCCC0C37103D411F85EB1135065041E17A146E5F123D4148E17A34FA0650412D72E41E7F123D4196CC5B802007504114AE4761E00F3D411F85EB31C6075041E17A14AEFE093D411F85EB71BE0850413D0AD763720A3D415C8FC265EF085041AE47E17A380A3D4185EB51C820095041F6285C4FE50A3D41EC51B82E3A095041D7A3707D030B3D415C8FC22564095041B81E852B920A3D413D0AD7A398095041E17A142EDA0A3D410AD7A370FC095041CDCCCC4C950C3D4133333343BC0A50419A999959560E3D41AE47E1EA560C504133333333150F3D4166666616F50D5041C3F528DCA0103D41E17A143E8F0F5041333333F3AB123D4185EB513898105041EC51B85E31133D41AE47E18A5C11504148E17A14B7143D4152B81E6505125041713D0A5787143D4148E17A444D1250418FC2F5A8DA153D41A4703D5A6A125041F6285C4F0F163D41713D0AE7991250411F85EB9169153D4148E17AA4541350410AD7A3300C173D41A4703D7AB7145041D7A370FDDC163D411F85EB81DC145041E17A14AE0C183D4152B81E955A165041A4703D4AE9173D41A4703D0ADB1650418FC2F5688B193D419A999989751750418FC2F5A8E71A3D415C8FC25547185041B81E85AB5C1B3D41295C8FB2E618504196B53345AB1D3D41A9569F02D9185041713D0AD7671B3D416666668603195041713D0A57DA1A3D4114AE47D15919504148E17A14611B3D41C3F528DCF01950419A9999993D1C3D41333333E3561A5041713D0AD7461C3D4148E17A04B01A504152B81EC5A61B3D41A4703DEAD41A504100000040E81B3D4148E17A44E61A5041CDCCCC4CAA1C3D41AE47E1CAE51A50417B14AE07881E3D4100000070C01A5041333333F35E1F3D41B81E859BF91A5041E17A142EA41E3D418FC2F5C8231B504148E17A14F31E3D4152B81E85571B50413D0AD7A3011E3D41000000104C1B5041295C8F02581D3D419A9999B9741B50410AD7A3F09B1C3D41D7A3705DDA1B50411F85EB51C51D3D41AE47E17ADF1B5041713D0A17CA1D3D41CDCCCCDCFC1B504100000040461D3D4114AE47B10A1C504100000080601D3D41713D0AD7931C5041CDCCCCCCD71C3D4185EB51289D1C5041E17A14EE2D1D3D4166666686E91C50410AD7A330021D3D41C3F528BC1D1D504166666626C11D3D4114AE4741121D504133333373E71D3D41713D0AF7351D5041B81E85ABA21E3D415C8FC2A52B1D5041A4703D4A3A1E3D41EC51B86E871D504148E17A94491E3D41333333E3951D5041694A7AB69E1E3D413DAD9B567B1D5041F6285CCF4F1E3D410AD7A3008D1D50410AD7A3B05B1E3D41333333B3241E504148E17A54FE1D3D41F6285C2FA61E5041A4703DCA331D3D4185EB51F88B1E50413D0AD7A3EC1B3D41C3F5286C2D1E50415C8FC2B5171A3D411F85EBA1F21D5041713D0A1780183D41713D0AD76A1E5041E17A146EB0173D4152B81EF5441E50411F85EB1151173D4152B81E05501E5041EC51B89E50183D41B81E859BA71E5041295C8F8248183D4148E17A648E1E5041713D0A57AD183D415C8FC2F5CF1E504152B81E8578193D41295C8F32EB1E5041D7A370FDDB173D4133333373181F50410000000062173D41666666966E1F5041EC51B8DE46173D417B14AEE7341F50410000008096153D413D0AD773851F5041E17A14AEE6143D41333333C36E1F5041666666667F143D4185EB5168A91F5041EC51B89EA2153D418FC2F5C8932050419A99991993153D41B81E85ABD22050410AD7A3702B153D4114AE47D1D020504148E17A94FE143D41000000908A20504114AE4721DA133D41A4703DDAA0205041713D0A174C123D410AD7A3C00A215041F6285C8F5E113D41CDCCCC8CF9205041B81E856B29113D419A999979CE205041713D0A5707113D413333339302215041E17A14AEFD0E3D41000000307F2150417B14AE07600E3D415C8FC235F62150419A9999D9A70D3D41AE47E1DA32225041AE47E17A170D3D41F6285CFF4B22504152B81E45000C3D41B81E858B5022504166666626D40A3D41333333437D2250419907101820093D41FA8575B136235041EC51B89E8E083D410000006021235041A4703D0AD0073D415C8FC2C52E2350410AD7A3F0D4063D41B81E858B0E23504114AE47A1B9043D4114AE4731CC23504148E17A1421053D41333333E31A2450413D0AD723C1053D41295C8F022C2450417B14AE4782053D41F6285C7FA1245041713D0AD702063D41713D0A47EB245041333333B3C9043D41D7A3700D48255041F6285C8FC7053D41295C8F428025504185EB513832073D410AD7A39092255041D7A370FD34083D4148E17A14EC2550418FC2F5A8E1083D41000000D002265041D7A3707D71093D41A4703DCA372650418FC2F5A86D093D4114AE47116426504114AE47E18F0A3D41C3F528CCA22650413D0AD763F10C3D418FC2F5987E275041E17A142E280D3D41713D0AA7B9275041713D0A17390C3D41E17A14FECE27504185EB5138DE0B3D4152B81E85F7275041B81E85EBF30D3D41EC51B85E4A2950410AD7A33001123D410AD7A320B5285041295C8FC29D133D41D7A370ED722650410AD7A37085143D41E17A146EF0255041C3F528DCD1183D41B81E857BAE245041ABD76FE78F1A3D410C8E051F612450411830E210051D3D41B7891E3DC323504182890DC8CC1E3D41E5B012790523504133326212AE223D418002752CA0235041D40943E6F4233D41768CED4596235041A43C8D9068253D414B0BA7A3FF2350412ACD1A49D8263D4177FB9DE0B5235041AC2AE668C2273D415FD3810C062450417C1E851B79283D41EEFFFFDBE02350418609D7E35A283D413885EB2171235041F3F528ACD7283D41823D0A974F235041B50EB67A9D293D411153C8B447235041CF20FC6B452A3D410CDF9BFEA92350413C52B89EE52A3D41A31E85EFC6235041863616303C2B3D41D23F75B8A2235041E9B81E95C92B3D41A5F52814B6235041F4713D2A102D3D41ADCCCCD46E2350412F83DBCD912E3D4153A7F8838A235041FFD808C7882F3D416CF60AFADD225041
7101523	C06_I99_003_02	Porte à porte (OMR) et points d'apport volontaire (CS-Verre)	\N	99	\N	\N	2019-12-20	00	99-00-06	38179 / 38533 / 38271	\N	IS628651	\N	\N	\N	N	\N	0103000020690F00000100000016000000A4703D4A77503D41713D0AF70D1B5041F6285C0F1B503D419A999919001B5041CDCCCC0CA04F3D4114AE47011B1B5041333333B3E94D3D41295C8FB2291B5041112CD06BEC4C3D4163E873BD471B50414BE924DD134D3D419EBB202D6A1B504128087632644A3D419FC7E4DAC51B5041771B1940C2493D417A64C06B171C504113BFF10DE6493D41CF4C40707F1C504146DC82AE5F4B3D41CAD06201CE1C5041DBD25A147A4D3D41B739B73A101D5041E6D88441B24D3D4170B7379E031D504153FAA0FBC14F3D4176DE328B751D50416DF5282489503D41E8D6A3C6091D5041AE4FC21767513D41A26A4A71C81C5041F308928BED513D41A7682FEFB61C5041096666FE3F533D416C14AE7DE31C5041A1C2F5A0F5533D41668FC273A71C504119B81ED5FC533D416E3D0A17571C504165C2F59889553D41478FC287141C504114AE476127533D41E17A146E711B5041A4703D4A77503D41713D0AF70D1B5041
\.


--
-- Data for Name: plan_b3_psc_02_captage_pct; Type: TABLE DATA; Schema: urba_plui_public; Owner: -
--

COPY urba_plui_public.plan_b3_psc_02_captage_pct (idprescription, idurba, libelle, txt, typepsc, nomfic, urlfic, datevalid, stypepsc, lib_cnig_epci, lib_code_insee, lib_etiquette, lib_idpsc, lib_labeling_positionx, lib_labeling_positiony, lib_legende, lib_modif, lib_modif_comment, geom) FROM stdin;
1741306	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38562	\N	PP151907	\N	\N	\N	N	\N	0101000020690F00005A1575EEA0423D4117EA533F5E105041
1741250	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151896	\N	\N	\N	N	\N	0101000020690F0000067A063A7D213D41CBF622E8BA155041
1741251	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38478	\N	PP151932	\N	\N	\N	N	\N	0101000020690F00009AE365806D5A3D4158B5E837C5115041
1741470	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151987	\N	\N	\N	N	\N	0101000020690F00002936DB0402213D417655AFED26155041
1741325	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38187	\N	PP151887	\N	\N	\N	N	\N	0101000020690F0000AE23E00EA21B3D41A4FC56BA3B0C5041
1741326	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151959	\N	\N	\N	N	\N	0101000020690F0000E55083C6766C3D414EF863A8471C5041
1741327	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38528	\N	PP151915	\N	\N	\N	N	\N	0101000020690F0000FC8764BD3B4E3D41B5E380952E135041
1741328	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38187	\N	PP151902	\N	\N	\N	N	\N	0101000020690F0000AA1BE411CC133D4160AF469D4A095041
1741329	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38364	\N	PP151943	\N	\N	\N	N	\N	0101000020690F0000FA46E490DE513D4189356437BF0C5041
1741274	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38281	\N	PP152014	\N	\N	\N	N	\N	0101000020690F00004BE9CA397A143D41B4A2EFEC10225041
1741343	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38277	\N	PP151992	\N	\N	\N	N	\N	0101000020690F00009A0DC096C0333D410E57A727A40A5041
1741356	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38486	\N	PP151925	\N	\N	\N	N	\N	0101000020690F00008AD32AE115243D4117CC2309201A5041
1741484	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151980	\N	\N	\N	N	\N	0101000020690F00004240AF9820683D411443D3A5C9185041
1741468	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38279	\N	PP151990	\N	\N	\N	N	\N	0101000020690F0000ACA5F3DCF83D3D41E59BAE3FBB0F5041
1741270	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38111	\N	PP151998	\N	\N	\N	N	\N	0101000020690F000081B4E8591E213D4175284FA664175041
1741249	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38485	\N	PP151931	\N	\N	\N	N	\N	0101000020690F000076C743B99C1E3D41FA8FF4D0C01A5041
1741307	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38436	\N	PP151923	\N	\N	\N	N	\N	0101000020690F0000C130920BFB173D41929582B0D50E5041
1741308	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151892	\N	\N	\N	N	\N	0101000020690F000036A26FDA0C213D41DE5A701D2B155041
1741309	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38445	\N	PP151955	\N	\N	\N	N	\N	0101000020690F000084FC15062F463D4192737218C40E5041
1741310	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38325	\N	PP151944	\N	\N	\N	N	\N	0101000020690F0000E3AA48D1652C3D41DB6EE45590265041
1741311	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38471	\N	PP151937	\N	\N	\N	N	\N	0101000020690F0000C3B0654AC1463D417B6BF8B3DC265041
1741312	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38472	\N	PP151940	\N	\N	\N	N	\N	0101000020690F000006660CAF47423D41A5DE965A08285041
1741313	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38325	\N	PP151946	\N	\N	\N	N	\N	0101000020690F0000B0FC84BAE2333D411DA3BB313D275041
1741314	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38364	\N	PP151941	\N	\N	\N	N	\N	0101000020690F000067EEAB3134553D412AF9B186960D5041
1741315	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38258	\N	PP151947	\N	\N	\N	N	\N	0101000020690F000020265EEE28273D4177EDB3E909275041
1741316	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38187	\N	PP151950	\N	\N	\N	N	\N	0101000020690F0000905B52F7F31A3D410E2C2605040A5041
1741317	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38445	\N	PP151951	\N	\N	\N	N	\N	0101000020690F000025679F2F55463D411D21CDC0C80E5041
1741318	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38445	\N	PP151952	\N	\N	\N	N	\N	0101000020690F000002588EF65E463D419E406DFBC20E5041
1741319	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38524	\N	PP151984	\N	\N	\N	N	\N	0101000020690F000057B66AE08E303D419AA4848C45135041
1741320	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38436	\N	PP151924	\N	\N	\N	N	\N	0101000020690F0000ABD9DBD39B173D41723E274C1E115041
1741321	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38486	\N	PP151927	\N	\N	\N	N	\N	0101000020690F000047E882C3AE233D41986AB69A351A5041
1741322	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151967	\N	\N	\N	N	\N	0101000020690F0000BF8C49A1306B3D41918CAECD651C5041
1741323	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151889	\N	\N	\N	N	\N	0101000020690F00001B2FDD2414203D41749318FCE9155041
1741252	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38279	\N	PP152016	\N	\N	\N	N	\N	0101000020690F0000C7AE0C82C23D3D417C0DF19EA30F5041
1741253	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38545	\N	PP151911	\N	\N	\N	N	\N	0101000020690F00006A4965F58B243D41CE56C310BF0A5041
1741254	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151973	\N	\N	\N	N	\N	0101000020690F0000A1D2BA093B693D41B0E4C4E122195041
1741403	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38478	\N	PP151996	\N	\N	\N	N	\N	0101000020690F000047B6E13C2D5B3D410A4243BFE7115041
1741271	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38281	\N	PP152011	\N	\N	\N	N	\N	0101000020690F00002891785B400C3D41E2A01B38D3225041
1741273	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38545	\N	PP152008	\N	\N	\N	N	\N	0101000020690F00003ED64815112F3D41F169D2127B0F5041
1741293	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151972	\N	\N	\N	N	\N	0101000020690F0000AC05944F5A693D41A721788CFA185041
1741294	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151962	\N	\N	\N	N	\N	0101000020690F00000D1480C12B6B3D41769CE614281C5041
1741266	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38545	\N	PP151913	\N	\N	\N	N	\N	0101000020690F0000152A3CA23A243D4153F80C98F70A5041
1741268	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38279	\N	PP152015	\N	\N	\N	N	\N	0101000020690F000048FD05D4933D3D416AC83FFB840F5041
1741278	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38445	\N	PP151954	\N	\N	\N	N	\N	0101000020690F00002FE3B0CF36463D4134B84194BE0E5041
1741279	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151895	\N	\N	\N	N	\N	0101000020690F000006020DDB20213D41B0186F19C4155041
1741283	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151893	\N	\N	\N	N	\N	0101000020690F00002936DB0402213D417655AFED26155041
1741284	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38472	\N	PP151995	\N	\N	\N	N	\N	0101000020690F0000D9A9A515103D3D414D650B2EFA275041
1741324	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151976	\N	\N	\N	N	\N	0101000020690F0000E2B29AF397683D41FE3AB44631195041
1741291	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151966	\N	\N	\N	N	\N	0101000020690F00006B5F83732D6B3D41CE22E0625E1C5041
1741292	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151965	\N	\N	\N	N	\N	0101000020690F0000C960BB454A6B3D417B0C8B00641C5041
1741297	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38486	\N	PP151929	\N	\N	\N	N	\N	0101000020690F000085918EA7BA233D410500B292301A5041
1741298	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38258	\N	PP151949	\N	\N	\N	N	\N	0101000020690F0000F50197CC89263D413B8F2DD9D0265041
1741299	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151957	\N	\N	\N	N	\N	0101000020690F00000D88F2540B6C3D419FFCBFBC031C5041
1741300	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151986	\N	\N	\N	N	\N	0101000020690F00002936DB0402213D417655AFED26155041
1741301	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151981	\N	\N	\N	N	\N	0101000020690F0000613CDD4213683D41FE025E3CBB185041
1741302	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151898	\N	\N	\N	N	\N	0101000020690F0000EDFBF2BDB1213D41838468D0A1155041
1741303	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38478	\N	PP151934	\N	\N	\N	N	\N	0101000020690F0000C7C8007126523D41BB5E16B355105041
1741304	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38486	\N	PP151930	\N	\N	\N	N	\N	0101000020690F0000CF453D7D52223D4100DA999A631A5041
1741305	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38364	\N	PP151942	\N	\N	\N	N	\N	0101000020690F0000C31731A586523D419738CC15D20C5041
1741333	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38471	\N	PP151938	\N	\N	\N	N	\N	0101000020690F000022985191BB463D41919F5EBBCF265041
1741413	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38562	\N	PP151906	\N	\N	\N	N	\N	0101000020690F000066E709B6D4423D41168AB72A61105041
1741336	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38445	\N	PP151953	\N	\N	\N	N	\N	0101000020690F0000D0282DCC53463D417C82A682BE0E5041
1741339	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38478	\N	PP151999	\N	\N	\N	N	\N	0101000020690F00001C58B29A92533D41238DE62C6A105041
1741340	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38111	\N	PP152004	\N	\N	\N	N	\N	0101000020690F00007583856A62213D415F8474756A175041
1741341	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38516	\N	PP151900	\N	\N	\N	N	\N	0101000020690F00001D41AE5BED3B3D4164CA8D1AE0215041
1741426	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38545	\N	PP151909	\N	\N	\N	N	\N	0101000020690F00007FEB89F223273D41C7922A8F310B5041
1741350	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151988	\N	\N	\N	N	\N	0101000020690F00002936DB0402213D417655AFED26155041
1741351	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151975	\N	\N	\N	N	\N	0101000020690F0000C10E3F8998683D41611E498C1D195041
1741352	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38528	\N	PP151969	\N	\N	\N	N	\N	0101000020690F0000A79E8B6372523D41ABA5C44E6D155041
1741360	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38279	\N	PP152017	\N	\N	\N	N	\N	0101000020690F00009334EFC5E63D3D41BE02B77FB20F5041
1741363	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38187	\N	PP151914	\N	\N	\N	N	\N	0101000020690F0000EFAE927D821B3D4129FF4339390C5041
1741457	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38562	\N	PP151905	\N	\N	\N	N	\N	0101000020690F0000ED26EA1CF5423D417FDB7BDE6A105041
1741377	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151894	\N	\N	\N	N	\N	0101000020690F0000F7F34880B5213D416D93DC9D33155041
1741378	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151897	\N	\N	\N	N	\N	0101000020690F00002BDF3C08B4213D41B4D56AF0A8155041
1741379	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151888	\N	\N	\N	N	\N	0101000020690F0000BC74933838203D4177BE9FAAEC155041
1741373	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151891	\N	\N	\N	N	\N	0101000020690F00004C3789A1F1213D41FED478D955155041
1741383	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38528	\N	PP151917	\N	\N	\N	N	\N	0101000020690F00003FCC0BFA53583D41597D165F00145041
1741385	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38364	\N	PP151936	\N	\N	\N	N	\N	0101000020690F0000FA16B3A031573D414920C68F260E5041
1741391	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38445	\N	PP151908	\N	\N	\N	N	\N	0101000020690F000031EB877F08463D411569E4EBFE0E5041
1741477	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38436	\N	PP151922	\N	\N	\N	N	\N	0101000020690F000046B6F31DF6173D4177BE9F52C10E5041
1741406	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151974	\N	\N	\N	N	\N	0101000020690F0000011632EC89683D4126A305D620195041
1741407	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38388	\N	PP152005	\N	\N	\N	N	\N	0101000020690F000013D35058B5333D414937AED8D20C5041
1741408	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151963	\N	\N	\N	N	\N	0101000020690F00003B6A695C376B3D4182307E92271C5041
1741440	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38528	\N	PP151918	\N	\N	\N	N	\N	0101000020690F00007D5807D3C2573D4189367F3515145041
1741441	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38524	\N	PP151919	\N	\N	\N	N	\N	0101000020690F00007CFF7CE1F22C3D41EE3487C641145041
1741415	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151899	\N	\N	\N	N	\N	0101000020690F0000B81E858B601A3D416F12838800145041
1741417	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38478	\N	PP151956	\N	\N	\N	N	\N	0101000020690F0000D3E170B2B7533D419B7E6166E0105041
1741442	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38524	\N	PP151920	\N	\N	\N	N	\N	0101000020690F000021A83B434F2F3D41096951F88D135041
1741443	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38486	\N	PP151928	\N	\N	\N	N	\N	0101000020690F00006A335FE6A5233D41F8C25136301A5041
1741419	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38281	\N	PP152010	\N	\N	\N	N	\N	0101000020690F00003AB6D6D6D70B3D41CEEA7CF9B5225041
1741420	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151968	\N	\N	\N	N	\N	0101000020690F00000EDF3E75866A3D41F69308BB621C5041
1741421	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38111	\N	PP151997	\N	\N	\N	N	\N	0101000020690F000086031B7B5D213D414A7483996F175041
1741423	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151958	\N	\N	\N	N	\N	0101000020690F0000332C75C1EB6B3D41E2BEEC78331C5041
1741424	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151961	\N	\N	\N	N	\N	0101000020690F00008A2F943BF46A3D4125E43C502B1C5041
1741425	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38528	\N	PP151916	\N	\N	\N	N	\N	0101000020690F0000E81598BD7C4F3D41D340F5C583155041
1741438	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38277	\N	PP151993	\N	\N	\N	N	\N	0101000020690F00005D27C8D02C333D4178F103CAA00A5041
1741478	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38486	\N	PP151926	\N	\N	\N	N	\N	0101000020690F00007A8EDC7DCD233D41C86F4CD31B1A5041
1741432	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38524	\N	PP151983	\N	\N	\N	N	\N	0101000020690F0000ABFC022269313D413657F13A3B135041
1741433	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151979	\N	\N	\N	N	\N	0101000020690F0000FE0AC90CF9673D41A0FD8C07ED185041
1741454	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38471	\N	PP151939	\N	\N	\N	N	\N	0101000020690F000039052A8C6E413D410F2E056117275041
1741465	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38478	\N	PP151935	\N	\N	\N	N	\N	0101000020690F0000A673034813573D41022C0CD834105041
1741466	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38325	\N	PP260844	\N	\N	\N	N	\N	0101000020690F00004F1F67407F2C3D41BC22863C21265041
1741467	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151971	\N	\N	\N	N	\N	0101000020690F00009FA3F28A51693D41F48A0CB4F4185041
1741490	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38472	\N	PP151994	\N	\N	\N	N	\N	0101000020690F0000FB38F94F853D3D414267E1FC09285041
1741463	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38545	\N	PP151910	\N	\N	\N	N	\N	0101000020690F00005FAB578DEE263D41FF8202E54F0B5041
1741464	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38545	\N	PP151912	\N	\N	\N	N	\N	0101000020690F00005966E6733C253D41AE9085B0D00A5041
1741472	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151985	\N	\N	\N	N	\N	0101000020690F000036A26FDA0C213D41DE5A701D2B155041
1741473	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151970	\N	\N	\N	N	\N	0101000020690F00007BBED2AE44693D4135B7A0CCF5185041
1741476	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38524	\N	PP151921	\N	\N	\N	N	\N	0101000020690F00004D6582B272353D41384F8B3EAD125041
1741480	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151890	\N	\N	\N	N	\N	0101000020690F0000C29C2C30801F3D4121A04EC4C9155041
1741481	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151982	\N	\N	\N	N	\N	0101000020690F00005329A786BA683D41F5A4C0BCB41C5041
1741485	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151960	\N	\N	\N	N	\N	0101000020690F000006D8724C6E6C3D41104BC147461C5041
1741487	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151977	\N	\N	\N	N	\N	0101000020690F00006439D5EB33683D412F29B83748195041
1741500	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38472	\N	PP152007	\N	\N	\N	N	\N	0101000020690F0000A16C17AA6C3A3D41BBADF79937285041
1741502	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38258	\N	PP151948	\N	\N	\N	N	\N	0101000020690F0000D1995557FC263D41787880B5DE265041
1741519	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151964	\N	\N	\N	N	\N	0101000020690F00008752DC395B6B3D4129F6359E691C5041
1741526	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38170	\N	PP152001	\N	\N	\N	N	\N	0101000020690F0000380BA57D6B253D4186174FB500245041
1741530	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	\N	\N	PP151978	\N	\N	\N	N	\N	0101000020690F00002C7C11B8F4673D41E52ACD20F6185041
1741543	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38281	\N	PP152012	\N	\N	\N	N	\N	0101000020690F0000269A218EF7153D41722C42DF33225041
1741551	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38516	\N	PP151901	\N	\N	\N	N	\N	0101000020690F00008D28937E0A3C3D41BF45B0ADD9215041
1741562	C06_P02_001_05	Captage avec arrêté de DUP	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-DUP	38111	\N	PP151886	\N	\N	\N	N	\N	0101000020690F00003CCABAE3BA203D4116226BF3D6155041
1741564	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38281	\N	PP152013	\N	\N	\N	N	\N	0101000020690F0000652607F307153D4129335AEBD6215041
1741565	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38388	\N	PP152003	\N	\N	\N	N	\N	0101000020690F0000AC28DE3E61383D413B0A9737610C5041
1741568	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38111	\N	PP152000	\N	\N	\N	N	\N	0101000020690F0000CA236F9E4C213D41A26C767E59175041
1741570	C06_P02_001_05	Captage avec rapport hydrogéologique	\N	02	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/3_1_Reglement_ecrit/T1_1_REGLES_COMMUNES_LEXIQUE.pdf	2019-12-20	01	02-01-RH	38382	\N	PP151991	\N	\N	\N	N	\N	0101000020690F00000DDC18F92B293D41D7321AE0C8225041
\.


--
-- Data for Name: plan_b3_psc_18_oap_air_lin; Type: TABLE DATA; Schema: urba_plui_public; Owner: -
--

COPY urba_plui_public.plan_b3_psc_18_oap_air_lin (idprescription, idurba, libelle, txt, typepsc, nomfic, urlfic, datevalid, stypepsc, lib_cnig_epci, lib_code_insee, lib_etiquette, lib_idpsc, lib_labeling_positionx, lib_labeling_positiony, lib_legende, lib_modif, lib_modif_comment, geom) FROM stdin;
1764434	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38229	\N	PL149399	\N	\N	\N	N	\N	0102000020690F0000020000005852741429493D410E3E5EE2332050415DCF60EC57493D4164A2FCB7A81F5041
1764423	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149397	\N	\N	\N	N	\N	0102000020690F000002000000DB2DDD11A2373D41E801A1F9021D5041A0CB2A2BFA363D41FE1C82030D1D5041
1764475	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185,38423	\N	PL149389	\N	\N	\N	N	\N	0102000020690F000007000000E9D341D2F6273D41A4DD72B93520504140777AB5792C3D41C5E4D731CB1F5041D22CA68387303D4168141D89461F5041AB91338615323D41C02A1D9BD41E50414C13AE370D323D41F427F4FC611E50410E09D7E357323D41F015E07D301E5041AAABFABC6D333D413C4D694F0E1E5041
1764428	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38421	\N	PL149409	\N	\N	\N	N	\N	0102000020690F0000020000009F8A603D3F453D410100A1D9801C5041AD97C193E8443D4157910C97821C5041
1764432	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38317	\N	PL149369	\N	\N	\N	N	\N	0102000020690F000002000000D4078ABF852C3D41B6B3CF25A11750417D05D344872C3D41E0E8A9DFA6175041
1764424	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38317	\N	PL149370	\N	\N	\N	N	\N	0102000020690F0000020000007D05D344872C3D41E0E8A9DFA6175041BCE1369A902C3D41851AA5EDAE175041
1764425	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149376	\N	\N	\N	N	\N	0102000020690F000002000000EFF7C316912E3D4131194235E31D504172E7481EAA2F3D413A91239AC61D5041
1764426	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38151	\N	PL149367	\N	\N	\N	N	\N	0102000020690F000002000000199C8046C1303D41D24145676B195041BD9D3CBCE12F3D41E83C115E85195041
1764427	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38229	\N	PL149401	\N	\N	\N	N	\N	0102000020690F000002000000352D3544A6403D4119A02F890D1F5041BD62CC4DDD3F3D415126388F321F5041
1764436	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149418	\N	\N	\N	N	\N	0102000020690F0000020000000B004DD484323D416663D37CA21A50410991CBEFED343D410EE624D6AE1B5041
1764437	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38423,38185	\N	PL149387	\N	\N	\N	N	\N	0102000020690F000003000000AB91338615323D41C02A1D9BD41E504111ECD0B4CD323D4129C7CFF87E1E50414EADB6520B333D41585A49FD1A1E5041
1764429	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38229	\N	PL149400	\N	\N	\N	N	\N	0102000020690F000002000000D33B9BE533463D41D1118AD7F61F50418DD22B75D3463D41399AED347D1F5041
1764435	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38169	\N	PL149374	\N	\N	\N	N	\N	0102000020690F0000020000009A063D9B6D2D3D41657E71D39A1D50412A5AB1BFB42D3D417D3543BC9A1D5041
1764430	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38158,38185	\N	PL149383	\N	\N	\N	N	\N	0102000020690F000003000000D35D983C0A3A3D41D5B0C613B9185041442C219F45383D41D806D50871195041DF81C0DA26383D41BA467948621A5041
1764431	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38474,38185	\N	PL149378	\N	\N	\N	N	\N	0102000020690F00000300000025E6385568273D41EE55591E291F50418D617FC9D0273D412EA14C0D771F5041DAA1928A73283D412EE546CBA31F5041
1764438	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38486,38485,38151	\N	PL149175	\N	\N	\N	N	\N	0102000020690F0000030000003B59FD709A2D3D416C674B25441A504110E7D9CC9A2B3D41B7CE6DC46D1A50415CF958DFCE2A3D4189E744762B1B5041
1764439	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149406	\N	\N	\N	N	\N	0102000020690F000006000000F3B7FCB7DD363D41DEB41C0A8E1D504174EA93D37B373D41122A569B911D50415088D0F738373D41728B5DECAC1D504157328945BA363D4163A4FDF59A1D5041F3B7FCB7DD363D41DEB41C0A8E1D5041540C4F8FDE343D41360744A2461D5041
1764440	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185,38423	\N	PL149380	\N	\N	\N	N	\N	0102000020690F000003000000DE301F35412D3D410BC4E7A6511F504176B33748BE2D3D41E82E534DA71F504140777AB5792C3D41C5E4D731CB1F5041
1764441	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149377	\N	\N	\N	N	\N	0102000020690F0000050000007AC54BE7B02E3D41B4588D1FB81D50418860E5AF71303D41892BAC5E2B1E5041800A03A6F72F3D41CB60F95C951E504160925D1F812B3D416E9E93F9B21F5041FA514447D5283D41C8D23479D61F5041
1764442	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38229,38126	\N	PL149404	\N	\N	\N	N	\N	0102000020690F00000200000011C707F53E3F3D41F06BEE33DA1F5041A77633B92C413D419865E7C630205041
1764443	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149394	\N	\N	\N	N	\N	0102000020690F00000200000096E4631A85333D41ED3AB39AEB1D504163066A54C2353D41B9B586F2D91C5041
1764444	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38421	\N	PL149411	\N	\N	\N	N	\N	0102000020690F000004000000DA3C00D1343F3D41EEC985473F1B50411AAE94659F3E3D414E460A47721B5041160B029B1B3F3D415F384C6ED01B50419D6E5FB7F73F3D419FDC2B85921B5041
1764445	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38485	\N	PL149174	\N	\N	\N	N	\N	0102000020690F000002000000A84B6039A12B3D41D16B16003C1C50416EE51D37A22B3D41858B51B1931C5041
1764446	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149379	\N	\N	\N	N	\N	0102000020690F000003000000D4FEFFAF702B3D4114726F10641F50419490526D592C3D4145EA063C2A1F5041DAB062B71A2D3D4143DCE6F05A1F5041
1764447	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149373	\N	\N	\N	N	\N	0102000020690F000003000000B3E3C2D7052F3D416887294E371B504110E7D9FC0E2F3D41254913B9861D50416F81F3E4962E3D4185B81222B31D5041
1764471	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149396	\N	\N	\N	N	\N	0102000020690F0000020000000A91CB9F14323D41F3F3E22EB71D50414DADB682E2343D41A6BC59CDE21D5041
1764448	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38169,38185	\N	PL149375	\N	\N	\N	N	\N	0102000020690F000002000000DF6A1964FF283D41DBDABB71CF1D5041D7E1F073C62D3D4199592C8EE61D5041
1764449	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149407	\N	\N	\N	N	\N	0102000020690F0000030000000C78580880373D41A0103D9B921D50416FF73136A4393D418CD1767EA01D50419B3A4EA1733A3D4112E84FA5491D5041
1764450	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38151	\N	PL149371	\N	\N	\N	N	\N	0102000020690F0000020000007B5F5432142E3D419D740959381950415807DD31242D3D41344759C845195041
1764451	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149419	\N	\N	\N	N	\N	0102000020690F000002000000DB2DDD11A2373D41E801A1F9021D5041DFE7B75F32373D41A85662F8391D5041
1764452	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38229	\N	PL149403	\N	\N	\N	N	\N	0102000020690F00000200000026F4B92A0E3F3D41E0E82D38F71E50417A0085D714463D410BB032FF611F5041
1764453	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38486	\N	PL149366	\N	\N	\N	N	\N	0102000020690F000004000000A1EC5657112B3D41021FB1FDE319504113F063BCBB2B3D41EA459B6DE219504106BE69DE3F2C3D4167BD70A9F81950413C8530B7792C3D417639926B511A5041
1764454	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38229,38516	\N	PL149402	\N	\N	\N	N	\N	0102000020690F000002000000BD62CC4DDD3F3D415126388F321F50418269A33F543D3D41F946C9638F1E5041
1764455	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149381	\N	\N	\N	N	\N	0102000020690F000007000000800A03A6F72F3D41CB60F95C951E5041EF4F70836B313D410D41A9ECB51E5041CA9F67C3D2313D41FBEC8376231E50416BCD0D3796323D415774CD8FFD1D504159B1607387333D4196553BF0ED1D5041557BD03313363D41FDA889D81D1E5041CF8F7EDB91373D41BA48A4B7791E5041
1764456	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185,38421	\N	PL149410	\N	\N	\N	N	\N	0102000020690F0000020000007CF10202BC433D410647556E9C1C5041B06F60B03C3A3D4179E2620B6E1D5041
1764467	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38485,38185	\N	PL149417	\N	\N	\N	N	\N	0102000020690F0000030000004B26E37ECC2D3D4129385B698D1C5041117858F86D2B3D411D726FE08F1C5041B32CA97DFC293D418679F6A70F1D5041
1764457	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149416	\N	\N	\N	N	\N	0102000020690F00000400000066D12A296D373D417AA2A398191D5041A3A379C197353D417CFCE4E5CB1C5041DC359F0455343D419053BBC2AF1C50413E08F9C0A02E3D415951BFE58D1C5041
1764458	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149408	\N	\N	\N	N	\N	0102000020690F000004000000187A834F6E3B3D41AAA3E66D8A1D50418FA7A4CED9393D4125FC8EBB241D5041FB1F1F44FD373D412E5B2798DC1C504163066A54C2353D41B9B586F2D91C5041
1764459	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38179,38421	\N	PL149391	\N	\N	\N	N	\N	0102000020690F000007000000DD81C08A4A423D41A62251022F1D5041EEDA1843AF423D410371A210731D50412FCB5DCB6C423D4160286306FC1D50411AFB18F3F4443D411869E5F00D1E5041C4ECEBD044453D4159EBC708F71D50415FC85F9459453D4142BC2007A91D5041C0702AFE1F463D419F717944911D5041
1764460	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38158,38185	\N	PL149384	\N	\N	\N	N	\N	0102000020690F000005000000833F82429F3D3D417743017D261950419E65D5D7A5373D410D45BD42011D5041AC1BA6A523373D414370D5FE341D50411B6BF63119363D41437CDABE481D504119E1D913DF333D415433B890F21D5041
1764461	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38179	\N	PL149392	\N	\N	\N	N	\N	0102000020690F00000500000053841116E1453D41E7DB9332F31C50414A03C54F70473D4100A98940F11C5041BA40CF5653483D41B70B09E2D21C504120F77DC4EE483D41F94E2CDF9C1C5041F828A913F7483D419CB1A4FE521C5041
1764462	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149395	\N	\N	\N	N	\N	0102000020690F0000040000000CACA30965323D41FF9AEBB2A31C50415B49EA3462353D419C20269BCB1C5041B06163E2F6363D41E4E99B540B1D5041EE59B6A20D373D41C1402B12351D5041
1764463	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185,38485	\N	PL149173	\N	\N	\N	N	\N	0102000020690F000003000000C47A7D9B042A3D419DAD207C101D50413F777A156D2B3D41BE1D1D01941C50410CACA30965323D41FF9AEBB2A31C5041
1764464	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38421,38179	\N	PL149393	\N	\N	\N	N	\N	0102000020690F0000030000009175BE9FB8493D41406F668E021D5041EFE283FE83473D415A0DC5F7E81C5041D3F7A0F7DE453D41B0687657F01C5041
1764465	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185,38421	\N	PL149412	\N	\N	\N	N	\N	0102000020690F000004000000D4AA1CCAF03D3D41E7459B3DC81A504140D61212EB393D4146C574B3A71B5041B94DF20D65373D41CF4AAFDD6B1B504126DFEF82E0313D4198FB7A1AFC1B5041
1764466	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185,38151	\N	PL149413	\N	\N	\N	N	\N	0102000020690F0000070000007B3D571BC2313D4167D254E92D1A50410B004DD484323D416663D37CA21A5041D4760BD409313D41E4B41C42E21A5041449825BCED313D410E6A8C19F81B50410991CBEFED343D410EE624D6AE1B5041DF7836BB19363D4195E38AF5961C5041BE9CE77EB9353D41452FA95FD81C5041
1764468	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38382	\N	PL149427	\N	\N	\N	N	\N	0102000020690F000003000000EB9B081734213D412BC31336A922504190D000CEA3223D41B0C939EB2123504150DDE1197F233D41E0FE431A48235041
1764469	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185,38516,38126	\N	PL149405	\N	\N	\N	N	\N	0102000020690F000005000000D40E452F95363D413270144D3C1E5041F3A00B3925373D41DF82905D221E5041605BFED3633B3D413622E208551F504148652C2F513C3D41D4734507831F50413D48C6BD1A3D3D417684B8DE851F5041
1764470	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185,38158	\N	PL149372	\N	\N	\N	N	\N	0102000020690F000006000000E8B5D110762E3D41047E0242401B50419797BBD6EC323D41E6CD8FA1931A50410A6FCEC811353D41797712DB601A5041DF813C1ACD383D41E2FCC8FB651A5041AB01092ACC393D411A2C4AB3731A504136BB74C32F3B3D413F5D5267A91A5041
1764472	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149414	\N	\N	\N	N	\N	0102000020690F000004000000740946E594363D41B53465115C1A50415E9FF8015B363D414F0210994C1B5041FE39543068373D418FB0A6AD6F1B50414F47BF5D01373D417F82C779071D5041
1764473	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149415	\N	\N	\N	N	\N	0102000020690F000002000000D8B0D8DA52363D41C438D0DBA01C50412B8EC2B57A363D416553EAACD51C5041
1764474	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149385	\N	\N	\N	N	\N	0102000020690F00000300000096283AD214343D41D1E4D7C95D1C504110A3DFFE0F333D41EE724DABD81C504121148CA23F323D417CA4C4467B1D5041
1764478	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38158,38185,38151	\N	PL149382	\N	\N	\N	N	\N	0102000020690F000004000000D07C3C5EE5333D41FD16A3AB751A50417144B6634C333D41BA5FEC1F581950415DA531553B373D41D1413EF2F51850416832A2B4443A3D4160FBB06050195041
1764479	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38317	\N	PL149368	\N	\N	\N	N	\N	0102000020690F000002000000084136FB4C2E3D4118B2881E9417504110345E5A6E2B3D41C1B5FA64B4175041
1764476	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38423,38185,38516	\N	PL149388	\N	\N	\N	N	\N	0102000020690F00000B0000009CCBCC1CF1383D418A498202681F504113AC698E93373D41E6944ADA061F50416C7F263205373D41A1F7C953801E50418002E79C14363D418B8D7CF03C1E5041DC3C3BF184343D417AB9D4E9141E504153E1C7982E333D41FFF50D860D1E5041C340CFE633323D413354C8073A1E5041B457178704323D4166B282A9D81E5041FB5A8F9283303D4193202603451F5041F0E9E246432C3D41568E5A9BCB1F50419638234A66283D411959FCC80A205041
1764477	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38421,38185	\N	PL149390	\N	\N	\N	N	\N	0102000020690F000007000000BB0C3EFE13373D41A509DE148A1E5041D56D81A889373D413FAC21117D1E504135A7DEBAFA383D41CDFA3E2BE01D5041323ADF3FC0393D411EA680E6DE1D5041F5C086E74B3A3D4125DA91149E1D50417E4F6B6ABF3D3D41859D65B07B1D5041B3B6AF8336453D41992026A3FD1C5041
1764480	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185,38516,38229	\N	PL149398	\N	\N	\N	N	\N	0102000020690F000004000000EE59B6A20D373D41C1402B12351D50415C05F066063A3D41ADAC702DA91D50412A06CE890E443D4147E99C8944205041B6E136DA85453D417DBF62EF77205041
1764481	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38151,38185,38317	\N	PL149172	\N	\N	\N	N	\N	0102000020690F0000020000001693F676732D3D4114A989C07B165041A5A53BBF72333D41492DADF4EB1D5041
1764482	C06_P18_002_03	Orientation d'Aménagement et de Programmation : Qualité de l'air	\N	18	\N	https://sitdl.lametro.fr/urba_posplu/PLUI_GAM/4_1_OAP_thematiques/08_OAP_Air.pdf	2019-12-20	05	18-05-air	38185	\N	PL149386	\N	\N	\N	N	\N	0102000020690F00000300000002A1927AE62F3D41E9A1FCCFFF1D5041FE411CCBE0313D413D4D694F7E1D5041D9199E6E69353D413F78F0557C1D5041
\.


--
-- Name: gest_bdd_contact_referents gest_bdd_contact_referents_pkey; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_contact_referents
    ADD CONSTRAINT gest_bdd_contact_referents_pkey PRIMARY KEY (id);


--
-- Name: gest_bdd_objets gest_bdd_objets_pkey; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_objets
    ADD CONSTRAINT gest_bdd_objets_pkey PRIMARY KEY (id);


--
-- Name: gest_bdd_objets gest_bdd_objets_unique; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_objets
    ADD CONSTRAINT gest_bdd_objets_unique UNIQUE (nom_objet, type_objet, schema_id);


--
-- Name: gest_bdd_rel_thematique_contact_referents gest_bdd_rel_objets_thematique_contact_referents_pkey; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_rel_thematique_contact_referents
    ADD CONSTRAINT gest_bdd_rel_objets_thematique_contact_referents_pkey PRIMARY KEY (id);


--
-- Name: gest_bdd_rel_objets_thematique gest_bdd_rel_objets_thematique_pkey; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_rel_objets_thematique
    ADD CONSTRAINT gest_bdd_rel_objets_thematique_pkey PRIMARY KEY (id);


--
-- Name: gest_bdd_rel_objets_thematique gest_bdd_rel_objets_thematique_un; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_rel_objets_thematique
    ADD CONSTRAINT gest_bdd_rel_objets_thematique_un UNIQUE (objet_id, thematique_id);


--
-- Name: gest_bdd_rel_thematique_contact_referents gest_bdd_rel_thematique_contact_referents_un; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_rel_thematique_contact_referents
    ADD CONSTRAINT gest_bdd_rel_thematique_contact_referents_un UNIQUE (thematique_id, contact_referent_id);


--
-- Name: gest_bdd_schemas gest_bdd_schemas_pkey; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_schemas
    ADD CONSTRAINT gest_bdd_schemas_pkey PRIMARY KEY (id);


--
-- Name: gest_bdd_schemas gest_bdd_schemas_unique; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_schemas
    ADD CONSTRAINT gest_bdd_schemas_unique UNIQUE (nom_schema);


--
-- Name: gest_bdd_thematique gest_bdd_thematique_pkey; Type: CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_thematique
    ADD CONSTRAINT gest_bdd_thematique_pkey PRIMARY KEY (id);


--
-- Name: plan_2_c2_inf_99_decheterie_surf plan_2_c2_inf_99_decheterie_surf_pk; Type: CONSTRAINT; Schema: urba_plui_public; Owner: -
--

ALTER TABLE ONLY urba_plui_public.plan_2_c2_inf_99_decheterie_surf
    ADD CONSTRAINT plan_2_c2_inf_99_decheterie_surf_pk PRIMARY KEY (idinformation);


--
-- Name: plan_b3_psc_02_captage_pct plan_b3_psc_02_captage_pct_pk; Type: CONSTRAINT; Schema: urba_plui_public; Owner: -
--

ALTER TABLE ONLY urba_plui_public.plan_b3_psc_02_captage_pct
    ADD CONSTRAINT plan_b3_psc_02_captage_pct_pk PRIMARY KEY (idprescription);


--
-- Name: plan_b3_psc_18_oap_air_lin plan_b3_psc_18_oap_air_lin_pk; Type: CONSTRAINT; Schema: urba_plui_public; Owner: -
--

ALTER TABLE ONLY urba_plui_public.plan_b3_psc_18_oap_air_lin
    ADD CONSTRAINT plan_b3_psc_18_oap_air_lin_pk PRIMARY KEY (idprescription);


--
-- Name: sidx_plan_2_c2_inf_99_decheterie_surf_geom; Type: INDEX; Schema: urba_plui_public; Owner: -
--

CREATE INDEX sidx_plan_2_c2_inf_99_decheterie_surf_geom ON urba_plui_public.plan_2_c2_inf_99_decheterie_surf USING gist (geom);


--
-- Name: sidx_plan_b3_psc_02_captage_pct_geom; Type: INDEX; Schema: urba_plui_public; Owner: -
--

CREATE INDEX sidx_plan_b3_psc_02_captage_pct_geom ON urba_plui_public.plan_b3_psc_02_captage_pct USING gist (geom);


--
-- Name: sidx_plan_b3_psc_18_oap_air_lin_geom; Type: INDEX; Schema: urba_plui_public; Owner: -
--

CREATE INDEX sidx_plan_b3_psc_18_oap_air_lin_geom ON urba_plui_public.plan_b3_psc_18_oap_air_lin USING gist (geom);


--
-- Name: gest_bdd_objets gest_bdd_objets_schema_id_fkey; Type: FK CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_objets
    ADD CONSTRAINT gest_bdd_objets_schema_id_fkey FOREIGN KEY (schema_id) REFERENCES sit_hydre.gest_bdd_schemas(id) ON DELETE CASCADE;


--
-- Name: gest_bdd_rel_objets_thematique gest_bdd_rel_objets_thematique_objet_id_fkey; Type: FK CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_rel_objets_thematique
    ADD CONSTRAINT gest_bdd_rel_objets_thematique_objet_id_fkey FOREIGN KEY (objet_id) REFERENCES sit_hydre.gest_bdd_objets(id);


--
-- Name: gest_bdd_rel_objets_thematique gest_bdd_rel_objets_thematique_thematique_id_fkey; Type: FK CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_rel_objets_thematique
    ADD CONSTRAINT gest_bdd_rel_objets_thematique_thematique_id_fkey FOREIGN KEY (thematique_id) REFERENCES sit_hydre.gest_bdd_thematique(id);


--
-- Name: gest_bdd_rel_thematique_contact_referents gest_bdd_rel_thematique_contact_refere_contact_referent_id_fkey; Type: FK CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_rel_thematique_contact_referents
    ADD CONSTRAINT gest_bdd_rel_thematique_contact_refere_contact_referent_id_fkey FOREIGN KEY (contact_referent_id) REFERENCES sit_hydre.gest_bdd_contact_referents(id);


--
-- Name: gest_bdd_rel_thematique_contact_referents gest_bdd_rel_thematique_contact_referents_thematique_id_fkey; Type: FK CONSTRAINT; Schema: sit_hydre; Owner: -
--

ALTER TABLE ONLY sit_hydre.gest_bdd_rel_thematique_contact_referents
    ADD CONSTRAINT gest_bdd_rel_thematique_contact_referents_thematique_id_fkey FOREIGN KEY (thematique_id) REFERENCES sit_hydre.gest_bdd_thematique(id);


--
-- PostgreSQL database dump complete
--
