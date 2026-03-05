-- Base de datos
USE proyecto1;

-- PROYECTO ACTUARIAL
-- ETAPA 1: TOTAL QUINQUENAL
-- ========================================================
-- 1.1 Medidas de cartera
-- ========================================================
-- 1.1.1. Emision total

SELECT COUNT(*) AS emision_total
FROM emision;

-- 1.1.2. Exposición total

SELECT SUM(uer_ind) AS UER
FROM(SELECT (DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
	FROM emision) t1;

-- 1.1.3. Exposicion total por cobertura

SELECT 	cobertura,
		UER/SUM(UER) OVER() AS pct_uer
FROM(SELECT cobertura,
			SUM(uer_ind) AS UER
	FROM(SELECT nombre_cobertura AS cobertura,
				(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
		FROM emision e
		JOIN poliza_cobertura pc
		ON e.id_poliza=pc.id_poliza
		JOIN coberturas c
		ON pc.id_cobertura=c.id_cobertura
		) t1
	GROUP BY cobertura
    ) t2;

-- 1.1.4. Polizas vigentes promedio

SELECT SUM(uer_ind)/COUNT(DISTINCT ejercicio) AS uer_promedio_anual
FROM(SELECT (DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind,
	ejercicio	
	FROM emision) t1;
    
-- 1.1.5. Suma asegurada

SELECT SUM(v.suma_asegurada) AS suma_asegurada
FROM emision e
JOIN vehiculos v
ON e.id_vehiculo=v.id_vehiculo;

-- 1.1.6. Composición de Productos

SELECT	producto,
		total/SUM(total) OVER() AS distribucion
FROM(SELECT 	producto,
				COUNT(*) AS total
	FROM emision e
	JOIN productos p
	ON e.id_producto=p.id_producto
	GROUP BY producto
    ) t1
ORDER BY distribucion DESC;

-- 1.1.7. Distribución de productos ponderados por emisión

SELECT	producto,
		prima/SUM(prima) OVER() AS distribucion
FROM(SELECT	producto,
	SUM(prima_emitida) as prima
	FROM emision e
	LEFT JOIN productos p
	ON e.id_producto=p.id_producto
	GROUP BY producto
    ) t1
ORDER BY distribucion DESC;

-- 1.1.8. Composición de coberturas
SELECT	cobertura,
		total/SUM(total) OVER()*100 AS distribucion
FROM(SELECT	cobertura,
			COUNT(cobertura) AS total
	FROM emision e
	JOIN(SELECT	pc.id_poliza,
				nombre_cobertura AS cobertura
	FROM poliza_cobertura pc
	JOIN coberturas c
	ON pc.id_cobertura=c.id_cobertura
		) t1
	ON e.id_poliza=t1.id_poliza
	GROUP BY cobertura
	) t2
ORDER BY distribucion DESC;

-- 1.1.9. Composición de coberturas ponderada por prima

SELECT	cobertura,
		prima_total/SUM(prima_total) OVER() AS distribucion
FROM(SELECT	nombre_cobertura AS cobertura,
			SUM(prima_emitida_cobertura) AS prima_total
	FROM poliza_cobertura pc
	LEFT JOIN coberturas c
	ON pc.id_cobertura=c.id_cobertura
	GROUP BY nombre_cobertura
    ) t1
ORDER BY distribucion DESC;

-- ========================================================
-- 1.2 Siniestros - Casos
-- ========================================================
-- 1.2.1. Cantidad de siniestros

SELECT COUNT(id_siniestro)
FROM siniestros;

-- 1.2.2. Siniestros por poliza

SELECT	e.id_poliza,
		COUNT(s.id_siniestro) AS total_siniestros
FROM emision e
LEFT JOIN siniestros s
ON e.id_poliza=s.id_poliza
GROUP BY e.id_poliza;

-- 1.2.3. Porcentaje de polizas siniestradas
SELECT SUM(control_siniestro)/COUNT(*)
FROM(SELECT	DISTINCT e.id_poliza,
					CASE
					WHEN id_siniestro IS NULL THEN 0
					ELSE 1
					END AS control_siniestro
	FROM emision e
	LEFT JOIN siniestros s
	ON e.id_poliza=s.id_poliza
	) t1;
    
-- ========================================================
-- 1.3 Siniestros - Montos
-- =========================================================
-- 1.3.1. Severidad Promedio

SELECT SUM(monto_siniestro)/COUNT(id_siniestro) AS siniestro_promedio
FROM siniestros;

-- 1.3.2. Severidad promedio por cobertura

SELECT 	nombre_cobertura AS cobertura,
		SUM(monto_siniestro)/COUNT(id_siniestro) AS siniestro_promedio
FROM siniestros s
JOIN coberturas c
ON s.id_cobertura=c.id_cobertura
GROUP BY nombre_cobertura;

-- 1.3.3. Varianza y Desviación estandar

SELECT	FORMAT(VARIANCE(monto_siniestro),2,"es_AR") AS varianza,
		FORMAT(SQRT(VARIANCE(monto_siniestro)),2,"es_AR") AS desvio_estandar
FROM siniestros;

    
-- 1.3.4. Coeficiente de Variación

SELECT	SQRT(VARIANCE(monto_siniestro))/AVG(monto_siniestro)*100 AS coeficiente_de_variacion
FROM siniestros;

-- 1.3.5. Severidad Mediana y Percentiles
SELECT 	FORMAT(MIN(CASE WHEN pct >= 0.25 THEN monto_siniestro END),2,"es_AR") AS "percentil_25",
		FORMAT(MIN(CASE WHEN pct >= 0.5 THEN monto_siniestro END),2,"es_AR") AS "mediana",
        FORMAT(MIN(CASE WHEN pct >= 0.75 THEN monto_siniestro END),2,"es_AR") AS "percentil_75",
        FORMAT(MIN(CASE WHEN pct >= 0.9 THEN monto_siniestro END),2,"es_AR") AS "percentil_90",
        FORMAT(MIN(CASE WHEN pct >= 0.95 THEN monto_siniestro END),2,"es_AR") AS "percentil_95",
        FORMAT(MIN(CASE WHEN pct = 1 THEN monto_siniestro END),2,"es_AR") AS "siniestro maximo"
FROM(SELECT monto_siniestro,
			CUME_DIST() OVER(ORDER BY monto_siniestro) AS pct
	FROM siniestros
    ) t1;

-- Considerando los logaritmos naturales

SELECT 	FORMAT(LN(MIN(CASE WHEN pct >= 0.25 THEN monto_siniestro END)),2,"es_AR") AS "percentil_25",
		FORMAT(LN(MIN(CASE WHEN pct >= 0.5 THEN monto_siniestro END)),2,"es_AR") AS "mediana",
        FORMAT(LN(MIN(CASE WHEN pct >= 0.75 THEN monto_siniestro END)),2,"es_AR") AS "percentil_75",
        FORMAT(LN(MIN(CASE WHEN pct >= 0.9 THEN monto_siniestro END)),2,"es_AR") AS "percentil_90",
        FORMAT(LN(MIN(CASE WHEN pct >= 0.95 THEN monto_siniestro END)),2,"es_AR") AS "percentil_95",
        FORMAT(LN(MIN(CASE WHEN pct = 1 THEN monto_siniestro END)),2,"es_AR") AS "siniestro maximo"
FROM(SELECT monto_siniestro,
			CUME_DIST() OVER(ORDER BY monto_siniestro) AS pct
	FROM siniestros
    ) t1;

-- ========================================================
-- 1.4 Pricing
-- =========================================================
-- 1.4.1. Frecuencia

SELECT	SUM(n_sin)/SUM(uer_ind) AS frecuencia
FROM(SELECT	e.id_poliza,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind,
			COUNT(id_siniestro) AS n_sin
	FROM emision e
	LEFT JOIN siniestros s
	ON e.id_poliza=s.id_poliza
    GROUP BY e.id_poliza
	) t1; 
    
-- 1.4.2. Frecuencia por cobertura

SELECT t2.cobertura,
		t3.casos / t2.uer AS frecuencia
FROM(SELECT	t1.cobertura,
			t1.id_cobertura,
			SUM(t1.uer_ind) AS uer
    FROM(SELECT	e.id_poliza,
				(DATEDIFF(e.fecha_fin, e.fecha_inicio) + 1) / 365 AS uer_ind,
				pc.id_cobertura,
				c.nombre_cobertura AS cobertura
        FROM emision e
        JOIN poliza_cobertura pc
		ON e.id_poliza = pc.id_poliza
        JOIN coberturas c
		ON pc.id_cobertura = c.id_cobertura
    ) t1
    GROUP BY t1.cobertura, t1.id_cobertura
) t2
LEFT JOIN (SELECT id_cobertura,
					COUNT(*) AS casos
			FROM siniestros
			GROUP BY id_cobertura
) t3
ON t2.id_cobertura = t3.id_cobertura;
    
-- 1.4.3. Prima Pura

SELECT	FORMAT(SUM(sin_total_poliza)/SUM(uer_ind),2,"es_AR") AS prima_pura
FROM(SELECT	id_poliza,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind,
			SUM(monto_siniestro) AS sin_total_poliza
	FROM(SELECT	e.id_poliza,
				e.fecha_inicio,
				e.fecha_fin,
				monto_siniestro
		FROM emision e
		LEFT JOIN siniestros s
		ON e.id_poliza=s.id_poliza
		) t1
	GROUP BY id_poliza
	) t2;
    
-- 1.4.4. Prima Pura por cobertura
SELECT	cobertura,
		monto_tot_cob/uer_tot_cob AS prima_pura_cob
FROM(SELECT	id_cobertura,
			cobertura,
			SUM(uer_cob) AS uer_tot_cob
	FROM(SELECT	e.id_poliza,
				id_cobertura,
				(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_cob,
				cobertura
		FROM emision e
		JOIN(SELECT	id_poliza,
					pc.id_cobertura,
					nombre_cobertura AS cobertura
			FROM poliza_cobertura pc
			JOIN coberturas c
			ON pc.id_cobertura=c.id_cobertura
			) t1
		ON e.id_poliza=t1.id_poliza
		) t2
	GROUP BY id_cobertura
    ) t3 
LEFT JOIN(SELECT	id_cobertura,
					SUM(monto_siniestro) AS monto_tot_cob
		FROM siniestros s
		GROUP BY id_cobertura
		) t4
ON t3.id_cobertura=t4.id_cobertura;

-- 1.4.5. Prima Pura por producto
SELECT	producto,
		prima_pura_producto
FROM(SELECT	t2.id_producto,
			monto_tot_prod/uer_tot_prod AS prima_pura_producto
	FROM(SELECT	id_producto,
				SUM(uer_prod) AS uer_tot_prod
		FROM(SELECT	id_poliza,
					id_producto,
					(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_prod
			FROM emision
			) t1
	GROUP BY id_producto
		) t2
	LEFT JOIN(SELECT	id_producto,
						SUM(monto_siniestro) monto_tot_prod
			FROM siniestros s
			LEFT JOIN emision e1
			ON s.id_poliza=e1.id_poliza
			GROUP BY id_producto
			) t3 
	ON t2.id_producto=t3.id_producto
	) t4
JOIN productos p
ON t4.id_producto=p.id_producto;

-- ========================================================
-- 1.5 Primas
-- =========================================================
-- 1.5.1. Prima  Emitida

SELECT SUM(prima_emitida) AS prima_emitida
FROM emision e;

-- 1.5.2. Prima Emitida por cobertura

SELECT 	nombre_cobertura AS cobertura,
		SUM(prima_emitida_cobertura) AS prima_emitida
FROM  poliza_cobertura pc
JOIN coberturas c
ON pc.id_cobertura=c.id_cobertura
GROUP BY nombre_cobertura;

-- 1.5.3. Prima Devengada

SELECT SUM(prima_emitida*vig_corrida/vig_dias) AS prima_devengada
FROM(SELECT	*,
			DATEDIFF(fecha_fin,fecha_inicio)+1	AS vig_dias,
			CASE
			WHEN fecha_fin <= STR_TO_DATE("2019-6-30","%Y-%m-%d") THEN DATEDIFF(fecha_fin,fecha_inicio)+1
			ELSE DATEDIFF(STR_TO_DATE("2019-6-30","%Y-%m-%d"),fecha_inicio)+1
			END AS vig_corrida
	FROM emision
    ) t1;
    
-- 1.5.4. Prima promedio

SELECT	AVG(prima_emitida) prima_promedio_poliza
FROM emision;

-- 1.5.4. Prima por unidad expuesta
SELECT	SUM(prima_emitida)/SUM(uer_ind) AS prima_UER
FROM(SELECT	prima_emitida,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
	FROM emision
    ) t1;

-- ========================================================
-- 1.6 Rentabilidad
-- =========================================================
-- 1.6.1. Siniestros Totales

SELECT SUM(monto_siniestro)	siniestros_totales
FROM siniestros;

-- 1.6.2. Loss Ratio

SELECT	SUM(sin_poliza)/SUM(prima_emitida)*100 AS loss_ratio
FROM(SELECT	prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT id_poliza,
				prima_emitida
		FROM emision e
		) t1
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
				GROUP BY id_poliza
			) t2
	ON t1.id_poliza=t2.id_poliza
    ) t4;
    
-- 1.6.3. Loss ratio por cobertura

SELECT	cobertura,
		SUM(sin_cobertura)/SUM(prima_emitida_cobertura)*100 AS loss_ratio
FROM(SELECT	cobertura,
			prima_emitida_cobertura,
			CASE
            WHEN monto_siniestros IS NULL THEN 0
            ELSE monto_siniestros
            END AS sin_cobertura
	FROM(SELECT id_poliza,
				pc.id_cobertura,
				nombre_cobertura AS cobertura,
				prima_emitida_cobertura
		FROM poliza_cobertura pc
        JOIN coberturas c
        ON pc.id_cobertura=c.id_cobertura
		) t1
	LEFT JOIN(SELECT	id_poliza,
				id_cobertura,
				SUM(monto_siniestro) AS monto_siniestros
		FROM siniestros s
		GROUP BY id_poliza, id_cobertura
			) t2
	ON t1.id_poliza=t2.id_poliza
    AND t1.id_cobertura=t2.id_cobertura
    ) t4
GROUP BY cobertura;
            
-- 1.6.4. Resultado técnico bruto

SELECT	SUM(prima_emitida)-SUM(sin_poliza) AS resultado_tecnico_bruto
FROM(SELECT	prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT id_poliza,
				prima_emitida
		FROM emision e
		) t1
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
				GROUP BY id_poliza
			) t2
	ON t1.id_poliza=t2.id_poliza
    ) t4;
    
-- 1.6.5. Resultado tecnico por cobertura

SELECT	cobertura,
		SUM(prima_emitida_cobertura)-SUM(sin_cobertura) AS resultado_tecnico
FROM(SELECT	cobertura,
			prima_emitida_cobertura,
			CASE
            WHEN monto_siniestros IS NULL THEN 0
            ELSE monto_siniestros
            END AS sin_cobertura
	FROM(SELECT id_poliza,
				pc.id_cobertura,
				nombre_cobertura AS cobertura,
				prima_emitida_cobertura
		FROM poliza_cobertura pc
        JOIN coberturas c
        ON pc.id_cobertura=c.id_cobertura
		) t1
	LEFT JOIN(SELECT	id_poliza,
				id_cobertura,
				SUM(monto_siniestro) AS monto_siniestros
		FROM siniestros s
		GROUP BY id_poliza, id_cobertura
			) t2
	ON t1.id_poliza=t2.id_poliza
    AND t1.id_cobertura=t2.id_cobertura
    ) t4
GROUP BY cobertura
ORDER BY resultado_tecnico DESC;

-- 1.6.6. Contribucion al resultado tecnico de cada cobertura
SELECT	cobertura,
		rdo_tec/SUM(rdo_tec) OVER() AS pct_rdo_tec
FROM(SELECT	cobertura,
			SUM(prima_emitida_cobertura)-SUM(sin_cobertura) AS rdo_tec
	FROM(SELECT	cobertura,
				prima_emitida_cobertura,
				CASE
				WHEN monto_siniestros IS NULL THEN 0
				ELSE monto_siniestros
				END AS sin_cobertura
		FROM(SELECT id_poliza,
					pc.id_cobertura,
					nombre_cobertura AS cobertura,
					prima_emitida_cobertura
			FROM poliza_cobertura pc
			JOIN coberturas c
			ON pc.id_cobertura=c.id_cobertura
			) t1
		LEFT JOIN(SELECT	id_poliza,
					id_cobertura,
					SUM(monto_siniestro) AS monto_siniestros
			FROM siniestros s
			GROUP BY id_poliza, id_cobertura
				) t2
		ON t1.id_poliza=t2.id_poliza
		AND t1.id_cobertura=t2.id_cobertura
		) t4
	GROUP BY cobertura
    ) t5
ORDER BY pct_rdo_tec DESC;
	
-- 1.6.7. Margen técnico bruto

SELECT	(SUM(prima_emitida)-SUM(sin_poliza))/SUM(prima_emitida)*100 AS loss_ratio
FROM(SELECT	prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT id_poliza,
				prima_emitida
		FROM emision e
		) t1
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
				GROUP BY id_poliza
			) t2
	ON t1.id_poliza=t2.id_poliza
    ) t4;

-- 1.6.8. Resultado por poliza

SELECT	id_poliza,
		prima_emitida-sin_poliza AS rdo_poliza
FROM(SELECT	t1.id_poliza,
			prima_emitida,
			CASE
			WHEN sin_poliza IS NULL THEN 0
			ELSE sin_poliza
			END AS sin_poliza
	FROM(SELECT id_poliza,
				prima_emitida
		FROM emision e
		) t1
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
			FROM siniestros s
			GROUP BY id_poliza
			) t2
	ON t1.id_poliza=t2.id_poliza
    ) t3;
    
-- 1.6.9. Resultado por expuesto

SELECT	(SUM(prima_emitida)-SUM(sin_poliza))/SUM(uer_ind) AS resultado_por_expuesto
FROM(SELECT	prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza,
            uer_ind
	FROM(SELECT id_poliza,
				prima_emitida,
                uer_ind
		FROM(SELECT	*,
					(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
			FROM emision e
			) t1
		) t2
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
				GROUP BY id_poliza
			) t3
	ON t2.id_poliza=t3.id_poliza
    ) t4;
    
-- Concetracion de siniestros
-- =========================================================

-- 5% de siniestros mas grandes

SELECT	SUM(CASE WHEN top <= CEIL(0.05*tot_sin) THEN pct END) AS pct_siniestros
FROM(SELECT	monto_siniestro,
			monto_siniestro/SUM(monto_siniestro) OVER() AS pct,
            COUNT(*) OVER() AS tot_sin,
			ROW_NUMBER() OVER(ORDER BY monto_siniestro DESC) AS top
	FROM siniestros s
	) t1;
    
-- 10% de siniestros mas grandes

SELECT	SUM(CASE WHEN top <= CEIL(0.1*tot_sin) THEN pct END) AS pct_siniestros
FROM(SELECT	monto_siniestro,
			monto_siniestro/SUM(monto_siniestro) OVER() AS pct,
            COUNT(*) OVER() AS tot_sin,
			ROW_NUMBER() OVER(ORDER BY monto_siniestro DESC) AS top
	FROM siniestros s
	) t1;
    
-- 20% de siniestros mas grandes

SELECT	SUM(CASE WHEN top <= CEIL(0.2*tot_sin) THEN pct END) AS pct_siniestros
FROM(SELECT	monto_siniestro,
			monto_siniestro/SUM(monto_siniestro) OVER() AS pct,
            COUNT(*) OVER() AS tot_sin,
			ROW_NUMBER() OVER(ORDER BY monto_siniestro DESC) AS top
	FROM siniestros s
	) t1