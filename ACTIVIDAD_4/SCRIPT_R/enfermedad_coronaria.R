############################################################
# ACTIVIDAD 4: PROBLEMA DE REGRESIÓN LOGÍSTICA
# Predicción de enfermedad coronaria a 10 años - Framingham
# Estudiante: Bertha Delmira Mero Castro
############################################################

# Instalar paquetes solo si no están disponibles.
paquetes <- c("ggplot2", "pROC")
por_instalar <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
if (length(por_instalar) > 0) {
  install.packages(por_instalar, repos = "https://cloud.r-project.org")
}
library(ggplot2)
library(pROC)

# Localizar el CSV en DATASET/ o en la raíz del repositorio.
archivos_csv <- c(
  "DATASET/enfermedad_coronaria (1).csv",
  "DATASET/enfermedad_coronaria.csv",
  "enfermedad_coronaria (1).csv",
  "enfermedad_coronaria.csv"
)
ruta_csv <- archivos_csv[file.exists(archivos_csv)][1]
if (is.na(ruta_csv)) {
  stop("No se encontró el CSV. Guarda enfermedad_coronaria.csv en DATASET/ o en la raíz.")
}

# Crear carpeta de salida.
if (!dir.exists("RESULTADOS")) dir.create("RESULTADOS", recursive = TRUE)

# Leer datos; NA y celdas vacías se consideran faltantes.
datos_originales <- read.csv(
  ruta_csv,
  na.strings = c("NA", "", " "),
  stringsAsFactors = FALSE,
  check.names = FALSE
)
cat("Archivo:", ruta_csv, "\n")
cat("Dimensiones:", dim(datos_originales), "\n")
cat("\nPrimeras filas:\n")
print(head(datos_originales))
cat("\nEstructura:\n")
str(datos_originales)
cat("\nResumen:\n")
print(summary(datos_originales))

# Variables indicadas en la consigna. education se excluye porque no está
# en la lista de predictores del enunciado.
objetivo <- "TenYearCHD"
predictoras <- c(
  "male", "age", "currentSmoker", "cigsPerDay", "BPMeds",
  "prevalentStroke", "prevalentHyp", "diabetes", "totChol",
  "sysBP", "diaBP", "BMI", "heartRate", "glucose"
)
requeridas <- c(objetivo, predictoras)
no_encontradas <- setdiff(requeridas, names(datos_originales))
if (length(no_encontradas) > 0) {
  stop(paste("Faltan columnas:", paste(no_encontradas, collapse = ", ")))
}

datos <- datos_originales[, requeridas]
for (v in requeridas) {
  datos[[v]] <- suppressWarnings(as.numeric(as.character(datos[[v]])))
}
# No se puede entrenar/evaluar observaciones sin respuesta conocida.
datos <- datos[!is.na(datos[[objetivo]]), ]
if (!all(datos[[objetivo]] %in% c(0, 1))) stop("TenYearCHD debe contener 0 y 1.")

# Resumen de datos faltantes y distribución de la respuesta.
faltantes <- data.frame(
  Variable = names(datos),
  Cantidad_NA = colSums(is.na(datos)),
  Porcentaje_NA = round(100 * colMeans(is.na(datos)), 2)
)
write.csv(faltantes, "RESULTADOS/valores_faltantes.csv", row.names = FALSE)
distribucion <- as.data.frame(table(TenYearCHD = datos[[objetivo]]))
names(distribucion) <- c("TenYearCHD", "Frecuencia")
distribucion$Porcentaje <- round(100 * distribucion$Frecuencia / sum(distribucion$Frecuencia), 2)
write.csv(distribucion, "RESULTADOS/distribucion_objetivo.csv", row.names = FALSE)
cat("\nFaltantes por variable:\n")
print(faltantes)
cat("\nDistribución de TenYearCHD:\n")
print(distribucion)

# División estratificada 80/20 para conservar proporciones de clase.
set.seed(123)
indices_train <- unlist(lapply(split(seq_len(nrow(datos)), datos[[objetivo]]), function(ids) {
  sample(ids, size = max(1, floor(0.80 * length(ids))))
}))
indices_train <- sort(indices_train)
train <- datos[indices_train, , drop = FALSE]
test <- datos[-indices_train, , drop = FALSE]
if (length(unique(train[[objetivo]])) < 2 || length(unique(test[[objetivo]])) < 2) {
  stop("Train y test deben contener las dos clases; revisa la distribución de TenYearCHD.")
}

# Imputar con medianas calculadas solamente en entrenamiento.
medianas <- sapply(predictoras, function(v) median(train[[v]], na.rm = TRUE))
medianas[!is.finite(medianas)] <- 0
for (v in predictoras) {
  train[[v]][is.na(train[[v]])] <- medianas[[v]]
  test[[v]][is.na(test[[v]])] <- medianas[[v]]
}

# Ajustar el modelo completo.
formula_full <- as.formula(paste(objetivo, "~", paste(predictoras, collapse = " + ")))
modelo_completo <- glm(formula_full, data = train, family = binomial(link = "logit"))
cat("\nResumen del modelo completo:\n")
print(summary(modelo_completo))

# Coeficientes, p-valores, odds ratios e intervalos Wald del 95%.
co <- summary(modelo_completo)$coefficients
co <- co[rownames(co) != "(Intercept)", , drop = FALSE]
tabla_co <- data.frame(
  Variable = rownames(co),
  Coeficiente = co[, "Estimate"],
  Error_estandar = co[, "Std. Error"],
  Estadistico_z = co[, "z value"],
  Valor_p = co[, "Pr(>|z|)"],
  Odds_ratio = exp(co[, "Estimate"]),
  OR_IC95_inferior = exp(co[, "Estimate"] - 1.96 * co[, "Std. Error"]),
  OR_IC95_superior = exp(co[, "Estimate"] + 1.96 * co[, "Std. Error"])
)
tabla_co$Significativa_p_menor_005 <- tabla_co$Valor_p < 0.05
tabla_co <- tabla_co[order(tabla_co$Valor_p), ]
write.csv(tabla_co, "RESULTADOS/coeficientes_modelo.csv", row.names = FALSE)
cat("\nCoeficientes ordenados por valor p:\n")
print(tabla_co)

# Métricas para cualquier modelo, con umbral de clasificación 0.50.
evaluar <- function(modelo, datos_test, nombre) {
  prob <- predict(modelo, newdata = datos_test, type = "response")
  pred <- factor(ifelse(prob >= 0.50, 1, 0), levels = c(0, 1))
  real <- factor(datos_test[[objetivo]], levels = c(0, 1))
  cm <- table(Prediccion = pred, Real = real)
  tn <- as.numeric(cm["0", "0"]); fn <- as.numeric(cm["0", "1"])
  fp <- as.numeric(cm["1", "0"]); tp <- as.numeric(cm["1", "1"])
  ratio <- function(a, b) if (b == 0) NA_real_ else a / b
  accuracy <- ratio(tp + tn, sum(cm))
  precision <- ratio(tp, tp + fp)
  recall <- ratio(tp, tp + fn)
  specificity <- ratio(tn, tn + fp)
  f1 <- if (is.na(precision) || is.na(recall) || precision + recall == 0) NA_real_ else 2 * precision * recall / (precision + recall)
  roc_obj <- pROC::roc(real, prob, levels = c("0", "1"), direction = "<", quiet = TRUE)
  metricas <- data.frame(
    Modelo = nombre, Umbral = 0.50, Accuracy = accuracy,
    Precision = precision, Recall = recall, Specificity = specificity,
    F1_Score = f1, AUC = as.numeric(pROC::auc(roc_obj))
  )
  list(metricas = metricas, matriz = cm, prob = prob, roc = roc_obj)
}

res_full <- evaluar(modelo_completo, test, "Completo")

# Selección de dos variables con menor p-valor en train para el modelo didáctico simplificado.
variables_p <- names(sort(co[, "Pr(>|z|)"]))
variables_simplificadas <- head(variables_p, 2)
formula_simple <- as.formula(paste(objetivo, "~", paste(variables_simplificadas, collapse = " + ")))
modelo_simplificado <- glm(formula_simple, data = train, family = binomial(link = "logit"))
cat("\nVariables del modelo simplificado:", paste(variables_simplificadas, collapse = ", "), "\n")
print(summary(modelo_simplificado))
res_simple <- evaluar(modelo_simplificado, test, "Simplificado")

# Exportar métricas, comparación y matrices.
metricas <- rbind(res_full$metricas, res_simple$metricas)
write.csv(metricas, "RESULTADOS/metricas_modelo.csv", row.names = FALSE)
comparacion <- metricas[, c("Modelo", "AUC")]
write.csv(comparacion, "RESULTADOS/comparacion_modelos.csv", row.names = FALSE)
sink("RESULTADOS/matriz_confusion.txt")
cat("MATRIZ DE CONFUSIÓN - MODELO COMPLETO\nFilas=predicción; columnas=observado\n")
print(res_full$matriz)
cat("\nMÉTRICAS\n"); print(res_full$metricas)
cat("\nMATRIZ DE CONFUSIÓN - MODELO SIMPLIFICADO\n")
print(res_simple$matriz)
cat("\nMÉTRICAS\n"); print(res_simple$metricas)
sink()

# Curvas ROC de ambos modelos.
roc_df <- rbind(
  data.frame(FPR = 1 - res_full$roc$specificities, Sensibilidad = res_full$roc$sensitivities, Modelo = "Completo"),
  data.frame(FPR = 1 - res_simple$roc$specificities, Sensibilidad = res_simple$roc$sensitivities, Modelo = "Simplificado")
)
g_roc <- ggplot(roc_df, aes(FPR, Sensibilidad, color = Modelo)) +
  geom_line(linewidth = 1) + geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  coord_equal() + labs(title = "Curvas ROC", x = "1 - Especificidad", y = "Sensibilidad") + theme_minimal()
ggsave("RESULTADOS/curva_ROC.png", g_roc, width = 8, height = 6, dpi = 300)

# Gráfico de coeficientes.
g_coef <- ggplot(tabla_co, aes(x = reorder(Variable, Coeficiente), y = Coeficiente, fill = Significativa_p_menor_005)) +
  geom_col() + coord_flip() + labs(title = "Coeficientes del modelo completo", x = "Variable", y = "Coeficiente", fill = "p < 0.05") +
  theme_minimal()
ggsave("RESULTADOS/coeficientes_modelo.png", g_coef, width = 8, height = 7, dpi = 300)

# Comparación visual de AUC.
g_auc <- ggplot(comparacion, aes(Modelo, AUC, fill = Modelo)) +
  geom_col(width = 0.6) + coord_cartesian(ylim = c(0, 1)) +
  labs(title = "Comparación del AUC", y = "AUC") + theme_minimal() + theme(legend.position = "none")
ggsave("RESULTADOS/comparacion_modelos.png", g_auc, width = 7, height = 5, dpi = 300)

# Gráfico de la matriz de confusión del modelo completo.
cm_df <- as.data.frame(res_full$matriz)
g_cm <- ggplot(cm_df, aes(Real, Prediccion, fill = Freq)) + geom_tile(color = "white") +
  geom_text(aes(label = Freq), size = 6) + scale_fill_gradient(low = "white", high = "steelblue") +
  labs(title = "Matriz de confusión - modelo completo", x = "Observado", y = "Predicho") + theme_minimal()
ggsave("RESULTADOS/matriz_confusion.png", g_cm, width = 7, height = 5, dpi = 300)

cat("\nAnálisis terminado. Revisa la carpeta RESULTADOS/.\n")
