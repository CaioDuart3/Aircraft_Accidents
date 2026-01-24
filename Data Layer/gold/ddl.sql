-- =======================================================================
-- DDL - DATA WAREHOUSE (Camada Gold)
-- =======================================================================

CREATE SCHEMA IF NOT EXISTS dw;

COMMENT ON SCHEMA dw IS 'Data Warehouse - Star Schema (Camada Gold)';

-- =======================================================================
-- DROP TABELAS (se já existirem)
-- =======================================================================

DROP TABLE IF EXISTS dw.fat_acc CASCADE;
DROP TABLE IF EXISTS dw.dim_tim CASCADE;
DROP TABLE IF EXISTS dw.dim_ggp CASCADE;
DROP TABLE IF EXISTS dw.dim_arc CASCADE;
DROP TABLE IF EXISTS dw.dim_opt CASCADE;
DROP TABLE IF EXISTS dw.dim_sev CASCADE;
DROP TABLE IF EXISTS dw.dim_wth CASCADE;

-- =======================================================================
-- DIMENSÕES
-- =======================================================================

-- DIMENSÃO: Temporal
CREATE TABLE dw.dim_tim (
    srk_tim SERIAL PRIMARY KEY,
    event_date DATE,
    publication_date DATE
);

COMMENT ON TABLE dw.dim_tim IS 'Dimensão Temporal';
COMMENT ON COLUMN dw.dim_tim.event_date IS 'Data do evento';
COMMENT ON COLUMN dw.dim_tim.publication_date IS 'Data de publicação';

-- DIMENSÃO: Geográfica
CREATE TABLE dw.dim_ggp (
    srk_ggp SERIAL PRIMARY KEY,
    location TEXT,
    country VARCHAR(100),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    airport_code VARCHAR(20),
    airport_name VARCHAR(200)
);

COMMENT ON TABLE dw.dim_ggp IS 'Dimensão Geográfica';
COMMENT ON COLUMN dw.dim_ggp.location IS 'Localização';
COMMENT ON COLUMN dw.dim_ggp.country IS 'País';
COMMENT ON COLUMN dw.dim_ggp.latitude IS 'Latitude';
COMMENT ON COLUMN dw.dim_ggp.longitude IS 'Longitude';
COMMENT ON COLUMN dw.dim_ggp.airport_code IS 'Código do aeroporto';
COMMENT ON COLUMN dw.dim_ggp.airport_name IS 'Nome do aeroporto';

-- DIMENSÃO: Aeronave
CREATE TABLE dw.dim_arc (
    srk_arc SERIAL PRIMARY KEY,
    aircraft_category VARCHAR(50),
    registration_number VARCHAR(50),
    make VARCHAR(100),
    model VARCHAR(100),
    amateur_built BOOLEAN,
    number_of_engines INTEGER,
    engine_type VARCHAR(50),
    aircraft_damage VARCHAR(50)
);

COMMENT ON TABLE dw.dim_arc IS 'Dimensão Aeronave';
COMMENT ON COLUMN dw.dim_arc.aircraft_category IS 'Categoria da aeronave';
COMMENT ON COLUMN dw.dim_arc.registration_number IS 'Número de registro';
COMMENT ON COLUMN dw.dim_arc.make IS 'Fabricante';
COMMENT ON COLUMN dw.dim_arc.model IS 'Modelo';
COMMENT ON COLUMN dw.dim_arc.amateur_built IS 'Construção amadora';
COMMENT ON COLUMN dw.dim_arc.number_of_engines IS 'Número de motores';
COMMENT ON COLUMN dw.dim_arc.engine_type IS 'Tipo de motor';
COMMENT ON COLUMN dw.dim_arc.aircraft_damage IS 'Dano à aeronave';

-- DIMENSÃO: Operação
CREATE TABLE dw.dim_opt (
    srk_opt SERIAL PRIMARY KEY,
    far_description VARCHAR(200),
    schedule VARCHAR(50),
    purpose_of_flight VARCHAR(100),
    air_carrier VARCHAR(200),
    broad_phase_of_flight VARCHAR(100),
    report_status VARCHAR(50)
);

COMMENT ON TABLE dw.dim_opt IS 'Dimensão Operação';
COMMENT ON COLUMN dw.dim_opt.far_description IS 'Descrição FAR';
COMMENT ON COLUMN dw.dim_opt.schedule IS 'Agendamento';
COMMENT ON COLUMN dw.dim_opt.purpose_of_flight IS 'Propósito do voo';
COMMENT ON COLUMN dw.dim_opt.air_carrier IS 'Companhia aérea';
COMMENT ON COLUMN dw.dim_opt.broad_phase_of_flight IS 'Fase do voo';
COMMENT ON COLUMN dw.dim_opt.report_status IS 'Status do relatório';

-- DIMENSÃO: Severidade
CREATE TABLE dw.dim_sev (
    srk_sev SERIAL PRIMARY KEY,
    injury_severity VARCHAR(50)
);

COMMENT ON TABLE dw.dim_sev IS 'Dimensão Severidade';
COMMENT ON COLUMN dw.dim_sev.injury_severity IS 'Severidade das lesões';

-- DIMENSÃO: Clima
CREATE TABLE dw.dim_wth (
    srk_wth SERIAL PRIMARY KEY,
    weather_condition VARCHAR(50)
);

COMMENT ON TABLE dw.dim_wth IS 'Dimensão Clima';
COMMENT ON COLUMN dw.dim_wth.weather_condition IS 'Condição climática';

-- =======================================================================
-- TABELA FATO
-- =======================================================================

CREATE TABLE dw.fat_acc (
    srk_fat_acc SERIAL PRIMARY KEY,

    srk_tim INTEGER,
    srk_ggp INTEGER,
    srk_arc INTEGER,
    srk_opt INTEGER,
    srk_sev INTEGER,
    srk_wth INTEGER,

    event_id VARCHAR(50) NOT NULL,
    accident_number VARCHAR(50),

    total_fatal_injuries INTEGER DEFAULT 0,
    total_serious_injuries INTEGER DEFAULT 0,
    total_minor_injuries INTEGER DEFAULT 0,
    total_uninjured INTEGER DEFAULT 0,

    CONSTRAINT fk_fat_time FOREIGN KEY (srk_tim) REFERENCES dw.dim_tim(srk_tim),
    CONSTRAINT fk_fat_geo FOREIGN KEY (srk_ggp) REFERENCES dw.dim_ggp(srk_ggp),
    CONSTRAINT fk_fat_aircraft FOREIGN KEY (srk_arc) REFERENCES dw.dim_arc(srk_arc),
    CONSTRAINT fk_fat_operation FOREIGN KEY (srk_opt) REFERENCES dw.dim_opt(srk_opt),
    CONSTRAINT fk_fat_sev FOREIGN KEY (srk_sev) REFERENCES dw.dim_sev(srk_sev),
    CONSTRAINT fk_fat_wth FOREIGN KEY (srk_wth) REFERENCES dw.dim_wth(srk_wth)
);

COMMENT ON TABLE dw.fat_acc IS 'Tabela fato de acidentes';
COMMENT ON COLUMN dw.fat_acc.event_id IS 'Identificador do evento';
COMMENT ON COLUMN dw.fat_acc.accident_number IS 'Número do acidente';
COMMENT ON COLUMN dw.fat_acc.total_fatal_injuries IS 'Total de fatalidades';
COMMENT ON COLUMN dw.fat_acc.total_serious_injuries IS 'Total de feridos graves';
COMMENT ON COLUMN dw.fat_acc.total_minor_injuries IS 'Total de feridos leves';
COMMENT ON COLUMN dw.fat_acc.total_uninjured IS 'Total de ilesos';

-- =======================================================================
-- ÍNDICES
-- =======================================================================

CREATE INDEX idx_fat_time ON dw.fat_acc(srk_tim);
CREATE INDEX idx_fat_geo ON dw.fat_acc(srk_ggp);
CREATE INDEX idx_fat_arc ON dw.fat_acc(srk_arc);
CREATE INDEX idx_fat_opt ON dw.fat_acc(srk_opt);
CREATE INDEX idx_fat_sev ON dw.fat_acc(srk_sev);
CREATE INDEX idx_fat_wth ON dw.fat_acc(srk_wth);

CREATE INDEX idx_fat_event_id ON dw.fat_acc(event_id);

CREATE INDEX idx_fat_fatal ON dw.fat_acc(total_fatal_injuries) WHERE total_fatal_injuries > 0;
