-- Base de datos
USE proyecto1;

-- PROYECTO ACTUARIAL
-- ETAPA 2: TOTAL POR EJERCICIO
-- ========================================================
-- 2.1 Medidas de cartera
-- ========================================================
-- 2.1.1. Emision total

SELECT	ejercicio,
		COUNT(*) AS emision_total
FROM emision
GROUP BY ejercicio;

-- 2.1.2. Exposición total

SELECT	ejercicio,
		SUM(uer_ind) AS UER
FROM(SELECT ejercicio,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
	FROM emision) t1
GROUP BY ejercicio;

-- 2.1.3. Polizas vigentes promedio

SELECT	ejercicio,
		SUM(uer_ind) AS uer_promedio_mensual
FROM(SELECT (DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind,
	ejercicio	
	FROM emision) t1
GROUP BY ejercicio;
    
-- 2.1.4. Suma asegurada

SELECT 	ejercicio,
		SUM(v.suma_asegurada) AS suma_asegurada
FROM emision e
JOIN vehiculos v
ON e.id_vehiculo=v.id_vehiculo
GROUP BY ejercicio;

-- 2.1.5 Composición de Productos

SELECT	ejercicio,
		producto,
		total/SUM(total) OVER(PARTITION BY ejercicio) AS distribucion
FROM(SELECT 	ejercicio,
				producto,
				COUNT(*) AS total
	FROM emision e
	JOIN productos p
	ON e.id_producto=p.id_producto
	GROUP BY ejercicio,producto
    ) t1
ORDER BY ejercicio, distribucion DESC;

-- 2.1.6 Distribución de productos ponderados por emisión

SELECT	ejercicio,
		producto,
		prima/SUM(prima) OVER(PARTITION BY ejercicio) AS distribucion
FROM(SELECT	ejercicio,
			producto,
			SUM(prima_emitida) as prima
	FROM emision e
	LEFT JOIN productos p
	ON e.id_producto=p.id_producto
	GROUP BY ejercicio,producto
    ) t1
ORDER BY ejercicio, distribucion DESC;

-- 2.1.7 Composición de coberturas

SELECT	ejercicio,
		cobertura,
		total/SUM(total) OVER(PARTITION BY ejercicio) AS distribucion
FROM(SELECT	ejercicio,
			cobertura,
			COUNT(cobertura) AS total
	FROM emision e
	JOIN(SELECT	pc.id_poliza,
				nombre_cobertura AS cobertura
		FROM poliza_cobertura pc
		JOIN coberturas c
		ON pc.id_cobertura=c.id_cobertura
		) t1
	ON e.id_poliza=t1.id_poliza
	GROUP BY ejercicio, cobertura
	) t2
ORDER BY ejercicio, distribucion DESC;

-- 2.1.8 Composición de coberturas ponderada por prima

SELECT	ejercicio,
		cobertura,
		prima_total/SUM(prima_total) OVER(PARTITION BY ejercicio) AS distribucion
FROM(SELECT	ejercicio,
			cobertura,
			SUM(prima_emitida_cobertura) prima_total
	FROM(SELECT	pc.id_poliza,
				nombre_cobertura AS cobertura,
				prima_emitida_cobertura
		FROM poliza_cobertura pc
		LEFT JOIN coberturas c
		ON pc.id_cobertura=c.id_cobertura
		) t1
	LEFT JOIN emision e
	ON e.id_poliza=t1.id_poliza
	GROUP BY ejercicio, cobertura
	) t2
ORDER BY ejercicio, distribucion DESC;

-- ========================================================
-- 2.2 Siniestros - Casos
-- ========================================================
-- 2.2.1. Cantidad de siniestros

SELECT	ejercicio,
		COUNT(id_siniestro) AS siniestros_ejercicio
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY ejercicio;

-- 2.2.2. Siniestros por poliza

-- Ejercicio 2014-2015
SELECT	ejercicio,
		e.id_poliza,
		COUNT(s.id_siniestro) AS total_siniestros
FROM emision e
LEFT JOIN siniestros s
ON e.id_poliza=s.id_poliza
GROUP BY e.id_poliza
HAVING ejercicio="2014-2015";

-- Ejercicio 2015-2016
SELECT	ejercicio,
		e.id_poliza,
		COUNT(s.id_siniestro) AS total_siniestros
FROM emision e
LEFT JOIN siniestros s
ON e.id_poliza=s.id_poliza
GROUP BY e.id_poliza
HAVING ejercicio="2015-2016";

-- Ejercicio 2016-2017
SELECT	ejercicio,
		e.id_poliza,
		COUNT(s.id_siniestro) AS total_siniestros
FROM emision e
LEFT JOIN siniestros s
ON e.id_poliza=s.id_poliza
GROUP BY e.id_poliza
HAVING ejercicio="2016-2017";

-- Ejercicio 2017-2018
SELECT	ejercicio,
		e.id_poliza,
		COUNT(s.id_siniestro) AS total_siniestros
FROM emision e
LEFT JOIN siniestros s
ON e.id_poliza=s.id_poliza
GROUP BY e.id_poliza
HAVING ejercicio="2017-2018";

-- Ejercicio 2018-2019
SELECT	ejercicio,
		e.id_poliza,
		COUNT(s.id_siniestro) AS total_siniestros
FROM emision e
LEFT JOIN siniestros s
ON e.id_poliza=s.id_poliza
GROUP BY e.id_poliza
HAVING ejercicio="2018-2019";

-- 2.2.3. Porcentaje de polizas siniestradas

SELECT 	ejercicio,
		SUM(control_siniestro)/COUNT(*) AS pct_polizas_siniestradas
FROM(SELECT	DISTINCT ejercicio,
					e.id_poliza,
					CASE
					WHEN id_siniestro IS NULL THEN 0
					ELSE 1
					END AS control_siniestro
	FROM emision e
	LEFT JOIN siniestros s
	ON e.id_poliza=s.id_poliza
	) t1
GROUP BY ejercicio;
    
-- 2.2.4. Casos por cobertura

SELECT	ejercicio,
		id_cobertura,
		COUNT(*) AS siniestros_ejercicio
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY ejercicio, id_cobertura;

-- ========================================================
-- 2.3 Siniestros - Montos
-- =========================================================
-- 2.3.1. Severidad Promedio

SELECT 	ejercicio,
		SUM(monto_siniestro)/COUNT(id_siniestro) AS siniestro_promedio
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY ejercicio;

-- 2.3.2. Severidad Promedio por cobertura

SELECT	cobertura,
		AVG(siniestro_promedio) AS media,
        SQRT(VARIANCE(siniestro_promedio)) AS desvio,
        SQRT(VARIANCE(siniestro_promedio))/AVG(siniestro_promedio) AS cv
FROM(SELECT ejercicio,
			nombre_cobertura AS cobertura,
			SUM(monto_siniestro)/COUNT(id_siniestro) AS siniestro_promedio
	FROM siniestros s
	LEFT JOIN emision e
	ON s.id_poliza=e.id_poliza
	JOIN coberturas c
	ON s.id_cobertura=c.id_cobertura
	GROUP BY ejercicio, nombre_cobertura
    ) t1
GROUP BY cobertura;

-- 2.3.3. Varianza y Desviación estandar

SELECT	ejercicio,
		VARIANCE(monto_siniestro) AS varianza,
		SQRT(VARIANCE(monto_siniestro)) AS desvio_estandar
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY ejercicio;

    
-- 2.3.4. Coeficiente de Variación

SELECT	ejercicio,
		ROUND(SQRT(VARIANCE(monto_siniestro))/AVG(monto_siniestro)*100,2) AS coeficiente_variacion
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY ejercicio;

-- 2.3.5. Severidad Mediana y Percentiles
SELECT 	ejercicio,
		MIN(CASE WHEN pct >= 0.25 THEN monto_siniestro END) AS "percentil_25",
		MIN(CASE WHEN pct >= 0.5 THEN monto_siniestro END) AS "mediana",
        MIN(CASE WHEN pct >= 0.75 THEN monto_siniestro END) AS "percentil_75",
        MIN(CASE WHEN pct >= 0.9 THEN monto_siniestro END) AS "percentil_90",
        MIN(CASE WHEN pct >= 0.95 THEN monto_siniestro END) AS "percentil_95",
        MIN(CASE WHEN pct = 1 THEN monto_siniestro END) AS "siniestro maximo"
FROM(SELECT ejercicio,
			monto_siniestro,
			CUME_DIST() OVER(PARTITION BY ejercicio ORDER BY monto_siniestro) AS pct
	FROM siniestros s
    LEFT JOIN emision e
	ON s.id_poliza=e.id_poliza
    ) t1
GROUP BY ejercicio;

-- Considerando los logaritmos naturales

SELECT 	ejercicio,
		LN(MIN(CASE WHEN pct >= 0.25 THEN monto_siniestro END)) AS "percentil_25",
		LN(MIN(CASE WHEN pct >= 0.5 THEN monto_siniestro END)) AS "mediana",
        LN(MIN(CASE WHEN pct >= 0.75 THEN monto_siniestro END)) AS "percentil_75",
        LN(MIN(CASE WHEN pct >= 0.9 THEN monto_siniestro END)) AS "percentil_90",
        LN(MIN(CASE WHEN pct >= 0.95 THEN monto_siniestro END)) AS "percentil_95",
        LN(MIN(CASE WHEN pct = 1 THEN monto_siniestro END)) AS "siniestro maximo"
FROM(SELECT ejercicio,
			monto_siniestro,
			CUME_DIST() OVER(PARTITION BY ejercicio ORDER BY monto_siniestro) AS pct
	FROM siniestros s
    LEFT JOIN emision e
	ON s.id_poliza=e.id_poliza
    ) t1
GROUP BY ejercicio;

-- ========================================================
-- 2.4 Pricing
-- =========================================================
-- 2.4.1. Frecuencia

SELECT	ejercicio,
		SUM(n_sin)/SUM(uer_ind) AS frecuencia
FROM(SELECT	ejercicio,
			e.id_poliza,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind,
			COUNT(id_siniestro) AS n_sin
	FROM emision e
	LEFT JOIN siniestros s
	ON e.id_poliza=s.id_poliza
    GROUP BY e.id_poliza
	) t1 
GROUP BY ejercicio;

-- 2.4.2. Frecuencia por cobertura

SELECT 	ejercicio,
		cobertura,
		SUM(n_sin)/SUM(uer_ind) AS frecuencia
FROM(SELECT	ejercicio,
			cobertura,
			uer_ind,
			COALESCE(n_sin,0) AS n_sin
	FROM(SELECT	e.id_poliza,
				ejercicio,
				pc.id_cobertura,
				nombre_cobertura AS cobertura,
				(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
		FROM emision e
		JOIN poliza_cobertura pc
		ON e.id_poliza=pc.id_poliza
		JOIN coberturas c
		ON pc.id_cobertura=c.id_cobertura
		) t1
	LEFT JOIN(SELECT id_poliza,
					 id_cobertura,
					 COUNT(monto_siniestro) AS n_sin
			 FROM siniestros s
			 GROUP BY id_poliza, id_cobertura
			 ) t2
	ON t1.id_poliza=t2.id_poliza
	AND t1.id_cobertura=t2.id_cobertura
    ) t3
GROUP BY ejercicio, cobertura;

-- 2.4.3. Media, Desvio y CV de la Frecuencia
SELECT	cobertura,
		AVG(frecuencia) AS media,
        SQRT(VARIANCE(frecuencia)) AS desvio,
        SQRT(VARIANCE(frecuencia))/AVG(frecuencia) AS cv
FROM(SELECT ejercicio,
			cobertura,
			SUM(n_sin)/SUM(uer_ind) AS frecuencia
	FROM(SELECT	ejercicio,
				cobertura,
				uer_ind,
				COALESCE(n_sin,0) AS n_sin
		FROM(SELECT	e.id_poliza,
					ejercicio,
					pc.id_cobertura,
					nombre_cobertura AS cobertura,
					(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
			FROM emision e
			JOIN poliza_cobertura pc
			ON e.id_poliza=pc.id_poliza
			JOIN coberturas c
			ON pc.id_cobertura=c.id_cobertura
			) t1
		LEFT JOIN(SELECT id_poliza,
						 id_cobertura,
						 COUNT(monto_siniestro) AS n_sin
				 FROM siniestros s
				 GROUP BY id_poliza, id_cobertura
				 ) t2
		ON t1.id_poliza=t2.id_poliza
		AND t1.id_cobertura=t2.id_cobertura
		) t3
	GROUP BY ejercicio, cobertura
    ) t4
GROUP BY cobertura;

-- 2.4.4. Prima Pura

SELECT	ejercicio,
		SUM(sin_total_poliza)/SUM(uer_ind) AS prima_pura
FROM(SELECT	ejercicio,
			id_poliza,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind,
			SUM(monto_siniestro) AS sin_total_poliza
	FROM(SELECT	e.ejercicio,
				e.id_poliza,
				e.fecha_inicio,
				e.fecha_fin,
				monto_siniestro
		FROM emision e
		LEFT JOIN siniestros s
		ON e.id_poliza=s.id_poliza
		) t1
	GROUP BY id_poliza
	) t2
GROUP BY ejercicio;
    
-- 2.4.5. Prima Pura por cobertura

SELECT	t3.ejercicio,
		cobertura,
		monto_tot_cob/uer_tot_cob AS prima_pura_cob
FROM(SELECT	ejercicio,
			id_cobertura,
			cobertura,
			SUM(uer_cob) AS uer_tot_cob
	FROM(SELECT	ejercicio,
				e.id_poliza,
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
	GROUP BY ejercicio, id_cobertura
    ) t3 
LEFT JOIN(SELECT	ejercicio,
					id_cobertura,
					SUM(monto_siniestro) AS monto_tot_cob
		FROM siniestros s
        LEFT JOIN emision e
        ON s.id_poliza=e.id_poliza
		GROUP BY ejercicio, id_cobertura
		) t4
ON t3.id_cobertura=t4.id_cobertura
AND t3.ejercicio=t4.ejercicio
ORDER BY ejercicio;

-- 2.4.6. Prima Pura por producto
SELECT	ejercicio,
		producto,
		prima_pura_producto
FROM(SELECT	t2.ejercicio,
			t2.id_producto,
			monto_tot_prod/uer_tot_prod AS prima_pura_producto
	FROM(SELECT	ejercicio,
				id_producto,
				SUM(uer_prod) AS uer_tot_prod
		FROM(SELECT	ejercicio,
					id_poliza,
					id_producto,
					(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_prod
			FROM emision
			) t1
	GROUP BY ejercicio, id_producto
		) t2
	LEFT JOIN(SELECT	ejercicio,
						id_producto,
						SUM(monto_siniestro) monto_tot_prod
			FROM siniestros s
			LEFT JOIN emision e1
			ON s.id_poliza=e1.id_poliza
			GROUP BY ejercicio, id_producto
			) t3 
	ON t2.id_producto=t3.id_producto
    AND t2.ejercicio=t3.ejercicio
	) t4
JOIN productos p
ON t4.id_producto=p.id_producto
ORDER BY ejercicio;

-- ========================================================
-- 2.5 Primas
-- =========================================================
-- 2.5.1. Prima Emitida

SELECT 	ejercicio,
		SUM(prima_emitida) AS prima_total
FROM emision
GROUP BY ejercicio;

-- 2.5.2. Prima emitida por cobertura

SELECT 	ejercicio,
		nombre_cobertura AS cobertura,
		SUM(prima_emitida_cobertura) AS prima_emitida
FROM emision e 
JOIN poliza_cobertura pc
ON e.id_poliza=pc.id_poliza
JOIN coberturas c
ON pc.id_cobertura=c.id_cobertura
GROUP BY ejercicio, nombre_cobertura
ORDER BY ejercicio ASC, prima_emitida DESC;

-- 2.5.3. Prima Devengada
SELECT 	ejercicio,
		SUM(prima_emitida*vig_corrida/vig_dias) AS prima_devengada
FROM(SELECT	*,
			DATEDIFF(fecha_fin,fecha_inicio)+1	AS vig_dias,
			CASE
			WHEN fecha_fin <= STR_TO_DATE("2019-6-30","%Y-%m-%d") THEN DATEDIFF(fecha_fin,fecha_inicio)+1
			ELSE DATEDIFF(STR_TO_DATE("2019-6-30","%Y-%m-%d"),fecha_inicio)+1
			END AS vig_corrida
	FROM emision
    ) t1
GROUP BY ejercicio;
    
-- 2.5.4. Prima promedio
SELECT	ejercicio,
		AVG(prima_emitida) prima_promedio
FROM emision
GROUP BY ejercicio;

-- 2.5.5. Prima por unidad expuesta
SELECT	ejercicio,
		SUM(prima_emitida)/SUM(uer_ind) AS prima_por_uer
FROM(SELECT	ejercicio,
			prima_emitida,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
	FROM emision
    ) t1
GROUP BY ejercicio;

-- ========================================================
-- 2.6 Rentabilidad
-- =========================================================
-- 2.6.1. Siniestros Totales

SELECT 	ejercicio,
		SUM(monto_siniestro)	siniestros_totales
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY ejercicio;

-- 2.6.2. Loss Ratio
SELECT	ejercicio,
		SUM(sin_poliza)/SUM(prima_emitida)*100 AS loss_ratio
FROM(SELECT	ejercicio,
			prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT ejercicio,
				id_poliza,
				prima_emitida
		FROM emision e
		) t1
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
				GROUP BY id_poliza
			) t2
	ON t1.id_poliza=t2.id_poliza
    ) t3
GROUP BY ejercicio;

-- 2.6.3. Loss Ratio por cobertura
SELECT	ejercicio,
		cobertura,
		SUM(sin_poliza)/SUM(prima_emitida_cobertura) AS loss_ratio
FROM(SELECT	ejercicio,
			cobertura,
			prima_emitida_cobertura,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT pc.id_poliza,
				pc.id_cobertura,
                ejercicio,
				nombre_cobertura AS cobertura,
				prima_emitida_cobertura
		FROM poliza_cobertura pc
        JOIN coberturas c
        ON pc.id_cobertura=c.id_cobertura
        JOIN emision e
        ON e.id_poliza=pc.id_poliza
		) t1
	LEFT JOIN(SELECT	id_poliza,
						id_cobertura,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
				GROUP BY id_poliza, id_cobertura
			) t2
	ON t1.id_poliza=t2.id_poliza
    AND t1.id_cobertura=t2.id_cobertura
    ) t3
GROUP BY ejercicio, cobertura
ORDER BY ejercicio,cobertura;

-- 2.6.4. Resultado técnico bruto

SELECT	ejercicio,
		SUM(prima_emitida)-SUM(sin_poliza) AS resultado_tecnico_bruto
FROM(SELECT	ejercicio,
			prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT ejercicio,
				id_poliza,
				prima_emitida
		FROM emision e
		) t1
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
				GROUP BY id_poliza
			) t2
	ON t1.id_poliza=t2.id_poliza
    ) t3
GROUP BY ejercicio;

-- 2.6.5. Resultado tecnico por cobertura

SELECT	ejercicio,
		cobertura,
		SUM(prima_emitida_cobertura)-SUM(sin_poliza) AS resultado_tecnico
FROM(SELECT	ejercicio,
			cobertura,
			prima_emitida_cobertura,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT pc.id_poliza,
				pc.id_cobertura,
                ejercicio,
				nombre_cobertura AS cobertura,
				prima_emitida_cobertura
		FROM poliza_cobertura pc
        JOIN coberturas c
        ON pc.id_cobertura=c.id_cobertura
        JOIN emision e
        ON e.id_poliza=pc.id_poliza
		) t1
	LEFT JOIN(SELECT	id_poliza,
						id_cobertura,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
				GROUP BY id_poliza, id_cobertura
			) t2
	ON t1.id_poliza=t2.id_poliza
    AND t1.id_cobertura=t2.id_cobertura
    ) t3
GROUP BY ejercicio, cobertura
ORDER BY ejercicio,cobertura;

-- 2.6.6. Composicion en el resultado tecnico

SELECT	ejercicio,
		cobertura,
        100*resultado_tecnico/SUM(resultado_tecnico) OVER(PARTITION BY ejercicio) AS pct_rdo_tec
FROM(SELECT	ejercicio,
			cobertura,
			SUM(prima_emitida_cobertura)-SUM(sin_poliza) AS resultado_tecnico
	FROM(SELECT	ejercicio,
				cobertura,
				prima_emitida_cobertura,
				CASE
				WHEN sin_poliza IS NULL THEN 0
				ELSE sin_poliza
				END AS sin_poliza
		FROM(SELECT pc.id_poliza,
					pc.id_cobertura,
					ejercicio,
					nombre_cobertura AS cobertura,
					prima_emitida_cobertura
			FROM poliza_cobertura pc
			JOIN coberturas c
			ON pc.id_cobertura=c.id_cobertura
			JOIN emision e
			ON e.id_poliza=pc.id_poliza
			) t1
		LEFT JOIN(SELECT	id_poliza,
							id_cobertura,
							SUM(monto_siniestro) AS sin_poliza
					FROM siniestros s
					GROUP BY id_poliza, id_cobertura
				) t2
		ON t1.id_poliza=t2.id_poliza
		AND t1.id_cobertura=t2.id_cobertura
		) t3
	GROUP BY ejercicio, cobertura
	ORDER BY ejercicio,cobertura
    ) t4;

-- 2.6.7. Margen técnico bruto

SELECT	ejercicio,
		(SUM(prima_emitida)-SUM(sin_poliza))/SUM(prima_emitida)*100 AS margen_tecnico_bruto
FROM(SELECT	ejercicio,
			prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT ejercicio,
				id_poliza,
				prima_emitida
		FROM emision e
		) t1
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
				GROUP BY id_poliza
			) t2
	ON t1.id_poliza=t2.id_poliza
    ) t3
GROUP BY ejercicio;

-- 2.6.8. Resultado por poliza

SELECT	ejercicio,
		id_poliza,
		prima_emitida-sin_poliza AS rdo_poliza
FROM(SELECT	ejercicio,
			t1.id_poliza,
			prima_emitida,
			CASE
			WHEN sin_poliza IS NULL THEN 0
			ELSE sin_poliza
			END AS sin_poliza
	FROM(SELECT ejercicio,
				id_poliza,
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
    
-- 2.6.9. Resultado por expuesto

SELECT	ejercicio,
		(SUM(prima_emitida)-SUM(sin_poliza))/SUM(uer_ind) AS rt_por_uer
FROM(SELECT	ejercicio,
			prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza,
            uer_ind
	FROM(SELECT ejercicio,
				id_poliza,
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
    ) t4
GROUP BY ejercicio;

-- ========================================================
-- 2.7 Indicadores de Control
-- =========================================================

-- 2.7.1. Frecuencia YoY

SELECT	*,
		100*(frecuencia-LAG(frecuencia) OVER(ORDER BY ejercicio))/LAG(frecuencia) OVER(ORDER BY ejercicio) AS variacion_frecuencia
        FROM(SELECT	ejercicio,
			SUM(n_sin)/SUM(uer_ind) AS frecuencia
	FROM(SELECT	ejercicio,
				e.id_poliza,
				(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind,
				COUNT(id_siniestro) AS n_sin
		FROM emision e
		LEFT JOIN siniestros s
		ON e.id_poliza=s.id_poliza
		GROUP BY e.id_poliza
		) t1 
	GROUP BY ejercicio
    ) t2;
    
-- 2.7.2. Frecuencia por cobertura YoY

SELECT 	*,
		100*(frecuencia-LAG(frecuencia) OVER(PARTITION BY cobertura ORDER BY ejercicio))/LAG(frecuencia) OVER(PARTITION BY cobertura ORDER BY ejercicio) AS variacion
FROM(SELECT	ejercicio,
			cobertura,
			SUM(n_sin)/SUM(uer_ind) AS frecuencia
	FROM(SELECT	ejercicio,
				cobertura,
				uer_ind,
				COALESCE(n_sin,0) AS n_sin
		FROM(SELECT	e.id_poliza,
					ejercicio,
					pc.id_cobertura,
					nombre_cobertura AS cobertura,
					(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
			FROM emision e
			JOIN poliza_cobertura pc
			ON e.id_poliza=pc.id_poliza
			JOIN coberturas c
			ON pc.id_cobertura=c.id_cobertura
			) t1
		LEFT JOIN(SELECT id_poliza,
						 id_cobertura,
						 COUNT(monto_siniestro) AS n_sin
				 FROM siniestros s
				 GROUP BY id_poliza, id_cobertura
				 ) t2
		ON t1.id_poliza=t2.id_poliza
		AND t1.id_cobertura=t2.id_cobertura
		) t3
	GROUP BY ejercicio, cobertura
	) t4;

-- 2.7.3. Severidad YoY

SELECT	*,
		100*(siniestro_promedio-LAG(siniestro_promedio) OVER(ORDER BY siniestro_promedio))/LAG(siniestro_promedio) OVER(ORDER BY ejercicio) AS var_sin_promedio
FROM(SELECT ejercicio,
			AVG(monto_siniestro) AS siniestro_promedio
	FROM siniestros s
	LEFT JOIN emision e
	ON s.id_poliza=e.id_poliza
	GROUP BY ejercicio
    ) t1;

-- 2.7.4. Severidad por cobertura YOY

SELECT	*,
		100*(siniestro_promedio-LAG(siniestro_promedio) OVER(PARTITION BY cobertura ORDER BY ejercicio))/LAG(siniestro_promedio) OVER(PARTITION BY cobertura ORDER BY ejercicio) AS variacion
FROM(SELECT ejercicio,
			nombre_cobertura AS cobertura,
			SUM(monto_siniestro)/COUNT(id_siniestro) AS siniestro_promedio
	FROM siniestros s
	LEFT JOIN emision e
	ON s.id_poliza=e.id_poliza
	JOIN coberturas c
	ON s.id_cobertura=c.id_cobertura
	GROUP BY ejercicio, nombre_cobertura
    ) t1;

-- 2.7.5 Loss Ratio

SELECT	*,
		100*(loss_ratio-LAG(loss_ratio) OVER(ORDER BY ejercicio))/LAG(loss_ratio) OVER(ORDER BY ejercicio) AS variacion_lossratio
FROM(SELECT	ejercicio,
			SUM(sin_poliza)/SUM(prima_emitida)*100 AS loss_ratio
	FROM(SELECT	ejercicio,
				prima_emitida,
				CASE
				WHEN sin_poliza IS NULL THEN 0
				ELSE sin_poliza
				END AS sin_poliza
		FROM(SELECT ejercicio,
					id_poliza,
					prima_emitida
			FROM(SELECT	*
				FROM emision e
				) t1
			) t2
		LEFT JOIN(SELECT	id_poliza,
							SUM(monto_siniestro) AS sin_poliza
					FROM siniestros s
					GROUP BY id_poliza
				) t3
		ON t2.id_poliza=t3.id_poliza
		) t4
	GROUP BY ejercicio
    ) t5;
    
-- 2.7.6 Concentracion de siniestros

-- 5% de siniestros mas grandes

SELECT	ejercicio,
		SUM(CASE WHEN top <= CEIL(0.05*tot_sin) THEN pct END) AS pct_siniestros
FROM(SELECT	ejercicio,
			monto_siniestro,
			monto_siniestro/SUM(monto_siniestro) OVER(PARTITION BY ejercicio) AS pct,
            COUNT(*) OVER(PARTITION BY ejercicio) AS tot_sin,
			ROW_NUMBER() OVER(PARTITION BY ejercicio ORDER BY monto_siniestro DESC) AS top
	FROM siniestros s
	LEFT JOIN emision e
	ON s.id_poliza=e.id_poliza
	) t1
GROUP BY ejercicio;

-- 10% de siniestros mas grandes

SELECT	ejercicio,
		SUM(CASE WHEN top <= CEIL(0.1*tot_sin) THEN pct END) AS pct_siniestros
FROM(SELECT	ejercicio,
			monto_siniestro,
			monto_siniestro/SUM(monto_siniestro) OVER(PARTITION BY ejercicio) AS pct,
            COUNT(*) OVER(PARTITION BY ejercicio) AS tot_sin,
			ROW_NUMBER() OVER(PARTITION BY ejercicio ORDER BY monto_siniestro DESC) AS top
			FROM siniestros s
	LEFT JOIN emision e
	ON s.id_poliza=e.id_poliza
	) t1
GROUP BY ejercicio;

-- 20% de siniestros mas grandes

SELECT	ejercicio,
		SUM(CASE WHEN top <= CEIL(0.2*tot_sin) THEN pct END) AS pct_siniestros
FROM(SELECT	ejercicio,
			monto_siniestro,
			monto_siniestro/SUM(monto_siniestro) OVER(PARTITION BY ejercicio) AS pct,
            COUNT(*) OVER(PARTITION BY ejercicio) AS tot_sin,
			ROW_NUMBER() OVER(PARTITION BY ejercicio ORDER BY monto_siniestro DESC) AS top
			FROM siniestros s
	LEFT JOIN emision e
	ON s.id_poliza=e.id_poliza
	) t1
GROUP BY ejercicio