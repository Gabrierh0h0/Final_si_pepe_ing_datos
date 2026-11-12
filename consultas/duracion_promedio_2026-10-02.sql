-- Duración promedio de las entregas exitosas del 2026-10-02 (sin contar los ceros de los intentos fallidos).
SELECT
    fecha,
    CAST(ROUND(AVG(duracion_minutos), 2) AS DECIMAL(6, 2)) AS duracion_promedio_minutos
FROM final_si_pepe_gabriel_giraldo.entregas
WHERE fecha = '2026-10-02'
  AND estado = 'entregado'
GROUP BY fecha;
