-- ============================================================================
-- SILVER LAYER: TABELA AVIAO (ACIDENTES AÉREOS)
-- Camada Silver - Dados limpos e padronizados do NTSB
-- ============================================================================

-- Criação do schema silver (caso não exista)
CREATE SCHEMA IF NOT EXISTS silver;

-- Comentário no schema
COMMENT ON SCHEMA silver IS 'Camada Silver - Dados de Aviação limpos e validados';

-- ============================================================================
-- TABELA: AVIAO
-- ============================================================================
DROP TABLE IF EXISTS silver.aviao CASCADE;

CREATE TABLE silver.aviao (
    -- Identificação
    event_id VARCHAR(50) PRIMARY KEY,
    investigation_type VARCHAR(50),
    accident_number VARCHAR(50),

    -- Temporal
    event_date DATE,
    publication_date DATE,

    -- Localização
    location TEXT,
    country VARCHAR(100),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    airport_code VARCHAR(20),
    airport_name VARCHAR(200),

    -- Aeronave
    aircraft_category VARCHAR(50),
    registration_number VARCHAR(50),
    make VARCHAR(100),
    model VARCHAR(100),
    amateur_built BOOLEAN,
    number_of_engines INTEGER,
    engine_type VARCHAR(50),
    aircraft_damage VARCHAR(50),

    -- Operação e Regulação
    far_description VARCHAR(200),
    schedule VARCHAR(50),
    purpose_of_flight VARCHAR(100),
    air_carrier VARCHAR(200),
    broad_phase_of_flight VARCHAR(100),
    report_status VARCHAR(50),

    -- Vítimas (Métricas)
    total_fatal_injuries INTEGER DEFAULT 0,
    total_serious_injuries INTEGER DEFAULT 0,
    total_minor_injuries INTEGER DEFAULT 0,
    total_uninjured INTEGER DEFAULT 0,
    injury_severity VARCHAR(50),
    
    -- Condições
    weather_condition VARCHAR(50),

    -- Metadata de Controle
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================================================
-- Índices para filtros comuns em dashboards
CREATE INDEX idx_aviao_date ON silver.aviao(event_date);
CREATE INDEX idx_aviao_country ON silver.aviao(country);
CREATE INDEX idx_aviao_make ON silver.aviao(make);
CREATE INDEX idx_aviao_model ON silver.aviao(model);
CREATE INDEX idx_aviao_severity ON silver.aviao(injury_severity);

-- Índices parciais (Onde há fatalidades ou coordenadas)
CREATE INDEX idx_aviao_fatal ON silver.aviao(total_fatal_injuries) WHERE total_fatal_injuries > 0;
CREATE INDEX idx_aviao_geo ON silver.aviao(latitude, longitude) WHERE latitude IS NOT NULL;

-- ============================================================================
-- COMENTÁRIOS NAS COLUNAS (Dicionário de Dados no Banco)
-- ============================================================================
COMMENT ON TABLE silver.aviao IS 'Histórico de acidentes aéreos (NTSB) tratado e enriquecido';

-- Identificação
COMMENT ON COLUMN silver.aviao.event_id IS 'Identificador único do evento (NTSB)';
COMMENT ON COLUMN silver.aviao.investigation_type IS 'Tipo: Accident ou Incident';
COMMENT ON COLUMN silver.aviao.accident_number IS 'Número oficial do processo';

-- Aeronave
COMMENT ON COLUMN silver.aviao.make IS 'Fabricante da aeronave (ex: Boeing, Cessna)';
COMMENT ON COLUMN silver.aviao.model IS 'Modelo da aeronave';
COMMENT ON COLUMN silver.aviao.amateur_built IS 'Indicador se é aeronave experimental/amadora';
COMMENT ON COLUMN silver.aviao.aircraft_damage IS 'Nível de dano (Destroyed, Substantial, Minor)';

-- Métricas
COMMENT ON COLUMN silver.aviao.total_fatal_injuries IS 'Total de óbitos no evento';
COMMENT ON COLUMN silver.aviao.total_serious_injuries IS 'Total de feridos graves';
COMMENT ON COLUMN silver.aviao.weather_condition IS 'Condição climática (VMC/IMC)';
COMMENT ON COLUMN silver.aviao.broad_phase_of_flight IS 'Fase do voo (Pouso, Decolagem, Cruzeiro)';

-- ============================================================================
-- VIEWS AUXILIARES (ANALYTICS READY)
-- ============================================================================

-- View: Apenas Acidentes Fatais (Para KPIs de Segurança)
CREATE OR REPLACE VIEW silver.vw_fatal_accidents AS
SELECT 
    event_id,
    event_date,
    make,
    model,
    country,
    total_fatal_injuries,
    broad_phase_of_flight,
    weather_condition
FROM silver.aviao
WHERE total_fatal_injuries > 0
ORDER BY total_fatal_injuries DESC;

-- View: Resumo por Fabricante (Top Makers)
CREATE OR REPLACE VIEW silver.vw_maker_stats AS
SELECT 
    make,
    COUNT(*) as total_events,
    SUM(total_fatal_injuries) as total_deaths,
    SUM(CASE WHEN aircraft_damage = 'Destroyed' THEN 1 ELSE 0 END) as total_destroyed
FROM silver.aviao
WHERE make IS NOT NULL AND make != 'Unknown'
GROUP BY make
ORDER BY total_events DESC;

-- ============================================================================
-- FIM DO DDL
-- ============================================================================