-- ===========================================================================
-- DDL - DATA WAREHOUSE (Camada Gold)
-- ===========================================================================
-- Disciplina: Sistemas de Banco de Dados 2
-- Semestre: 2025/4 - Curso de Verão
-- Professor: Thiago Luiz de Souza Gomes
-- Grupo 15
--    Caio Ferreira Duarte (231026901)
--    Laryssa Felix Ribeiro Lopes (231026840)
--    Luísa de Souza Ferreira (232014807)
--    Henrique Fontenelle Galvão Passos (231030771)
--    Marjorie Mitzi Cavalcante Rodrigues (231039140)
-- ============================================================================

-- Criação do schema DW (Data Warehouse)

CREATE SCHEMA IF NOT EXISTS dw;

COMMENT ON SCHEMA dw IS 'Data Warehouse - Star Schema (Camada Gold)';

-- ===========================================================================
-- LIMPA AS TABELAS (caso já existam)
-- ===========================================================================

DROP TABLE IF EXISTS dw.fat_acc CASCADE;
DROP TABLE IF EXISTS dw.dim_tim CASCADE;
DROP TABLE IF EXISTS dw.dim_sev CASCADE;
DROP TABLE IF EXISTS dw.dim_arc CASCADE;
DROP TABLE IF EXISTS dw.dim_geo CASCADE;
DROP TABLE IF EXISTS dw.dim_flt_phs CASCADE;
DROP TABLE IF EXISTS dw.dim_opt CASCADE;
DROP TABLE IF EXISTS dw.dim_wth CASCADE;

-- ============================================================================
-- DIMENSÃO: dim_tim
-- Descrição: Dimensão Temporal - Armazena datas dos eventos e publicações
-- ============================================================================
CREATE TABLE dw.dim_tim (
    srk_tim SERIAL PRIMARY KEY,
    evt_dat DATE NOT NULL,
    pub_dat DATE,
    UNIQUE(evt_dat, pub_dat)
);

COMMENT ON TABLE dw.dim_tim IS 'Dimensão Temporal';
COMMENT ON COLUMN dw.dim_tim.srk_tim IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_tim.evt_dat IS 'Data do evento';
COMMENT ON COLUMN dw.dim_tim.pub_dat IS 'Data de publicação do relatório';

-- ============================================================================
-- DIMENSÃO: dim_sev
-- Descrição: Dimensão de Severidade - Armazena classificações de gravidade
-- ============================================================================
CREATE TABLE dw.dim_sev (
    srk_sev SERIAL PRIMARY KEY,
    inj_sev VARCHAR(50),
    inv_typ VARCHAR(50),
    rpt_sta VARCHAR(50),
    UNIQUE(inj_sev, inv_typ, rpt_sta)
);

COMMENT ON TABLE dw.dim_sev IS 'Dimensão de Severidade do Acidente';
COMMENT ON COLUMN dw.dim_sev.srk_sev IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_sev.inj_sev IS 'Severidade das lesões (Fatal, Non-Fatal)';
COMMENT ON COLUMN dw.dim_sev.inv_typ IS 'Tipo de investigação (Accident, Incident)';
COMMENT ON COLUMN dw.dim_sev.rpt_sta IS 'Status do relatório (Probable Cause, etc)';

-- ============================================================================
-- DIMENSÃO: dim_arc
-- Descrição: Dimensão de Aeronave - Armazena características das aeronaves
-- ============================================================================
CREATE TABLE dw.dim_arc (
    srk_arc SERIAL PRIMARY KEY,
    arc_cat VARCHAR(50),
    mak VARCHAR(100),
    mod VARCHAR(100),
    reg_num VARCHAR(50),
    eng_typ VARCHAR(50),
    num_off_eng INTEGER,
    ama_blt BOOLEAN,
    arc_dam VARCHAR(50),
    UNIQUE(arc_cat, mak, mod, reg_num, eng_typ, num_off_eng, ama_blt, arc_dam)
);

COMMENT ON TABLE dw.dim_arc IS 'Dimensão de Aeronave';
COMMENT ON COLUMN dw.dim_arc.srk_arc IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_arc.arc_cat IS 'Categoria da aeronave (aircraft_category)';
COMMENT ON COLUMN dw.dim_arc.mak IS 'Fabricante (make)';
COMMENT ON COLUMN dw.dim_arc.mod IS 'Modelo (model)';
COMMENT ON COLUMN dw.dim_arc.reg_num IS 'Número de registro (registration_number)';
COMMENT ON COLUMN dw.dim_arc.eng_typ IS 'Tipo de motor (engine_type)';
COMMENT ON COLUMN dw.dim_arc.num_off_eng IS 'Número de motores (number_of_engines)';
COMMENT ON COLUMN dw.dim_arc.ama_blt IS 'Construção amadora (amateur_built)';
COMMENT ON COLUMN dw.dim_arc.arc_dam IS 'Dano à aeronave (aircraft_damage)';

-- ============================================================================
-- DIMENSÃO: dim_geo
-- Descrição: Dimensão Geográfica - Armazena localizações dos acidentes
-- ============================================================================
CREATE TABLE dw.dim_geo (
    srk_geo SERIAL PRIMARY KEY,
    ctr VARCHAR(100),
    lat DECIMAL(10,6),
    lon DECIMAL(10,6),
    apt_cod VARCHAR(20),
    apt_nam VARCHAR(200),
    loc TEXT,
    UNIQUE(ctr, lat, lon, apt_cod, apt_nam, loc)
);

COMMENT ON TABLE dw.dim_geo IS 'Dimensão Geográfica';
COMMENT ON COLUMN dw.dim_geo.srk_geo IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_geo.ctr IS 'País (country)';
COMMENT ON COLUMN dw.dim_geo.lat IS 'Latitude';
COMMENT ON COLUMN dw.dim_geo.lon IS 'Longitude';
COMMENT ON COLUMN dw.dim_geo.apt_cod IS 'Código do aeroporto (airport_code)';
COMMENT ON COLUMN dw.dim_geo.apt_nam IS 'Nome do aeroporto (airport_name)';
COMMENT ON COLUMN dw.dim_geo.loc IS 'Localização (location)';

-- ============================================================================
-- DIMENSÃO: dim_flt_phs
-- Descrição: Dimensão de Fase de Voo - Armazena a fase do voo no acidente
-- ============================================================================
CREATE TABLE dw.dim_flt_phs (
    srk_flt_phs SERIAL PRIMARY KEY,
    brd_phs_off_flt VARCHAR(100),
    UNIQUE(brd_phs_off_flt)
);

COMMENT ON TABLE dw.dim_flt_phs IS 'Dimensão de Fase de Voo';
COMMENT ON COLUMN dw.dim_flt_phs.srk_flt_phs IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_flt_phs.brd_phs_off_flt IS 'Fase ampla do voo (broad_phase_of_flight)';

-- ============================================================================
-- DIMENSÃO: dim_opt
-- Descrição: Dimensão de Operação - Armazena dados operacionais do voo
-- ============================================================================
CREATE TABLE dw.dim_opt (
    srk_opt SERIAL PRIMARY KEY,
    prp_off_flt VARCHAR(100),
    sch VARCHAR(50),
    air_car VARCHAR(200),
    far_dsc VARCHAR(200),
    UNIQUE(prp_off_flt, sch, air_car, far_dsc)
);

COMMENT ON TABLE dw.dim_opt IS 'Dimensão de Operação';
COMMENT ON COLUMN dw.dim_opt.srk_opt IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_opt.prp_off_flt IS 'Propósito do voo (purpose_of_flight)';
COMMENT ON COLUMN dw.dim_opt.sch IS 'Agendamento (schedule)';
COMMENT ON COLUMN dw.dim_opt.air_car IS 'Companhia aérea (air_carrier)';
COMMENT ON COLUMN dw.dim_opt.far_dsc IS 'Descrição FAR (far_description)';

-- ============================================================================
-- DIMENSÃO: dim_wth
-- Descrição: Dimensão de Clima - Armazena condições meteorológicas
-- ============================================================================
CREATE TABLE dw.dim_wth (
    srk_wth SERIAL PRIMARY KEY,
    wth_con VARCHAR(50),
    UNIQUE(wth_con)
);

COMMENT ON TABLE dw.dim_wth IS 'Dimensão de Condições Meteorológicas';
COMMENT ON COLUMN dw.dim_wth.srk_wth IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_wth.wth_con IS 'Condição climática (weather_condition)';

-- ============================================================================
-- TABELA FATO: fat_acc
-- Descrição: Tabela Fato - Armazena métricas de acidentes aéreos
-- ============================================================================
CREATE TABLE dw.fat_acc (
    srk_acc SERIAL PRIMARY KEY,
    
    -- Chaves Estrangeiras (Foreign Keys) - Ligação com as Dimensões
    srk_tim INTEGER NOT NULL,
    srk_sev INTEGER NOT NULL,
    srk_arc INTEGER NOT NULL,
    srk_geo INTEGER NOT NULL,
    srk_flt_phs INTEGER NOT NULL,
    srk_opt INTEGER NOT NULL,
    srk_wth INTEGER NOT NULL,
    
    -- Identificadores do Evento
    evt_ide VARCHAR(50) NOT NULL,
    acc_num VARCHAR(50),
    
    -- Métricas (Fatos/Medidas)
    tot_fat_inj INTEGER DEFAULT 0,
    tot_ser_inj INTEGER DEFAULT 0,
    tot_min_inj INTEGER DEFAULT 0,
    tot_uni INTEGER DEFAULT 0,
    
    -- Constraints de Chave Estrangeira
    CONSTRAINT fk_fat_tim FOREIGN KEY (srk_tim) 
        REFERENCES dw.dim_tim(srk_tim),
    CONSTRAINT fk_fat_sev FOREIGN KEY (srk_sev) 
        REFERENCES dw.dim_sev(srk_sev),
    CONSTRAINT fk_fat_arc FOREIGN KEY (srk_arc) 
        REFERENCES dw.dim_arc(srk_arc),
    CONSTRAINT fk_fat_geo FOREIGN KEY (srk_geo) 
        REFERENCES dw.dim_geo(srk_geo),
    CONSTRAINT fk_fat_flt_phs FOREIGN KEY (srk_flt_phs) 
        REFERENCES dw.dim_flt_phs(srk_flt_phs),
    CONSTRAINT fk_fat_opt FOREIGN KEY (srk_opt) 
        REFERENCES dw.dim_opt(srk_opt),
    CONSTRAINT fk_fat_wth FOREIGN KEY (srk_wth) 
        REFERENCES dw.dim_wth(srk_wth),
    
    -- Garante unicidade do evento
    UNIQUE(evt_ide)
);

COMMENT ON TABLE dw.fat_acc IS 'Tabela Fato - Acidentes Aéreos';
COMMENT ON COLUMN dw.fat_acc.srk_acc IS 'Surrogate Key (PK) da Tabela Fato';
COMMENT ON COLUMN dw.fat_acc.srk_tim IS 'FK - Dimensão Temporal';
COMMENT ON COLUMN dw.fat_acc.srk_sev IS 'FK - Dimensão de Severidade';
COMMENT ON COLUMN dw.fat_acc.srk_arc IS 'FK - Dimensão de Aeronave';
COMMENT ON COLUMN dw.fat_acc.srk_geo IS 'FK - Dimensão Geográfica';
COMMENT ON COLUMN dw.fat_acc.srk_flt_phs IS 'FK - Dimensão de Fase de Voo';
COMMENT ON COLUMN dw.fat_acc.srk_opt IS 'FK - Dimensão de Operação';
COMMENT ON COLUMN dw.fat_acc.srk_wth IS 'FK - Dimensão de Clima';
COMMENT ON COLUMN dw.fat_acc.evt_ide IS 'ID do evento (event_id)';
COMMENT ON COLUMN dw.fat_acc.acc_num IS 'Número do acidente (accident_number)';
COMMENT ON COLUMN dw.fat_acc.tot_fat_inj IS 'Total de lesões fatais (total_fatal_injuries)';
COMMENT ON COLUMN dw.fat_acc.tot_ser_inj IS 'Total de lesões sérias (total_serious_injuries)';
COMMENT ON COLUMN dw.fat_acc.tot_min_inj IS 'Total de lesões leves (total_minor_injuries)';
COMMENT ON COLUMN dw.fat_acc.tot_uni IS 'Total de ilesos (total_uninjured)';

-- ============================================================================
-- ÍNDICES PARA MELHOR PERFORMANCE
-- ============================================================================

-- Índices nas Foreign Keys da Tabela Fato
CREATE INDEX idx_fat_tim ON dw.fat_acc(srk_tim);
CREATE INDEX idx_fat_sev ON dw.fat_acc(srk_sev);
CREATE INDEX idx_fat_arc ON dw.fat_acc(srk_arc);
CREATE INDEX idx_fat_geo ON dw.fat_acc(srk_geo);
CREATE INDEX idx_fat_flt_phs ON dw.fat_acc(srk_flt_phs);
CREATE INDEX idx_fat_opt ON dw.fat_acc(srk_opt);
CREATE INDEX idx_fat_wth ON dw.fat_acc(srk_wth);

-- Índice no ID do evento (para buscas rápidas)
CREATE INDEX idx_fat_evt_ide ON dw.fat_acc(evt_ide);

-- Índices nas métricas (para agregações)
CREATE INDEX idx_fat_tot_fat_inj ON dw.fat_acc(tot_fat_inj) WHERE tot_fat_inj > 0;

-- ============================================================================
-- FIM DO DDL
-- ============================================================================