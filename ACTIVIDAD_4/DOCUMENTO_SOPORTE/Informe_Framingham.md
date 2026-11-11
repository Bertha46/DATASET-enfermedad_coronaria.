# Actividad 4: Problema de regresión logística

**Estudiante:** Bertha Delmira Mero Castro  
**Asignatura:** Analítica de Datos  
**Docente:** [Nombre del docente]  
**Fecha:** [Fecha de entrega]

## Resumen
Este trabajo utiliza datos del estudio Framingham para analizar la predicción de enfermedad coronaria a diez años. La variable de respuesta es `TenYearCHD` (0 = no se registró el evento, 1 = se registró el evento). Se ajustó una regresión logística binaria y se comparó un modelo completo con uno simplificado. El script genera métricas de evaluación, matriz de confusión, coeficientes, razones de momios y curvas ROC. Los valores finales deben completarse con las salidas reales generadas al ejecutar el script.

## 1. Introducción
Las enfermedades cardiovasculares son un problema relevante de salud pública. La detección temprana de personas con mayor riesgo puede orientar estrategias preventivas y facilitar su evaluación clínica. La regresión logística permite modelar la probabilidad de una respuesta binaria a partir de factores demográficos, conductuales y médicos. En este ejercicio se utiliza el conjunto Framingham para estudiar la variable `TenYearCHD`.

## 2. Objetivos
### Objetivo general
Desarrollar y evaluar un modelo de regresión logística para predecir la presencia de enfermedad coronaria a diez años en el conjunto Framingham.

### Objetivos específicos
- Explorar la estructura y distribución de los datos.
- Identificar y tratar datos faltantes.
- Ajustar un modelo logístico completo y otro simplificado.
- Evaluar los modelos con métricas de clasificación y AUC.
- Interpretar coeficientes y razones de momios sin atribuir causalidad.

## 3. Datos y variables
La variable objetivo es `TenYearCHD`: 0 indica que el evento no se registró y 1 que sí se registró durante el periodo indicado por el conjunto de datos. Se utilizaron 14 predictores: sexo (`male`), edad (`age`), fumador actual (`currentSmoker`), cigarrillos diarios (`cigsPerDay`), medicación para presión (`BPMeds`), accidente cerebrovascular previo (`prevalentStroke`), hipertensión (`prevalentHyp`), diabetes (`diabetes`), colesterol (`totChol`), presión sistólica (`sysBP`), presión diastólica (`diaBP`), IMC (`BMI`), frecuencia cardíaca (`heartRate`) y glucosa (`glucose`). La columna `education` se excluyó porque no está en la lista de predictores solicitada.

Registros usados: **[N generado]**.  
Casos `TenYearCHD = 0`: **[N generado]**.  
Casos `TenYearCHD = 1`: **[N generado]**.

## 4. Metodología
Se revisaron las dimensiones, tipos, resúmenes y datos faltantes. Se excluyeron únicamente los registros sin respuesta conocida. El resto de valores faltantes se imputó con medianas calculadas en el conjunto de entrenamiento. Se realizó una división estratificada de 80 % entrenamiento y 20 % prueba, con semilla fija para reproducibilidad.

El modelo completo se estimó con todas las variables predictoras. Para el modelo simplificado, se tomaron las dos variables con menor valor p en el ajuste de entrenamiento. Se usó un umbral de clasificación de 0.50 y se calcularon exactitud, precisión, sensibilidad, especificidad, F1 y AUC en el conjunto de prueba.

## 5. Resultados
Completar esta tabla con `RESULTADOS/metricas_modelo.csv` después de ejecutar el script:

| Modelo | Accuracy | Precisión | Sensibilidad | Especificidad | F1 | AUC |
|---|---:|---:|---:|---:|---:|---:|
| Completo | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Simplificado | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

Las dos variables seleccionadas para el modelo simplificado fueron **[variables generadas]**. El modelo con mayor AUC fue **[modelo]**, con AUC **[valor]**. La matriz de confusión se encuentra en `RESULTADOS/matriz_confusion.txt`.

Las variables con p < 0.05, según el ajuste realizado, fueron **[variables obtenidas en coeficientes_modelo.csv]**. Para cada predictor, el odds ratio se interpreta manteniendo constantes los demás predictores; OR > 1 indica asociación positiva con los odds del evento y OR < 1 asociación negativa. Esta interpretación no demuestra causalidad.

## 6. Discusión
La comparación debe considerar conjuntamente AUC, sensibilidad y especificidad, no solo exactitud. La sensibilidad representa la proporción de eventos positivos detectados; la especificidad representa la proporción de casos negativos identificados. Debido a que el resultado es binario y las clases pueden estar desbalanceadas, la exactitud aislada puede ser insuficiente. La selección por valores p se utiliza aquí con propósito académico y no garantiza que el modelo simplificado sea clínicamente óptimo.

## 7. Limitaciones
- El resultado depende de la versión y calidad del CSV utilizado.
- La imputación por mediana es un método simple.
- El umbral 0.50 es convencional y afecta el balance entre sensibilidad y especificidad.
- Una única división entrenamiento/prueba puede producir variabilidad; una validación cruzada sería una evaluación adicional recomendable.
- El análisis observacional describe asociaciones, no causas, y no sustituye evaluación o diagnóstico médico.

## 8. Conclusiones
Se ajustaron dos modelos de regresión logística para la variable `TenYearCHD`. El modelo completo obtuvo AUC **[valor real]** y el simplificado AUC **[valor real]** en el conjunto de prueba. Las variables estadísticamente asociadas según el modelo fueron **[variables reales]**. La conclusión sobre cuál modelo funciona mejor debe basarse en las métricas generadas y considerar de manera especial la sensibilidad, especificidad y AUC. Este ejercicio es académico y no es una herramienta de diagnóstico clínico.

## 9. Evidencias
Adjuntar capturas propias de RStudio: carga y exploración, revisión de faltantes, ajuste del modelo, coeficientes, matriz de confusión, curva ROC, modelo simplificado y archivos generados. No usar métricas de ejemplo como si fueran resultados del análisis.
