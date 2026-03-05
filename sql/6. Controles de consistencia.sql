-- Base de datos
USE proyecto1;


-- Control de que todo siniestro sea de una cobertura contratada

SELECT *
FROM siniestros s
WHERE NOT EXISTS(SELECT	e.id_poliza,
						id_cobertura
				FROM emision e
                JOIN poliza_cobertura pc
                ON e.id_poliza=pc.id_poliza
                WHERE s.id_poliza=e.id_poliza
				AND s.id_cobertura=pc.id_cobertura
                );
                
-- Control de las primas emitidas
SELECT DISTINCT control
FROM(SELECT	e.id_poliza,
			prima_emitida,
			prima_emitida1,
			prima_emitida-prima_emitida1 AS control
	FROM emision e
	LEFT JOIN(SELECT	id_poliza,
			SUM(prima_emitida_cobertura) AS prima_emitida1
			FROM poliza_cobertura
			GROUP BY id_poliza
			) t1
	ON e.id_poliza=t1.id_poliza
    ) t2