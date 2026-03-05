-- Base de Datos
USE proyecto1;

-- Rentabilidad con corte al 30-06-2019
-- ETAPA 1: QUINQUENAL

-- 1.1 Loss Ratio
SELECT	SUM(sin_poliza)/SUM(prima_dev)*100 AS loss_ratio
FROM(SELECT	prima_dev,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT id_poliza,
				prima_emitida*vig_corrida/vig_dias AS prima_dev
		FROM(SELECT	*,
					DATEDIFF(fecha_fin,fecha_inicio)+1	AS vig_dias,
					CASE
					WHEN fecha_fin <= STR_TO_DATE("2019-6-30","%Y-%m-%d") THEN DATEDIFF(fecha_fin,fecha_inicio)+1
					ELSE DATEDIFF(STR_TO_DATE("2019-6-30","%Y-%m-%d"),fecha_inicio)+1
					END AS vig_corrida
			FROM emision e
			) t1
		) t2
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
                WHERE fecha_ocurrencia <= STR_TO_DATE("2019-6-30","%Y-%m-%d") 
				GROUP BY id_poliza
			) t3
	ON t2.id_poliza=t3.id_poliza
    ) t4;

-- 1.2. Resultado técnico bruto

SELECT	SUM(prima_dev)-SUM(sin_poliza) AS resultado_tecnico_bruto
FROM(SELECT	prima_dev,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT id_poliza,
				prima_emitida*vig_corrida/vig_dias AS prima_dev
		FROM(SELECT	*,
					DATEDIFF(fecha_fin,fecha_inicio)+1	AS vig_dias,
					CASE
					WHEN fecha_fin <= STR_TO_DATE("2019-6-30","%Y-%m-%d") THEN DATEDIFF(fecha_fin,fecha_inicio)+1
					ELSE DATEDIFF(STR_TO_DATE("2019-6-30","%Y-%m-%d"),fecha_inicio)+1
					END AS vig_corrida
			FROM emision e
			) t1
		) t2
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
                WHERE fecha_ocurrencia <= STR_TO_DATE("2019-6-30","%Y-%m-%d")
				GROUP BY id_poliza
			) t3
	ON t2.id_poliza=t3.id_poliza
    ) t4;

-- 1.3. Margen técnico bruto

SELECT	(SUM(prima_dev)-SUM(sin_poliza))/SUM(prima_dev)*100 AS margen_tecnico_bruto
FROM(SELECT	prima_dev,
			CASE
            WHEN sin_poliza IS NULL THEN 0
            ELSE sin_poliza
            END AS sin_poliza
	FROM(SELECT id_poliza,
				prima_emitida*vig_corrida/vig_dias AS prima_dev
		FROM(SELECT	*,
					DATEDIFF(fecha_fin,fecha_inicio)+1	AS vig_dias,
					CASE
					WHEN fecha_fin <= STR_TO_DATE("2019-6-30","%Y-%m-%d") THEN DATEDIFF(fecha_fin,fecha_inicio)+1
					ELSE DATEDIFF(STR_TO_DATE("2019-6-30","%Y-%m-%d"),fecha_inicio)+1
					END AS vig_corrida
			FROM emision e
			) t1
		) t2
	LEFT JOIN(SELECT	id_poliza,
						SUM(monto_siniestro) AS sin_poliza
				FROM siniestros s
                WHERE fecha_ocurrencia <= STR_TO_DATE("2019-6-30","%Y-%m-%d") 
				GROUP BY id_poliza
			) t3
	ON t2.id_poliza=t3.id_poliza
    ) t4;
    
-- ETAPA 2: POR EJERCICIO

-- 2.1. Loss Ratio

SELECT ejercicio, 
		SUM(sin_poliza)/SUM(prima_dev)*100 AS loss_ratio 
FROM(SELECT ejercicio, 
			prima_dev, 
			CASE 
			WHEN sin_poliza IS NULL THEN 0 
			ELSE sin_poliza 
			END AS sin_poliza 
	FROM(SELECT ejercicio, 
				id_poliza, 
				prima_emitida*vig_corrida/vig_dias AS prima_dev 
		FROM(SELECT *, 
					DATEDIFF(fecha_fin,fecha_inicio)+1 AS vig_dias, 
					CASE 
					WHEN fecha_fin <= STR_TO_DATE("2019-6-30","%Y-%m-%d") THEN DATEDIFF(fecha_fin,fecha_inicio)+1 
					ELSE DATEDIFF(STR_TO_DATE("2019-6-30","%Y-%m-%d"),fecha_inicio)+1 
					END AS vig_corrida 
			FROM emision e 
			) t1 
		) t2 
	LEFT JOIN(SELECT	id_poliza, 
						SUM(monto_siniestro) AS sin_poliza 
			FROM siniestros s
            WHERE fecha_ocurrencia <= STR_TO_DATE("2019-6-30","%Y-%m-%d") 
			GROUP BY id_poliza 
			) t3 
	ON t2.id_poliza=t3.id_poliza 
	) t4 
GROUP BY ejercicio;

-- 2.1. Resultado tecnico bruto

SELECT 	ejercicio, 
		SUM(prima_dev)-SUM(sin_poliza) AS resultado_tecnico_bruto
FROM(SELECT ejercicio, 
			prima_dev, 
			CASE 
			WHEN sin_poliza IS NULL THEN 0 
			ELSE sin_poliza 
			END AS sin_poliza 
	FROM(SELECT ejercicio, 
				id_poliza, 
				prima_emitida*vig_corrida/vig_dias AS prima_dev 
		FROM(SELECT *, 
					DATEDIFF(fecha_fin,fecha_inicio)+1 AS vig_dias, 
					CASE 
					WHEN fecha_fin <= STR_TO_DATE("2019-6-30","%Y-%m-%d") THEN DATEDIFF(fecha_fin,fecha_inicio)+1 
					ELSE DATEDIFF(STR_TO_DATE("2019-6-30","%Y-%m-%d"),fecha_inicio)+1 
					END AS vig_corrida 
			FROM emision e 
			) t1 
		) t2 
	LEFT JOIN(SELECT	id_poliza, 
						SUM(monto_siniestro) AS sin_poliza 
			FROM siniestros s
            WHERE fecha_ocurrencia <= STR_TO_DATE("2019-6-30","%Y-%m-%d") 
			GROUP BY id_poliza 
			) t3 
	ON t2.id_poliza=t3.id_poliza 
	) t4 
GROUP BY ejercicio;

-- 2.3. Margen tecnico bruto

SELECT ejercicio, 
		(SUM(prima_dev)-SUM(sin_poliza))/SUM(prima_dev)*100 AS loss_ratio 
FROM(SELECT ejercicio, 
			prima_dev, 
			CASE 
			WHEN sin_poliza IS NULL THEN 0 
			ELSE sin_poliza 
			END AS sin_poliza 
	FROM(SELECT ejercicio, 
				id_poliza, 
				prima_emitida*vig_corrida/vig_dias AS prima_dev 
		FROM(SELECT *, 
					DATEDIFF(fecha_fin,fecha_inicio)+1 AS vig_dias, 
					CASE 
					WHEN fecha_fin <= STR_TO_DATE("2019-6-30","%Y-%m-%d") THEN DATEDIFF(fecha_fin,fecha_inicio)+1 
					ELSE DATEDIFF(STR_TO_DATE("2019-6-30","%Y-%m-%d"),fecha_inicio)+1 
					END AS vig_corrida 
			FROM emision e 
			) t1 
		) t2 
	LEFT JOIN(SELECT	id_poliza, 
						SUM(monto_siniestro) AS sin_poliza 
			FROM siniestros s
            WHERE fecha_ocurrencia <= STR_TO_DATE("2019-6-30","%Y-%m-%d") 
			GROUP BY id_poliza 
			) t3 
	ON t2.id_poliza=t3.id_poliza 
	) t4 
GROUP BY ejercicio;