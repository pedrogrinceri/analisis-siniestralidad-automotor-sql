# Análisis de Siniestralidad Automotor (SQL)

## Resumen
Este proyecto analiza el comportamiento de una cartera simulada de seguros automotor (2014–2019) mediante consultas SQL sobre una base de datos relacional.

El objetivo es evaluar la siniestralidad de la cartera utilizando métricas actuariales clave como exposición, frecuencia, severidad y loss ratio para entender los factores que explican el resultado técnico del negocio.

---

## Problema
Evaluar la rentabilidad técnica de la cartera y responder:

- ¿La prima es suficiente para cubrir el riesgo?
- ¿Qué coberturas presentan mayor siniestralidad?
- ¿Cómo evoluciona el resultado a lo largo de los ejercicios?
- ¿Existen segmentos con peor desempeño?

---

##  Qué se hizo
- Modelado relacional de pólizas, coberturas y siniestros  
- Construcción de base de datos simulada (5 ejercicios contables)  
- Cálculo de métricas actuariales:
  - Exposición (UER)  
  - Frecuencia  
  - Severidad  
  - Loss Ratio  
  - Resultado técnico  
- Análisis por ejercicio, cobertura y segmentaciones  
- Controles de consistencia de datos  

---

## Hallazgos clave
- La cartera presenta resultados cercanos al equilibrio con variaciones entre ejercicios  
- Existen diferencias relevantes entre coberturas en términos de volatilidad  
- Determinados segmentos concentran mayor siniestralidad  
- El resultado técnico se explica principalmente por el comportamiento de la cobertura de Responsabilidad Civil  

---

## Estructura del repositorio
```text
analisis-siniestralidad-automotor-sql/
├── data/
│   └── archivos CSV utilizados para construir la base de datos
├── sql/
│   └── consultas SQL del análisis
├── Analisis_Siniestralidad_Automotor_SQL.pdf
└── README.md    
---

## ▶Cómo correr el proyecto
1. Importar los archivos CSV en una base de datos (MySQL recomendado)  
2. Ejecutar las consultas de la carpeta `sql/`  

---

## Informe completo
El desarrollo completo del análisis se encuentra en:  
`Analisis_Siniestralidad_Automotor_SQL.pdf`

---

## Próximo paso
Versión en Python en desarrollo:  
**Análisis de Siniestralidad REBOOT (Python)**

---

## Nota
Los datos utilizados son simulados y fueron generados con fines educativos.