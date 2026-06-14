# Predicción de Enfermedad Coronaria a 10 Años mediante Regresión Logística

## Información General

**Estudiante:** Bertha Delmira Mero Castro

**Asignatura:** Analítica de Datos

**Actividad:** Predicción de Enfermedad Coronaria mediante Regresión Logística

## Descripción del Problema

La Organización Mundial de la Salud estima que millones de personas fallecen cada año debido a enfermedades cardiovasculares. El diagnóstico temprano permite identificar pacientes de alto riesgo y aplicar medidas preventivas oportunas.

Este proyecto utiliza el conjunto de datos del estudio Framingham para predecir si una persona desarrollará enfermedad coronaria en los próximos 10 años mediante un modelo de regresión logística.

## Objetivo General

Desarrollar un modelo predictivo capaz de estimar el riesgo de enfermedad coronaria a 10 años utilizando variables demográficas, conductuales y médicas.

## Variables del Dataset

### Datos Demográficos
- Sexo
- Edad

### Factores Conductuales
- Fumador actual
- Cigarrillos por día

### Antecedentes Médicos
- Medicamentos para presión arterial
- Accidente cerebrovascular previo
- Hipertensión
- Diabetes

### Datos Médicos Actuales
- Colesterol total
- Presión arterial sistólica
- Presión arterial diastólica
- Índice de masa corporal (IMC)
- Frecuencia cardíaca
- Glucosa

### Variable Objetivo
- Riesgo de enfermedad coronaria a 10 años
  - 0 = No
  - 1 = Sí

## Tecnologías Utilizadas

- R Studio Desktop
- Lenguaje R
- tidyverse
- caret
- pROC
- ggplot2

## Metodología

### 1. Preprocesamiento
- Carga de librerías.
- Importación del dataset.
- Exploración de datos.
- Tratamiento de valores faltantes.
- Conversión de la variable objetivo a factor.

### 2. Construcción del Modelo
- División de datos en entrenamiento y prueba.
- Regresión logística utilizando glm().
- Evaluación de coeficientes.

### 3. Evaluación
- Matriz de confusión.
- Accuracy.
- Precision.
- Recall.
- Specificity.
