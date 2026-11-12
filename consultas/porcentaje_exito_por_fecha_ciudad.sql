-- Porcentaje de entregas exitosas por fecha y ciudad.
-- Denominador: todos los intentos del grupo. 100.0 evita la división entera.
SELECT
    fecha,
    ciudad,
    CAST(
        ROUND(100.0 * SUM(CASE WHEN estado = 'entregado' THEN 1 ELSE 0 END) / COUNT(*), 2)
        AS DECIMAL(5, 2)
    ) AS porcentaje_exito
FROM final_si_pepe_gabriel_giraldo.entregas
GROUP BY fecha, ciudad
ORDER BY fecha ASC, ciudad ASC;
