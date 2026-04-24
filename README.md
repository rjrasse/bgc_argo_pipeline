# BGC-Argo Open Ocean Data Pipeline  
## Pipeline de procesamiento de datos para observaciones oceánicas autónomas

---

## System architecture

```text
NetCDF profiles (BGC-Argo floats)
        |
        v
MATLAB ingestion layer
  - rd_ncread_*.m

        |
        v
Data processing pipeline
  - argos_pipeline.m
  - quality control
  - TEOS-10 calculations
  - feature extraction

        |
        v
Scientific core functions
  - mld_sigma0.m (mixed layer depth)

        |
        v
Outputs (.dat files)
  - KPIs
  - cleaned profiles

        |
        v
Python visualization
  - multi-panel plots
```
  
---

## Overview / Resumen

This repository contains a data processing pipeline for BGC-Argo float profiles used in oceanographic monitoring.  
Este repositorio contiene un pipeline de procesamiento de datos para perfiles de flotadores BGC-Argo utilizados en monitoreo oceanográfico.

It processes raw NetCDF profiles and produces cleaned datasets ready for analysis.  
Procesa perfiles NetCDF en bruto y genera datasets limpios listos para análisis.

The workflow is designed for repeated processing of large sets of float observations.  
El flujo de trabajo está diseñado para el procesamiento repetitivo de grandes volúmenes de observaciones de flotadores.

---

## Problem context / Contexto del problema

BGC-Argo floats generate high volumes of vertical ocean profiles combining physical and biogeochemical variables.  
Los flotadores BGC-Argo generan grandes volúmenes de perfiles verticales que combinan variables físicas y biogeoquímicas.

Raw datasets present challenges such as:
- sensor noise  
- irregular sampling  
- missing values  
- variability in data quality  

Los datos en bruto presentan problemas como ruido en sensores, muestreo irregular, valores faltantes y variabilidad en la calidad de los datos.

This pipeline standardizes and cleans these datasets for consistent analysis.  
Este pipeline estandariza y limpia los datos para garantizar análisis consistentes.

---

## Pipeline structure / Estructura del pipeline

```text
NetCDF input
    ↓
Data ingestion
    ↓
Quality control
    ↓
Signal processing
    ↓
Feature extraction
    ↓
KPI generation
    ↓
Export (.dat files)
```

---

## Tech stack / Tecnologías

- MATLAB / Octave  
- NetCDF format  
- TEOS-10 (GSW toolbox)  
- Tabular data processing  

---

## Key processing steps / Etapas principales

### 1. Data ingestion / Ingesta de datos
Reads raw NetCDF profiles and structures them into tabular format.  
Lee perfiles NetCDF en bruto y los estructura en formato tabular.

### 2. Signal processing / Procesamiento de señal
Removes spikes in optical variables using vectorized filtering.  
Elimina picos en variables ópticas mediante filtrado vectorizado.

### 3. Physical transformations / Transformaciones físicas
Computes derived oceanographic variables using TEOS-10.  
Calcula variables oceanográficas derivadas usando TEOS-10.

### 4. Feature extraction / Extracción de variables

This step derives key vertical structure variables from cleaned ocean profiles.

Esta etapa deriva variables clave de estructura vertical a partir de perfiles oceánicos ya depurados.

The goal is to characterize the physical and biogeochemical structure of the water column.

El objetivo es caracterizar la estructura física y biogeoquímica de la columna de agua.

---

Extracted variables include:

Variables extraídas:

- Mixed Layer Depth (MLD)
- Productive Layer Depth (PLD)

---

## KPI generation / Generación de indicadores

These features are transformed into operational oceanographic KPIs that support downstream environmental and climate analytics.

Estas variables se transforman en indicadores oceanográficos operativos que soportan análisis ambientales y climáticos posteriores.

### Physical KPI / KPI físico
- Mixed Layer Depth (MLD)  
  Derived from density threshold (σθ)  
  Indicador de estratificación vertical del océano  

### Biogeochemical KPI / KPI biogeoquímico
- Productive Layer Depth (PLD)  
  Derived from chlorophyll-a vertical structure  
  Indicador de productividad biológica  

These KPIs provide interpretable metrics for ocean state characterization and ecosystem variability.

Estos indicadores proporcionan métricas interpretables para la caracterización del estado del océano y la variabilidad del ecosistema.

---

## Outputs / Resultados

- Clean KPI tables / tablas de indicadores limpias  
- Processed profiles / perfiles procesados  
- Exported `.dat` files for downstream analysis  

---

## How to run / Ejecución

- Place NetCDF files in `input/`  
  Colocar los archivos NetCDF en `input/`

- Run main MATLAB script  
  Ejecutar el script principal en MATLAB

- Outputs are saved in `output/`  
  Los resultados se guardan en `output/`

---

## Notes / Notas

- Designed for batch processing of ocean float data  
  Diseñado para procesamiento en lote  

- Reproducible workflow  
  Flujo de trabajo reproducible  

- Optimized for vectorized computation in MATLAB  
  Optimizado para cálculo vectorizado  

---
## Why this matters / Relevancia

Processing environmental data at scale requires robust, reproducible pipelines.

This project demonstrates:
- Handling of heterogeneous scientific datasets  
- Automation of data workflows  
- Generation of consistent indicators from raw observations  

Este proyecto muestra cómo transformar datos complejos en información estructurada lista para análisis y toma de decisiones.

---


## Repository structure

```text
data/
outputs/
scripts/
argos_pipeline.m
mld_sigma0.m
rd_ncread_*.m
README.md

---

## Author / Autor

Rafael Rasse, PhD  
Data Science & Ocean Data Systems  
Ciencia de datos y sistemas de observación oceánica  