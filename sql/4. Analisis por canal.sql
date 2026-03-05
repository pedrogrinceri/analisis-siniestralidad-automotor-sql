-- Base de datos
USE proyecto1;

-- PROYECTO ACTUARIAL
-- ETAPA 4: TOTAL POR CANAL
-- ========================================================

-- 4.1. Exposición total

SELECT	canal,
		SUM(uer_ind) AS UER
FROM(SELECT canal,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
	FROM emision) t1
GROUP BY canal;

-- 4.2. Prima Emitida

SELECT 	canal,
		SUM(prima_emitida) AS prima_total
FROM emision
GROUP BY canal;

-- 4.3. Distribución de prima emitida

SELECT	canal,
		prima_total/SUM(prima_total) OVER() AS porcentaje_de_prima
FROM(SELECT canal,
			SUM(prima_emitida) AS prima_total
	FROM emision
	GROUP BY canal
    ) t1;

-- 4.4. Siniestros Totales

SELECT 	canal,
		SUM(monto_siniestro)	siniestros_totales
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY canal;

-- 4.5. Distribucion de siniestros

SELECT	canal,
		siniestros_totales/SUM(siniestros_totales) OVER() AS porcentaje_de_siniestros
FROM(SELECT canal,
			SUM(monto_siniestro)	siniestros_totales
	FROM siniestros s
	LEFT JOIN emision e
	ON s.id_poliza=e.id_poliza
	GROUP BY canal
	) t1;

-- 4.6. Cantidad de siniestros

SELECT	canal,
		COUNT(*) AS siniestros_ejercicio
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY canal;

-- 4.7. Frecuencia

SELECT	canal,
		SUM(n_sin)/SUM(uer_ind) AS frecuencia
FROM(SELECT	canal,
			e.id_poliza,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind,
			COUNT(id_siniestro) AS n_sin
	FROM emision e
	LEFT JOIN siniestros s
	ON e.id_poliza=s.id_poliza
    GROUP BY e.id_poliza
	) t1 
GROUP BY canal;

-- 4.8. Severidad Promedio

SELECT 	canal,
		SUM(monto_siniestro)/COUNT(*) AS siniestro_promedio
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY canal;

-- 4.9. Loss Ratio

SELECT	canal,
		SUM(sin_poliza)/SUM(prima_emitida)*100 AS loss_ratio
FROM(SELECT	canal,
			prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT canal,
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
    ) t4
GROUP BY canal;

-- 4.10. Resultado Tecnico Bruto

SELECT	canal,
		SUM(prima_emitida)-SUM(sin_poliza) AS resultado_tecnico_bruto
FROM(SELECT	canal,
			prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT canal,
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
    ) t4
GROUP BY canal;

SELECT * FROM emision