-- Cantidad de intentos por fecha y estado (todas las fechas proyectadas con datos).
SELECT
    fecha,
    estado,
    COUNT(*) AS total_intentos
FROM final_si_pepe_gabriel_giraldo.entregas
GROUP BY fecha, estado
ORDER BY fecha ASC, estado ASC;
