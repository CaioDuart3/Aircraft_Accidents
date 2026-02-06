-- ============================================================================
-- 1. MAPA MUNDI GLOBAL (VIA NOME DA LOCALIDADE)
-- ============================================================================
-- Objetivo: Criar uma coluna de localização
SELECT 
    t.evt_dat AS data_evento,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    CONCAT(g.loc, ', ', g.ctr) AS localizacao_mapa,
    g.loc AS cidade,
    CONCAT(a.mak, ' ', a.mod) AS aeronave,
    s.inj_sev AS severidade,
    f.tot_fat_inj AS total_fatais
FROM dw.fat_acc f
JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
JOIN dw.dim_sev s ON f.srk_sev = s.srk_sev
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim 
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
WHERE g.loc IS NOT NULL 
  AND g.ctr IS NOT NULL

  -- mapa

-- ============================================================================
-- 2.RELATÓRIO COM NÚMEROS GERAIS 
-- ============================================================================
-- Objetivo: Cartões com os números totais do relatório.
SELECT 
    t.evt_dat AS data_evento,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    COUNT(f.evt_ide) AS total_acidentes,
    SUM(f.tot_fat_inj) AS total_mortos,
    ROUND(
        AVG(
            CAST(f.tot_fat_inj AS DECIMAL) /
            NULLIF(
                f.tot_fat_inj + f.tot_ser_inj + f.tot_min_inj + f.tot_uni,
                0
            )
        ) * 100,
        2
    ) AS taxa_letalidade_media
FROM dw.fat_acc f
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
WHERE a.arc_cat IS NOT NULL
  AND a.arc_cat <> 'UNKNOWN'
GROUP BY 
    t.evt_dat,
    a.mak,
    a.arc_cat,
    g.ctr

-- dados gerais

-- ============================================================================
-- 3 SAZONALIDADE ANUAL
-- ============================================================================
-- Objetivo: identificar os anos com o maior número de acidentes.
SELECT 
    t.evt_dat AS data_evento,
    EXTRACT(YEAR FROM t.evt_dat)::INT AS ano,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    COUNT(f.evt_ide) AS qtd_acidentes,
    SUM(f.tot_fat_inj) AS qtd_fatais
FROM dw.fat_acc f
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
WHERE EXTRACT(YEAR FROM t.evt_dat) >= 1982
GROUP BY t.evt_dat, ano, a.mak, a.arc_cat, g.ctr
ORDER BY ano

--sazonalidade anual

-- ============================================================================
-- 4. FASES DE VOO CRÍTICAS (RANKING)
-- ============================================================================
-- Objetivo: identificar o momento mais perigoso.
SELECT 
    t.evt_dat AS data_evento,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    p.brd_phs_off_flt AS fase,
    COUNT(f.evt_ide) AS ocorrencias,
    SUM(f.tot_fat_inj) AS total_fatais
FROM dw.fat_acc f
JOIN dw.dim_flt_phs p ON f.srk_flt_phs = p.srk_flt_phs
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
WHERE p.brd_phs_off_flt IS NOT NULL
  AND p.brd_phs_off_flt <> 'UNKNOWN'
GROUP BY t.evt_dat, a.mak, a.arc_cat, g.ctr, p.brd_phs_off_flt

-- fases do voo

-- ============================================================================
-- 5. RANKING DE FABRICANTES (TOP 10)
-- ============================================================================
-- Objetivo: Listar os fabricantes com mais ocorrências.
SELECT 
    t.evt_dat AS data_evento,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    COUNT(f.evt_ide) AS qtd_acidentes
FROM dw.fat_acc f
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
WHERE a.mak IS NOT NULL
GROUP BY t.evt_dat, a.mak, a.arc_cat, g.ctr

-- ranking de fab

-- ============================================================================
-- 6. SAZONALIDADE MENSAL 
-- ============================================================================
-- Objetivo: Identificar se existem meses mais perigosos no ano.
SELECT 
    t.evt_dat AS data_evento,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    TO_CHAR(t.evt_dat, 'MM') AS num_mes,
    TRIM(TO_CHAR(t.evt_dat, 'Month')) AS nome_mes,
    COUNT(f.evt_ide) AS total_eventos
FROM dw.fat_acc f
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
GROUP BY t.evt_dat, a.mak, a.arc_cat, g.ctr, num_mes, nome_mes

-- sazonalidade mensal

-- ============================================================================
-- 7. MATRIZ DE RISCO (TOP 5 FINALIDADES x SEVERIDADE)
-- ============================================================================
-- Objetivo: Heatmap focado nas categorias principais para comparar risco real.
SELECT 
    t.evt_dat AS data_evento,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    o.prp_off_flt AS finalidade,
    CASE 
        WHEN s.inj_sev IN ('Fatal', 'Non-Fatal') THEN s.inj_sev
        ELSE 'Incident/Minor' 
    END AS severidade_agrupada,
    COUNT(f.evt_ide) AS quantidade
FROM dw.fat_acc f
JOIN dw.dim_opt o ON f.srk_opt = o.srk_opt
JOIN dw.dim_sev s ON f.srk_sev = s.srk_sev
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
WHERE o.prp_off_flt IN (
    'Personal',
    'Instructional',
    'Business',
    'Aerial Application',
    'Executive/corporate'
)
GROUP BY 
    t.evt_dat,
    a.mak,
    a.arc_cat,
    g.ctr,
    o.prp_off_flt,
    CASE 
        WHEN s.inj_sev IN ('Fatal', 'Non-Fatal') THEN s.inj_sev
        ELSE 'Incident/Minor' 
    END

-- matriz de risco 

-- ============================================================================
-- 8. CLASSIFICAÇÃO TEMPORAL DE ACIDENTES FATAIS E NÃO FATAIS 
-- ============================================================================
-- Objetivo: Classificar os acidentes aéreos ao longo dos anos em fatais e
-- não fatais
SELECT
    -- colunas de filtro (BI)
    t.evt_dat AS data_evento,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    -- eixo do gráfico
    EXTRACT(YEAR FROM t.evt_dat) AS ano,

    -- métricas
    SUM(CASE WHEN f.tot_fat_inj > 0 THEN 1 ELSE 0 END) AS qtd_fatal,
    SUM(CASE WHEN f.tot_fat_inj = 0 THEN 1 ELSE 0 END) AS qtd_nao_fatal
FROM dw.fat_acc f
JOIN dw.dim_tim t
    ON f.srk_tim = t.srk_tim
JOIN dw.dim_arc a
    ON f.srk_arc = a.srk_arc
JOIN dw.dim_geo g
    ON f.srk_geo = g.srk_geo
GROUP BY
    t.evt_dat,
    a.mak,
    a.arc_cat,
    g.ctr,
    EXTRACT(YEAR FROM t.evt_dat)
ORDER BY ano

-- fatalXnfatal

-- ============================================================================
-- 9.  DISTRIBUIÇÃO DOS ACIDENTES AÉREOS POR CONDIÇÃO METEOROLÓGICA 
-- ============================================================================
-- Objetivo: Analisar a distribuição dos acidentes aéreos de acordo com as
-- condições meteorológicas
SELECT 
    -- colunas de filtro (BI)
    t.evt_dat AS data_evento,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    -- dimensão principal do gráfico
    w.wth_con AS condicao_meteorologica,

    -- métrica
    COUNT(f.evt_ide) AS quantidade
FROM dw.fat_acc f
JOIN dw.dim_wth w
    ON f.srk_wth = w.srk_wth
JOIN dw.dim_tim t
    ON f.srk_tim = t.srk_tim
JOIN dw.dim_arc a
    ON f.srk_arc = a.srk_arc
JOIN dw.dim_geo g
    ON f.srk_geo = g.srk_geo
WHERE w.wth_con IN ('VMC', 'IMC', 'UNKNOWN')
GROUP BY
    t.evt_dat,
    a.mak,
    a.arc_cat,
    g.ctr,
    w.wth_con

-- metereological

-- ============================================================================
-- 10. RISCO POR CATEGORIA DE AERONAVE
-- ============================================================================
-- Objetivo: Comparar volume e letalidade entre diferentes categorias
SELECT 
    t.evt_dat AS data_evento,
    a.mak AS maker,
    a.arc_cat AS categoria_aeronave,
    g.ctr AS pais,

    COUNT(f.evt_ide) AS total_eventos,
    SUM(f.tot_fat_inj + f.tot_ser_inj + f.tot_min_inj + f.tot_uni) AS total_vitimas,
    SUM(f.tot_fat_inj) AS total_mortes
FROM dw.fat_acc f
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
JOIN dw.dim_geo g ON f.srk_geo = g.srk_geo
GROUP BY t.evt_dat, a.mak, a.arc_cat, g.ctr

-- aeronave