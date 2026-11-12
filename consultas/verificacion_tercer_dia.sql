-- Athena ejecuta una sola sentencia por ejecución: cada bloque se corre por separado.

-- Bloque 1: los seis registros del 2026-10-03
-- (resultado -> resultados/final/verificacion_tercer_dia.csv)
SELECT
    fecha,
    id_envio,
    ciudad,
    transportadora,
    estado,
    duracion_minutos
FROM final_si_pepe_gabriel_giraldo.entregas
WHERE fecha = '2026-10-03'
ORDER BY id_envio ASC;

-- Bloque 2: total de registros de la tabla (esperado: 18)
-- (resultado -> resultados/final/verificacion_total_registros.csv)
SELECT COUNT(*) AS total_registros
FROM final_si_pepe_gabriel_giraldo.entregas;
