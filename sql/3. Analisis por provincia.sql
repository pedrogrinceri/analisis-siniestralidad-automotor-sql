-- Base de datos
USE proyecto1;

-- PROYECTO ACTUARIAL
-- ETAPA 3: TOTAL POR PROVINCIA
-- ========================================================

-- 3.1. Exposición total

SELECT	provincia,
		SUM(uer_ind) AS UER
FROM(SELECT provincia,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind
	FROM emision) t1
GROUP BY provincia;

-- 3.2. Prima Emitida

SELECT 	provincia,
		SUM(prima_emitida) AS prima_total
FROM emision
GROUP BY provincia;



-- 3.3. Siniestros Totales

SELECT 	provincia,
		SUM(monto_siniestro)	siniestros_totales
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY provincia;

-- 3.4. Cantidad de siniestros

SELECT	provincia,
		COUNT(*) AS siniestros_ejercicio
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY provincia;


-- 3.5. Frecuencia

SELECT	provincia,
		SUM(n_sin)/SUM(uer_ind) AS frecuencia
FROM(SELECT	provincia,
			e.id_poliza,
			(DATEDIFF(fecha_fin,fecha_inicio)+1)/365 AS uer_ind,
			COUNT(id_siniestro) AS n_sin
	FROM emision e
	LEFT JOIN siniestros s
	ON e.id_poliza=s.id_poliza
    GROUP BY e.id_poliza
	) t1 
GROUP BY provincia;

-- 3.6. Severidad Promedio

SELECT 	provincia,
		SUM(monto_siniestro)/COUNT(*) AS siniestro_promedio
FROM siniestros s
LEFT JOIN emision e
ON s.id_poliza=e.id_poliza
GROUP BY provincia;

-- 3.7. Loss Ratio

SELECT	provincia,
		SUM(sin_poliza)/SUM(prima_emitida)*100 AS loss_ratio
FROM(SELECT	provincia,
			prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT provincia,
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
GROUP BY provincia;

-- 3.8. Resultado Tecnico Bruto

SELECT	provincia,
		SUM(prima_emitida)-SUM(sin_poliza) AS resultado_tecnico_bruto
FROM(SELECT	provincia,
			prima_emitida,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT provincia,
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
GROUP BY provincia;