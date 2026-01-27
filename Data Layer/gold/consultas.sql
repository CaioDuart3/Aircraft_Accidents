-- ============================================================================
-- 1. MAPA GERAL DE ACIDENTES
-- ============================================================================
-- Objetivo: Listar cada acidente com suas coordenadas geográficas para adicionar no mapa.
SELECT 
    g.lat AS latitude,
    g.lon AS longitude,
    g.loc AS cidade,
    g.ctr AS pais,
    s.inj_sev AS severidade,
    f.tot_fat_inj AS total_fatais
FROM dw.fat_acc f
JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
JOIN dw.dim_sev s ON f.srk_sev = s.srk_sev
WHERE g.lat IS NOT NULL 
  AND g.lat != 0;

-- ============================================================================
-- 2.RELATÓRIO COM NÚMEROS GERAIS 
-- ============================================================================
-- Objetivo: Cartões com os números totais do relatório.
SELECT 
    COUNT(f.evt_ide) AS total_eventos,
    SUM(f.tot_fat_inj) AS total_mortes,
    SUM(f.tot_uni) AS total_ilesos,
    ROUND(AVG(CAST(f.tot_fat_inj AS DECIMAL) / NULLIF(f.tot_fat_inj + f.tot_ser_inj + f.tot_min_inj + f.tot_uni, 0)) * 100, 2) AS taxa_letalidade
FROM dw.fat_acc f;

-- ============================================================================
-- 3. TENDÊNCIA TEMPORAL (EVOLUÇÃO ANUAL)
-- ============================================================================
-- Objetivo: Gráfico de linha mostrando a evolução dos acidentes por ano.
SELECT 
    CAST(EXTRACT(YEAR FROM t.evt_dat) AS INTEGER) AS ano,
    COUNT(f.evt_ide) AS qtd_acidentes,
    SUM(f.tot_fat_inj) AS qtd_fatais
FROM dw.fat_acc f
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
GROUP BY CAST(EXTRACT(YEAR FROM t.evt_dat) AS INTEGER)
ORDER BY ano;

-- ============================================================================
-- 3.1 TENDÊNCIA TEMPORAL DADOS CONSISTENTES DESDE 1982
-- ============================================================================
-- Objetivo: Gráfico de linha mostrando a evolução a partir de 1982, início da série consistente.
SELECT 
    CAST(EXTRACT(YEAR FROM t.evt_dat) AS INTEGER) AS ano,
    COUNT(f.evt_ide) AS qtd_acidentes,
    SUM(f.tot_fat_inj) AS qtd_fatais
FROM dw.fat_acc f
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
WHERE CAST(EXTRACT(YEAR FROM t.evt_dat) AS INTEGER) >= 1982 
GROUP BY CAST(EXTRACT(YEAR FROM t.evt_dat) AS INTEGER)
ORDER BY ano;

-- ============================================================================
-- 4. FATOR CLIMÁTICO (VMC vs IMC)
-- ============================================================================
-- Objetivo: Gráfico de Rosca comparando voo visual vs instrumentos.
WITH weather_stats AS (
    SELECT 
        w.wth_con AS condicao,
        COUNT(f.evt_ide) AS total_eventos,
        SUM(f.tot_fat_inj) AS total_mortes
    FROM dw.fat_acc f
    JOIN dw.dim_wth w ON f.srk_wth = w.srk_wth
    WHERE w.wth_con IN ('VMC', 'IMC') 
    GROUP BY w.wth_con
)
SELECT 
    condicao,
    total_eventos,
    total_mortes,
    ROUND((CAST(total_mortes AS DECIMAL) / NULLIF(total_eventos, 0)) * 100, 2) AS pct_letalidade
FROM weather_stats;

-- ============================================================================
-- 5. FASES DE VOO CRÍTICAS (RANKING) - [CTE]
-- ============================================================================
-- Objetivo: identificar o momento mais perigoso.
WITH fase_ranking AS (
    SELECT 
        p.brd_phs_off_flt AS fase,
        COUNT(f.evt_ide) AS ocorrencias,
        SUM(f.tot_fat_inj) AS total_fatais
    FROM dw.fat_acc f
    JOIN dw.dim_flt_phs p ON f.srk_flt_phs = p.srk_flt_phs
    WHERE p.brd_phs_off_flt IS NOT NULL 
      AND p.brd_phs_off_flt != 'UNKNOWN'   -- Precisa arrumar isso no etl, ainda tem muitos vazios
    GROUP BY p.brd_phs_off_flt
)
SELECT * FROM fase_ranking
ORDER BY ocorrencias DESC
LIMIT 10;

-- ============================================================================
-- 6. RANKING DE FABRICANTES (TOP 10)
-- ============================================================================
-- Objetivo: Listar os fabricantes com mais ocorrências.
WITH ranking_fab AS (
    SELECT 
        a.mak AS fabricante,
        COUNT(f.evt_ide) AS qtd_acidentes,
        DENSE_RANK() OVER (ORDER BY COUNT(f.evt_ide) DESC) AS rank_pos
    FROM dw.fat_acc f
    JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
    WHERE a.mak IS NOT NULL
    GROUP BY a.mak
)
SELECT 
    fabricante, 
    qtd_acidentes 
FROM ranking_fab
WHERE rank_pos <= 10;

-- ============================================================================
-- 7. SAZONALIDADE MENSAL 
-- ============================================================================
-- Objetivo: Identificar se existem meses mais perigosos no ano.
WITH mensal AS (
    SELECT 
        TO_CHAR(t.evt_dat, 'MM') AS num_mes,
        TO_CHAR(t.evt_dat, 'Month') AS nome_mes,
        COUNT(f.evt_ide) AS total_eventos
    FROM dw.fat_acc f
    JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
    GROUP BY TO_CHAR(t.evt_dat, 'MM'), TO_CHAR(t.evt_dat, 'Month')
)
SELECT 
    nome_mes,
    total_eventos
FROM mensal
ORDER BY num_mes;

-- ============================================================================
-- 8. MATRIZ DE RISCO (TOP 5 FINALIDADES x SEVERIDADE)
-- ============================================================================
-- Objetivo: Heatmap focado nas categorias principais para comparar risco real.
SELECT 
    o.prp_off_flt AS finalidade,
    CASE 
        WHEN s.inj_sev IN ('Fatal', 'Non-Fatal') THEN s.inj_sev
        ELSE 'Incident/Minor' 
    END AS severidade_agrupada,
    COUNT(f.evt_ide) AS quantidade
FROM dw.fat_acc f
JOIN dw.dim_opt o ON f.srk_opt = o.srk_opt
JOIN dw.dim_sev s ON f.srk_sev = s.srk_sev
WHERE o.prp_off_flt IN ('Personal', 'Instructional', 'Business', 'Aerial Application', 'Executive/corporate')
GROUP BY o.prp_off_flt, 
         CASE 
            WHEN s.inj_sev IN ('Fatal', 'Non-Fatal') THEN s.inj_sev
            ELSE 'Incident/Minor' 
         END
ORDER BY quantidade DESC;

-- ============================================================================
-- 9. PERFIL DE CONSTRUÇÃO (AMADOR VS PROFISSIONAL)
-- ============================================================================
-- Objetivo: Comparativo das aeronaves amadoras vs certificadas.
SELECT 
    CASE 
        WHEN a.ama_blt = 'Yes' OR a.ama_blt = 'true' THEN 'Amador/Experimental' 
        ELSE 'Certificado/Fabrica' 
    END AS tipo_construcao,
    COUNT(f.evt_ide) AS total_eventos
FROM dw.fat_acc f
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
GROUP BY a.ama_blt;

-- ============================================================================
-- 10. CORRELAÇÃO MOTORES E SOBREVIVÊNCIA
-- ============================================================================
-- Objetivo: Analisar se mais motores significam mais sobreviventes.
SELECT 
    a.num_off_eng AS qtd_motores,
    COUNT(f.evt_ide) AS acidentes,
    SUM(f.tot_uni) AS total_ilesos
FROM dw.fat_acc f
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
WHERE a.num_off_eng IS NOT NULL 
  AND a.num_off_eng <= 4
GROUP BY a.num_off_eng
ORDER BY a.num_off_eng;

-- ============================================================================
-- 11. ANÁLISE "WEEKEND WARRIOR" 
-- ============================================================================
-- Objetivo: Comparação do Dia Útil vs Fim de Semana.
WITH analise_semanal AS (
    SELECT 
        TO_CHAR(t.evt_dat, 'Day') AS nome_dia,
        CAST(TO_CHAR(t.evt_dat, 'D') AS INTEGER) AS num_dia,
        CASE 
            WHEN CAST(TO_CHAR(t.evt_dat, 'D') AS INTEGER) IN (1, 7) THEN 'Fim de Semana'
            ELSE 'Dia de Semana'
        END AS tipo_dia,
        COUNT(f.evt_ide) AS total_acidentes,
        SUM(f.tot_fat_inj) AS total_mortes
    FROM dw.fat_acc f
    JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
    GROUP BY t.evt_dat
)
SELECT 
    nome_dia,
    num_dia,
    tipo_dia,
    SUM(total_acidentes) as qtd_acidentes,
    ROUND(AVG(total_mortes), 2) as media_mortes_por_dia
FROM analise_semanal
GROUP BY nome_dia, num_dia, tipo_dia
ORDER BY num_dia;


-- ============================================================================
-- 12. TOP LOCALIDADES (RANKING)
-- ============================================================================
-- Objetivo: Identificar as cidades com maior concentração de acidentes nos EUA.
WITH geo_rank AS (
    SELECT 
        g.ctr AS pais,
        g.loc AS localidade,
        COUNT(f.evt_ide) AS total_acidentes,
        SUM(f.tot_fat_inj) AS total_mortos,
        RANK() OVER (ORDER BY COUNT(f.evt_ide) DESC) AS ranking
    FROM dw.fat_acc f
    JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
    WHERE g.ctr = 'United States' 
      AND g.loc IS NOT NULL
    GROUP BY g.ctr, g.loc
)
SELECT 
    localidade,
    total_acidentes,
    total_mortos
FROM geo_rank
WHERE ranking <= 10
ORDER BY total_acidentes DESC;

-- ============================================================================
-- 13. CONFIABILIDADE TECNOLÓGICA (TIPO DE MOTOR) 
-- ============================================================================
-- Objetivo: Comparar risco fatal entre tipos de motor 
WITH motor_stats AS (
    SELECT 
        a.eng_typ AS tipo_motor,
        COUNT(f.evt_ide) AS qtd_eventos,
        SUM(f.tot_fat_inj) AS qtd_fatais,
        SUM(f.tot_uni + f.tot_fat_inj + f.tot_ser_inj + f.tot_min_inj) AS total_pessoas
    FROM dw.fat_acc f
    JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
    WHERE a.eng_typ NOT IN ('UNKNOWN' ) -- Precisa arrumar isso no etl, ainda tem muitos vazios
    GROUP BY a.eng_typ
)
SELECT 
    tipo_motor,
    qtd_eventos,
    qtd_fatais,
    ROUND((CAST(qtd_fatais AS DECIMAL) / NULLIF(total_pessoas, 0)) * 100, 2) AS pct_risco_fatal
FROM motor_stats
WHERE qtd_eventos > 50 
ORDER BY pct_risco_fatal DESC;

-- ============================================================================
-- 14. DANO DA AERONAVE VS FATALIDADE
-- ============================================================================
-- Objetivo: Analisar correlação entre dano material (Destruído/Substancial) e mortes.
SELECT 
    a.arc_dam AS dano_aeronave,
    COUNT(f.evt_ide) AS total_acidentes,
    SUM(f.tot_fat_inj) AS total_mortos,
    SUM(f.tot_uni) AS total_ilesos
FROM dw.fat_acc f
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
WHERE a.arc_dam IS NOT NULL 
  AND a.arc_dam != 'UNKNOWN' -- Precisa arrumar isso no etl, ainda tem muitos vazios
GROUP BY a.arc_dam
ORDER BY total_acidentes DESC;

-- ============================================================================
-- 15. RISCO POR CATEGORIA DE AERONAVE
-- ============================================================================
-- Objetivo: Comparar volume e letalidade entre diferentes categorias
SELECT 
    a.arc_cat AS categoria,
    COUNT(f.evt_ide) AS total_acidentes,
    SUM(f.tot_fat_inj) AS total_mortos,
    -- Taxa de Letalidade média por categoria
    ROUND(AVG(CAST(f.tot_fat_inj AS DECIMAL) / NULLIF(f.tot_fat_inj + f.tot_ser_inj + f.tot_min_inj + f.tot_uni, 0)) * 100, 2) AS taxa_letalidade
FROM dw.fat_acc f
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
WHERE a.arc_cat IS NOT NULL 
  AND a.arc_cat != 'UNKNOWN' -- Precisa arrumar isso no etl, ainda tem muitos vazios
GROUP BY a.arc_cat
HAVING COUNT(f.evt_ide) > 50 -- Filtra categorias raras (ex: Foguetes, Balões) para limpar o gráfico
ORDER BY total_acidentes DESC;