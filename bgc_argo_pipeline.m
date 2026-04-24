%% ARGOS DATA PIPELINE: Physical & Biogeochemical Processing
% Project: Coastal Monitoring & Data Architecture
% Author: Rafael Rasse Boada
% Version: 2.0 (Optimized for MATLAB/Octave)

clear; close all; clc;

%% 1. INITIALIZATION & DATA INGESTION 
%  INICIALIZACIîN E INGESTA DE DATOS

float_nm = "6901583"; % Float Identifier / Identificador del flotador

% Setup dynamic paths / Configuraci—n de rutas din‡micas
base_dir = pwd; 
din = fullfile(base_dir, 'input', float_nm, 'profiles', 'SD');
dout = fullfile(base_dir, 'output', float_nm, 'processed');

if ~exist(dout, 'dir'), mkdir(dout); end

% List NetCDF files / Listado de archivos NetCDF
file_list = dir(fullfile(din, '*.nc'));
num_files = length(file_list);

% Pre-allocate using cell arrays for memory safety 
% Pre-asignaci—n mediante celdas para seguridad de memoria
all_profiles = cell(num_files, 1);

fprintf('Starting Pipeline for Float: %s\n', float_nm);

%% 2. SIGNAL PROCESSING & NOISE REDUCTION
%  PROCESAMIENTO DE SE„AL Y REDUCCIîN DE RUIDO



for i = 1:num_files
    fn = fullfile(din, file_list(i).name);
    
    % Data Loading / Carga de datos
    tmp = rd_ncread_SO_sector_6901583(fn); 
    
    % Encapsulate in Table for vectorized operations 
    % Encapsulaci—n en Tabla para operaciones vectorizadas
    p = table();
    p.pres = tmp.pres(:);
    p.T = tmp.T(:);
    p.S = tmp.S(:);
    p.chl = tmp.chl_adjust(:);
    p.bbp = tmp.bbp700_adjst(:);
    p.lat = repmat(tmp.lat, height(p), 1);
    p.lon = repmat(tmp.lon, height(p), 1);
    p.time = repmat(tmp.jday + datenum([1950 1 1]), height(p), 1);
    
    % OPTIMIZED SPIKE REMOVAL (Vectorized movmedian)
    % ELIMINACIîN DE PICOS OPTIMIZADA (Mediana m—vil vectorizada)
    % This replaces the slow 'slidefun' loop / Reemplaza el bucle lento de 'slidefun'
    
    p.chl_smooth = movmedian(p.chl, 5, 'omitnan');
    p.chl_spikes = p.chl - p.chl_smooth;
    
    p.bbp_smooth = movmedian(p.bbp, 5, 'omitnan');
    p.bbp_spikes = p.bbp - p.bbp_smooth;

    all_profiles{i} = p;
end

% Merge all profiles into a Master Dataset
% Uni—n de todos los perfiles en un Dataset Maestro
sd = vertcat(all_profiles{:});

%% 3. THERMODYNAMIC INTEGRATION (TEOS-10 Standard)
%  INTEGRACIîN TERMODINçMICA (Est‡ndar TEOS-10)

% Calculate derived physical variables using GSW Library
% C‡lculo de variables f’sicas derivadas usando la librer’a GSW

sd.SA = gsw_SA_from_SP(sd.S, sd.press, sd.lon, sd.lat);   % Absolute Salinity
sd.CT = gsw_CT_from_t(sd.SA, sd.T, sd.press);          % Conservative Temp
sd.sigma0 = gsw_sigma0(sd.SA, sd.CT);                 % Potential Density
sd.spiciness = gsw_spiciness0(sd.SA, sd.CT);          % Water mass analysis

%% 4. FEATURE ENGINEERING: LAYER DETECTION
%  INGENIERêA DE VARIABLES: DETECCIîN DE CAPAS



unique_days = unique(sd.time);
kpi_summary = table();

for d = 1:length(unique_days)
    % Extract single profile / Extraer perfil individual
    idx = sd.time == unique_days(d);
    p_sub = sd(idx, :);
    
    % MIXED LAYER DEPTH (MLD) Calculation
    % C‡lculo de la Profundidad de la Capa de Mezcla
    mld_val = NaN;
    valid_sig = ~isnan(p_sub.sigma0);
    if any(valid_sig)
        mld_val = mld_sigma0(p_sub.pres(valid_sig), p_sub.sigma0(valid_sig), 0.03);
    end
    
    % PRODUCTIVE LAYER DEPTH (Threshold-based)
    % Profundidad de la Capa Productiva (Basada en umbral)
    idx_p = find(p_sub.chl_smooth >= 0.20 & p_sub.pres < 230, 1, 'last');
    z_prod = NaN; 
    if ~isempty(idx_p), z_prod = p_sub.pres(idx_p); end
    
    % Append results / Acumular resultados
    row = table(unique_days(d), p_sub.lat(1), p_sub.lon(1), mld_val, z_prod, ...
          'VariableNames', {'Date', 'Lat', 'Lon', 'MLD', 'Z_Productive'});
    kpi_summary = [kpi_summary; row];
end

%% 5. MULTI-FORMAT DATA EXPORT
%  EXPORTACIîN DE DATOS (Formato .dat Robusto)

% 5.1 Export KPIs Summary as .dat (Tab-separated)
% Exportar Resumen de KPIs en .dat (Separado por tabuladores)
% Usamos fprintf para asegurar precisi—n decimal m‡xima
kpi_fn = fullfile(dout, strcat(float_nm, '_summary_kpi.dat'));
fid = fopen(kpi_fn, 'w');
% Header / Cabecera
fprintf(fid, 'Date_Matlab\tLat\tLon\tMLD\tZ_Productive\n');
% Data / Datos (Controlando decimales: %f)
for r = 1:height(kpi_summary)
    fprintf(fid, '%.5f\t%.4f\t%.4f\t%.2f\t%.2f\n', ...
        kpi_summary.Date(r), kpi_summary.Lat(r), kpi_summary.Lon(r), ...
        kpi_summary.MLD(r), kpi_summary.Z_Productive(r));
end
fclose(fid);

% 5.2 Export XYZ Cleaned Data for Visualization (ASCII .dat)
% Exportar Datos XYZ limpios para visualizaci—n en .dat
% Ideal para ODV, Python o GMT
clean_idx = ~isnan(sd.chl_smooth);
xyz_output = [sd.time(clean_idx), sd.press(clean_idx), sd.chl_smooth(clean_idx)];

% Usamos la extensi—n .dat expl’citamente
fn_xyz = fullfile(dout, strcat(float_nm, '_chl_xyz.dat'));
save(fn_xyz, 'xyz_output', '-ascii');

fprintf('Pipeline Completed Successfully / Pipeline Finalizado con ƒxito\n');
fprintf('Files saved in .dat format for maximum precision.\n');