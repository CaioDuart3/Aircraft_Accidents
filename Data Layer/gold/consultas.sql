-- ============================================================================
-- 1) MAPA MUNDI GLOBAL (VIA NOME DA LOCALIDADE)
-- Descrição: retorna localidade (cidade, país), data, aeronave, severidade e evt_ide.
-- Filtra registros com local e país não nulos/ vazios usando uma CTE de geo filtrada.
-- ============================================================================
WITH geo_filtrada AS (
    SELECT srk_geo, loc, ctr
    FROM dw.dim_geo
    WHERE loc IS NOT NULL AND loc <> ''
      AND ctr IS NOT NULL AND ctr <> ''
)
SELECT 
    f.evt_ide,
    CONCAT(g.loc, ', ', g.ctr) AS localizacao_mapa,
    g.loc AS cidade,
    g.ctr AS pais,
    t.evt_dat AS data_acidente,
    CONCAT(a.mak, ' ', a.mod) AS aeronave,
    s.inj_sev AS severidade,
    f.tot_fat_inj AS total_fatais
FROM dw.fat_acc f
JOIN geo_filtrada g ON f.srk_geo = g.srk_geo
JOIN dw.dim_sev s ON f.srk_sev = s.srk_sev
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim 
JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
;

-- ============================================================================
-- 2) RELATÓRIO COM NÚMEROS GERAIS (EVENT-LEVEL)
-- Descrição: métrica por evento — vítimas, mortes e taxa de letalidade por evt_ide.
-- Uso de CTE para calcular métricas por evento (facilita reuso).
-- ============================================================================
WITH evento_metrics AS (
    SELECT
        f.evt_ide,
        (f.tot_fat_inj + f.tot_ser_inj + f.tot_min_inj + f.tot_uni) AS total_vitimas,
        f.tot_fat_inj AS total_mortes,
        CASE
            WHEN (f.tot_fat_inj + f.tot_ser_inj + f.tot_min_inj + f.tot_uni) = 0 THEN NULL
            ELSE ROUND(
                CAST(f.tot_fat_inj AS DECIMAL) /
                NULLIF(f.tot_fat_inj + f.tot_ser_inj + f.tot_min_inj + f.tot_uni, 0) * 100,
                2
            )
        END AS taxa_letalidade_geral
    FROM dw.fat_acc f
)
SELECT
    evt_ide,
    1 AS total_eventos,
    total_vitimas,
    total_mortes,
    taxa_letalidade_geral
FROM evento_metrics
;

-- ============================================================================
-- 3) TENDÊNCIA TEMPORAL (DESDE 1982)
-- Descrição: lista eventos com ano (>=1982) — preparado para agregação por ano.
-- CTE captura eventos com data e filtra ano; saída é 1 linha por evento.
-- ============================================================================
WITH eventos_com_ano AS (
    SELECT
        f.evt_ide,
        t.evt_dat
    FROM dw.fat_acc f
    JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
    WHERE CAST(EXTRACT(YEAR FROM t.evt_dat) AS INTEGER) >= 1982
)
SELECT
    evt_ide,
    CAST(EXTRACT(YEAR FROM evt_dat) AS INTEGER) AS ano,
    1 AS qtd_acidentes,
    (SELECT tot_fat_inj FROM dw.fat_acc fa WHERE fa.evt_ide = eventos_com_ano.evt_ide) AS qtd_fatais
FROM eventos_com_ano
;

-- ============================================================================
-- 4) FASES DE VOO CRÍTICAS (RANKING)
-- Descrição: conta ocorrências por fase de voo, exclui UNKNOWN. Usa CTE para agregação.
-- ============================================================================
WITH fase_ranking AS (
    SELECT 
        p.brd_phs_off_flt AS fase,
        COUNT(f.evt_ide) AS ocorrencias,
        SUM(f.tot_fat_inj) AS total_fatais
    FROM dw.fat_acc f
    JOIN dw.dim_flt_phs p ON f.srk_flt_phs = p.srk_flt_phs
    WHERE p.brd_phs_off_flt IS NOT NULL 
      AND p.brd_phs_off_flt != 'UNKNOWN'
    GROUP BY p.brd_phs_off_flt
)
SELECT
    NULL::text AS evt_ide, -- mantém o mesmo shape (evt_ide não é aplicável na agregação por fase)
    fase,
    ocorrencias,
    total_fatais
FROM fase_ranking
ORDER BY ocorrencias DESC
LIMIT 10
;

-- ============================================================================
-- 5) RANKING DE FABRICANTES (TOP 10)
-- Descrição: identifica fabricantes com mais acidentes usando CTE e rank; retorna lista.
-- ============================================================================
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
    NULL::text AS evt_ide, -- agregação por fabricante (evt_ide não aplicável)
    fabricante, 
    qtd_acidentes
FROM ranking_fab
WHERE rank_pos <= 10
ORDER BY qtd_acidentes DESC
;

-- ============================================================================
-- 6) SAZONALIDADE MENSAL (AGREGAÇÃO)
-- Descrição: quantidade de eventos por mês (MM, nome do mês) — pronta para gráfico.
-- ============================================================================
WITH mensal AS (
    SELECT 
        f.evt_ide,
        TO_CHAR(t.evt_dat, 'MM') AS num_mes,
        TRIM(TO_CHAR(t.evt_dat, 'Month')) AS nome_mes
    FROM dw.fat_acc f
    JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
)
SELECT 
    num_mes,
    nome_mes,
    COUNT(evt_ide) AS total_eventos
FROM mensal
GROUP BY num_mes, nome_mes
ORDER BY num_mes
;

-- ============================================================================
-- 7) SAZONALIDADE MENSAL (VERSÃO SIMPLES POR EVENTO)
-- Descrição: formato event-level com mês — útil para joins downstream.
-- ============================================================================
SELECT 
    f.evt_ide,
    TO_CHAR(t.evt_dat, 'MM') AS num_mes,
    TRIM(TO_CHAR(t.evt_dat, 'Month')) AS nome_mes
FROM dw.fat_acc f
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
;

-- ============================================================================
-- 8) ANÁLISE "WEEKEND WARRIOR"
-- Descrição: compara dias da semana (nome e tipo) com número de mortes por evento.
-- Usa CTE para normalizar por dia e depois agrega para relatório final.
-- ============================================================================
WITH analise_semanal AS (
    SELECT 
        f.evt_ide,
        t.evt_dat,
        TRIM(TO_CHAR(t.evt_dat, 'Day')) AS nome_dia,
        CAST(TO_CHAR(t.evt_dat, 'D') AS INTEGER) AS num_dia,
        CASE 
            WHEN CAST(TO_CHAR(t.evt_dat, 'D') AS INTEGER) IN (1, 7) THEN 'Fim de Semana'
            ELSE 'Dia de Semana'
        END AS tipo_dia,
        f.tot_fat_inj AS total_mortes
    FROM dw.fat_acc f
    JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
)
SELECT 
    nome_dia,
    num_dia,
    tipo_dia,
    COUNT(evt_ide) AS qtd_acidentes,
    ROUND(AVG(total_mortes), 2) AS media_mortes_por_dia
FROM analise_semanal
GROUP BY nome_dia, num_dia, tipo_dia
ORDER BY num_dia
;

-- ============================================================================
-- 9) CONDIÇÃO METEOROLÓGICA (EVENT-LEVEL)
-- Descrição: determina condição do evento (IMC / VMC / UNKNOWN) por evento e ano.
-- Usa CTE de eventos-clima para padronizar a categoria antes do select final.
-- ============================================================================
WITH eventos_clima AS (
    SELECT
        f.evt_ide,
        t.evt_dat,
        CASE
            WHEN w.wth_con IN ('IMC','VMC','UNKNOWN') THEN w.wth_con
            ELSE 'UNKNOWN'
        END AS condicao_meteorologica
    FROM dw.fat_acc f
    JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
    JOIN dw.dim_wth w ON f.srk_wth = w.srk_wth
)
SELECT
    evt_ide,
    EXTRACT(YEAR FROM evt_dat) AS ano,
    condicao_meteorologica
FROM eventos_clima
;

-- ============================================================================
-- 10) RISCO POR CATEGORIA DE AERONAVE
-- Descrição: calcula taxa de letalidade por categoria (exclui UNKNOWN) — CTE para sumarização.
-- ============================================================================
WITH categoria_stats AS (
    SELECT 
        a.arc_cat AS categoria,
        f.evt_ide,
        f.tot_fat_inj,
        (f.tot_fat_inj + f.tot_ser_inj + f.tot_min_inj + f.tot_uni) AS total_vitimas
    FROM dw.fat_acc f
    JOIN dw.dim_arc a ON f.srk_arc = a.srk_arc
    WHERE a.arc_cat IS NOT NULL 
      AND a.arc_cat != 'UNKNOWN'
)
SELECT
    NULL::text AS evt_ide, -- agregação por categoria
    categoria,
    COUNT(evt_ide) AS total_acidentes,
    SUM(tot_fat_inj) AS total_mortos,
    ROUND(
        AVG(
            CASE WHEN total_vitimas = 0 THEN NULL
                 ELSE CAST(tot_fat_inj AS DECIMAL)/NULLIF(total_vitimas,0)*100
            END
        ), 2
    ) AS taxa_letalidade
FROM categoria_stats
GROUP BY categoria
HAVING COUNT(evt_ide) > 50
ORDER BY total_acidentes DESC
;

-- ============================================================================
-- 11) TOP 10 FINALIDADES (EVENT-LEVEL PARA OS TOP 10)
-- Descrição: filtra eventos para as 10 finalidades com mais acidentes; retorna evento, ano, dia e finalidade.
-- ============================================================================
WITH top_10_finalidades AS (
    SELECT
        o.prp_off_flt AS finalidade_voo,
        COUNT(f.evt_ide) AS qtd_acidentes
    FROM dw.fat_acc f
    JOIN dw.dim_opt o ON f.srk_opt = o.srk_opt
    WHERE o.prp_off_flt IS NOT NULL
      AND o.prp_off_flt <> 'UNKNOWN'
    GROUP BY o.prp_off_flt
    ORDER BY qtd_acidentes DESC
    LIMIT 10
)
SELECT
    f.evt_ide,
    EXTRACT(YEAR FROM t.evt_dat) AS ano,
    TRIM(TO_CHAR(t.evt_dat, 'Day')) AS dia_semana,
    o.prp_off_flt AS finalidade_voo
FROM dw.fat_acc f
JOIN dw.dim_tim t ON f.srk_tim = t.srk_tim
JOIN dw.dim_opt o ON f.srk_opt = o.srk_opt
JOIN top_10_finalidades tf
    ON o.prp_off_flt = tf.finalidade_voo
;
