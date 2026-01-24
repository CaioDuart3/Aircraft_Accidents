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

DROP TABLE IF EXISTS dw.fat_acident CASCADE;
DROP TABLE IF EXISTS dw.dim_time CASCADE;
DROP TABLE IF EXISTS dw.dim_severity CASCADE;
DROP TABLE IF EXISTS dw.dim_aircraft CASCADE;
DROP TABLE IF EXISTS dw.dim_geograph CASCADE;
DROP TABLE IF EXISTS dw.dim_flight_phase CASCADE;
DROP TABLE IF EXISTS dw.dim_operation CASCADE;
DROP TABLE IF EXISTS dw.dim_weather CASCADE;

-- ============================================================================
-- DIMENSÃO: dim_time
-- Descrição: Dimensão Temporal - Armazena datas dos eventos e publicações
-- ============================================================================
CREATE TABLE dw.dim_time (
    dim_time_srk SERIAL PRIMARY KEY,
    evt_dat DATE NOT NULL,
    pub_dat DATE,
    UNIQUE(evt_dat, pub_dat)
);

COMMENT ON TABLE dw.dim_time IS 'Dimensão Temporal';
COMMENT ON COLUMN dw.dim_time.dim_time_srk IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_time.evt_dat IS 'Data do evento';
COMMENT ON COLUMN dw.dim_time.pub_dat IS 'Data de publicação do relatório';

-- ============================================================================
-- DIMENSÃO: dim_severity
-- Descrição: Dimensão de Severidade - Armazena classificações de gravidade
-- ============================================================================
CREATE TABLE dw.dim_severity (
    dim_severity_srk SERIAL PRIMARY KEY,
    inj_sev VARCHAR(50),
    inv_typ VARCHAR(50),
    rpt_sta VARCHAR(50),
    UNIQUE(inj_sev, inv_typ, rpt_sta)
);

COMMENT ON TABLE dw.dim_severity IS 'Dimensão de Severidade do Acidente';
COMMENT ON COLUMN dw.dim_severity.dim_severity_srk IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_severity.inj_sev IS 'Severidade das lesões (Fatal, Non-Fatal)';
COMMENT ON COLUMN dw.dim_severity.inv_typ IS 'Tipo de investigação (Accident, Incident)';
COMMENT ON COLUMN dw.dim_severity.rpt_sta IS 'Status do relatório (Probable Cause, etc)';

-- ============================================================================
-- DIMENSÃO: dim_aircraft
-- Descrição: Dimensão de Aeronave - Armazena características das aeronaves
-- ============================================================================
CREATE TABLE dw.dim_aircraft (
    dim_aircraft_srk SERIAL PRIMARY KEY,
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

COMMENT ON TABLE dw.dim_aircraft IS 'Dimensão de Aeronave';
COMMENT ON COLUMN dw.dim_aircraft.dim_aircraft_srk IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_aircraft.arc_cat IS 'Categoria da aeronave (aircraft_category)';
COMMENT ON COLUMN dw.dim_aircraft.mak IS 'Fabricante (make)';
COMMENT ON COLUMN dw.dim_aircraft.mod IS 'Modelo (model)';
COMMENT ON COLUMN dw.dim_aircraft.reg_num IS 'Número de registro (registration_number)';
COMMENT ON COLUMN dw.dim_aircraft.eng_typ IS 'Tipo de motor (engine_type)';
COMMENT ON COLUMN dw.dim_aircraft.num_off_eng IS 'Número de motores (number_of_engines)';
COMMENT ON COLUMN dw.dim_aircraft.ama_blt IS 'Construção amadora (amateur_built)';
COMMENT ON COLUMN dw.dim_aircraft.arc_dam IS 'Dano à aeronave (aircraft_damage)';

-- ============================================================================
-- DIMENSÃO: dim_geograph
-- Descrição: Dimensão Geográfica - Armazena localizações dos acidentes
-- ============================================================================
CREATE TABLE dw.dim_geograph (
    dim_geograph_srk SERIAL PRIMARY KEY,
    ctr VARCHAR(100),
    lat DECIMAL(10,6),
    lon DECIMAL(10,6),
    apt_cod VARCHAR(20),
    apt_nam VARCHAR(200),
    loc TEXT,
    UNIQUE(ctr, lat, lon, apt_cod, apt_nam, loc)
);

COMMENT ON TABLE dw.dim_geograph IS 'Dimensão Geográfica';
COMMENT ON COLUMN dw.dim_geograph.dim_geograph_srk IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_geograph.ctr IS 'País (country)';
COMMENT ON COLUMN dw.dim_geograph.lat IS 'Latitude';
COMMENT ON COLUMN dw.dim_geograph.lon IS 'Longitude';
COMMENT ON COLUMN dw.dim_geograph.apt_cod IS 'Código do aeroporto (airport_code)';
COMMENT ON COLUMN dw.dim_geograph.apt_nam IS 'Nome do aeroporto (airport_name)';
COMMENT ON COLUMN dw.dim_geograph.loc IS 'Localização (location)';


-- ============================================================================
-- DIMENSÃO: dim_flight_phase
-- Descrição: Dimensão de Fase de Voo - Armazena a fase do voo no acidente
-- ============================================================================
CREATE TABLE dw.dim_flight_phase (
    dim_flight_phase_srk SERIAL PRIMARY KEY,
    brd_phs_off_flt VARCHAR(100),
    UNIQUE(brd_phs_off_flt)
);

COMMENT ON TABLE dw.dim_flight_phase IS 'Dimensão de Fase de Voo';
COMMENT ON COLUMN dw.dim_flight_phase.dim_flight_phase_srk IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_flight_phase.brd_phs_off_flt IS 'Fase ampla do voo (broad_phase_of_flight)';

-- ============================================================================
-- DIMENSÃO: dim_operation
-- Descrição: Dimensão de Operação - Armazena dados operacionais do voo
-- ============================================================================
CREATE TABLE dw.dim_operation (
    dim_operation_srk SERIAL PRIMARY KEY,
    prp_off_flt VARCHAR(100),
    sch VARCHAR(50),
    air_car VARCHAR(200),
    far_dsc VARCHAR(200),
    UNIQUE(prp_off_flt, sch, air_car, far_dsc)
);

COMMENT ON TABLE dw.dim_operation IS 'Dimensão de Operação';
COMMENT ON COLUMN dw.dim_operation.dim_operation_srk IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_operation.prp_off_flt IS 'Propósito do voo (purpose_of_flight)';
COMMENT ON COLUMN dw.dim_operation.sch IS 'Agendamento (schedule)';
COMMENT ON COLUMN dw.dim_operation.air_car IS 'Companhia aérea (air_carrier)';
COMMENT ON COLUMN dw.dim_operation.far_dsc IS 'Descrição FAR (far_description)';

-- ============================================================================
-- DIMENSÃO: dim_weather
-- Descrição: Dimensão de Clima - Armazena condições meteorológicas
-- ============================================================================
CREATE TABLE dw.dim_weather (
    dim_weather_srk SERIAL PRIMARY KEY,
    wth_con VARCHAR(50),
    UNIQUE(wth_con)
);

COMMENT ON TABLE dw.dim_weather IS 'Dimensão de Condições Meteorológicas';
COMMENT ON COLUMN dw.dim_weather.dim_weather_srk IS 'Surrogate Key (PK)';
COMMENT ON COLUMN dw.dim_weather.wth_con IS 'Condição climática (weather_condition)';

-- ============================================================================
-- TABELA FATO: fat_acident
-- Descrição: Tabela Fato - Armazena métricas de acidentes aéreos
-- ============================================================================
CREATE TABLE dw.fat_acident (
    fat_acident_srk SERIAL PRIMARY KEY,
    
    -- Chaves Estrangeiras (Foreign Keys) - Ligação com as Dimensões
    dim_time_srk INTEGER NOT NULL,
    dim_severity_srk INTEGER NOT NULL,
    dim_aircraft_srk INTEGER NOT NULL,
    dim_geograph_srk INTEGER NOT NULL,
    dim_flight_phase_srk INTEGER NOT NULL,
    dim_operation_srk INTEGER NOT NULL,
    dim_weather_srk INTEGER NOT NULL,
    
    -- Identificadores do Evento
    evt_ide VARCHAR(50) NOT NULL,
    acc_num VARCHAR(50),
    
    -- Métricas (Fatos/Medidas)
    tot_fat_inj INTEGER DEFAULT 0,
    tot_ser_inj INTEGER DEFAULT 0,
    tot_min_inj INTEGER DEFAULT 0,
    tot_uni INTEGER DEFAULT 0,
    
    -- Constraints de Chave Estrangeira
    CONSTRAINT fk_fat_time FOREIGN KEY (dim_time_srk) 
        REFERENCES dw.dim_time(dim_time_srk),
    CONSTRAINT fk_fat_severity FOREIGN KEY (dim_severity_srk) 
        REFERENCES dw.dim_severity(dim_severity_srk),
    CONSTRAINT fk_fat_aircraft FOREIGN KEY (dim_aircraft_srk) 
        REFERENCES dw.dim_aircraft(dim_aircraft_srk),
    CONSTRAINT fk_fat_geograph FOREIGN KEY (dim_geograph_srk) 
        REFERENCES dw.dim_geograph(dim_geograph_srk),
    CONSTRAINT fk_fat_flight_phase FOREIGN KEY (dim_flight_phase_srk) 
        REFERENCES dw.dim_flight_phase(dim_flight_phase_srk),
    CONSTRAINT fk_fat_operation FOREIGN KEY (dim_operation_srk) 
        REFERENCES dw.dim_operation(dim_operation_srk),
    CONSTRAINT fk_fat_weather FOREIGN KEY (dim_weather_srk) 
        REFERENCES dw.dim_weather(dim_weather_srk),
    
    -- Garante unicidade do evento
    UNIQUE(evt_ide)
);

COMMENT ON TABLE dw.fat_acident IS 'Tabela Fato - Acidentes Aéreos';
COMMENT ON COLUMN dw.fat_acident.fat_acident_srk IS 'Surrogate Key (PK) da Tabela Fato';
COMMENT ON COLUMN dw.fat_acident.dim_time_srk IS 'FK - Dimensão Temporal';
COMMENT ON COLUMN dw.fat_acident.dim_severity_srk IS 'FK - Dimensão de Severidade';
COMMENT ON COLUMN dw.fat_acident.dim_aircraft_srk IS 'FK - Dimensão de Aeronave';
COMMENT ON COLUMN dw.fat_acident.dim_geograph_srk IS 'FK - Dimensão Geográfica';
COMMENT ON COLUMN dw.fat_acident.dim_flight_phase_srk IS 'FK - Dimensão de Fase de Voo';
COMMENT ON COLUMN dw.fat_acident.dim_operation_srk IS 'FK - Dimensão de Operação';
COMMENT ON COLUMN dw.fat_acident.dim_weather_srk IS 'FK - Dimensão de Clima';
COMMENT ON COLUMN dw.fat_acident.evt_ide IS 'ID do evento (event_id)';
COMMENT ON COLUMN dw.fat_acident.acc_num IS 'Número do acidente (accident_number)';
COMMENT ON COLUMN dw.fat_acident.tot_fat_inj IS 'Total de lesões fatais (total_fatal_injuries)';
COMMENT ON COLUMN dw.fat_acident.tot_ser_inj IS 'Total de lesões sérias (total_serious_injuries)';
COMMENT ON COLUMN dw.fat_acident.tot_min_inj IS 'Total de lesões leves (total_minor_injuries)';
COMMENT ON COLUMN dw.fat_acident.tot_uni IS 'Total de ilesos (total_uninjured)';

-- ============================================================================
-- ÍNDICES PARA MELHOR PERFORMANCE
-- ============================================================================

-- Índices nas Foreign Keys da Tabela Fato
CREATE INDEX idx_fat_time ON dw.fat_acident(dim_time_srk);
CREATE INDEX idx_fat_severity ON dw.fat_acident(dim_severity_srk);
CREATE INDEX idx_fat_aircraft ON dw.fat_acident(dim_aircraft_srk);
CREATE INDEX idx_fat_geograph ON dw.fat_acident(dim_geograph_srk);
CREATE INDEX idx_fat_flight_phase ON dw.fat_acident(dim_flight_phase_srk);
CREATE INDEX idx_fat_operation ON dw.fat_acident(dim_operation_srk);
CREATE INDEX idx_fat_weather ON dw.fat_acident(dim_weather_srk);

-- Índice no ID do evento (para buscas rápidas)
CREATE INDEX idx_fat_evt_ide ON dw.fat_acident(evt_ide);

-- Índices nas métricas (para agregações)
CREATE INDEX idx_fat_tot_fat_inj ON dw.fat_acident(tot_fat_inj) WHERE tot_fat_inj > 0;

-- ============================================================================
-- FIM DO DDL
-- ============================================================================