clc
clear
close all

datos = importfile("C:\Users\Resen\Documents\MATLAB\pendulo\muestras.csv", [2, Inf]);

t = table2array(datos(:, 1));
muestras = table2array(datos(:, 2:end));

t = t(:);

% Filtrar las mediciones
filtradas = medfilt1(muestras, 3);

% Calcular los promedios
muestra_prom = mean(muestras, 2);
muestra_prom_fil = mean(filtradas, 2);



% Gráfica 1: Mediciones originales
figure('Color', 'w')
hold on
h_muestras = plot(t, muestras, ...
    'Color', [0.55 0.55 0.55], 'LineWidth', 0.8);

title('Mediciones originales del ángulo', ...
    'FontSize', 16, 'FontWeight', 'bold')
xlabel('Tiempo (s)', 'FontSize', 14)
ylabel('Ángulo (rad)', 'FontSize', 14)
grid on
box on
set(gca, 'FontSize', 20, 'LineWidth', 1.1)
xlim([min(t), max(t)])


% Gráfica 2: Mediciones filtradas
figure('Color', 'w')
hold on
h_filtradas = plot(t, filtradas, ...
    'Color', [0.55 0.55 0.55], 'LineWidth', 0.8);

title('Mediciones filtradas del ángulo', ...
    'FontSize', 16, 'FontWeight', 'bold')
xlabel('Tiempo (s)', 'FontSize', 14)
ylabel('Ángulo (rad)', 'FontSize', 14)
grid on
box on
set(gca, 'FontSize', 20, 'LineWidth', 1.1)
xlim([min(t), max(t)])


% Gráfica 3: Comparación de promedios
figure('Color', 'w')
hold on

h_original = plot(t, muestra_prom, ...
    'Color', [0.95 0.55 0.30], 'LineWidth', 1.6);

h_filtrado = plot(t, muestra_prom_fil, ...
    'Color', [0.20 0.40 0.70], 'LineWidth', 2);

title('Comparación de las señales promedio', ...
    'FontSize', 16, 'FontWeight', 'bold')
xlabel('Tiempo (s)', 'FontSize', 14)
ylabel('Ángulo promedio (rad)', 'FontSize', 14)
legend([h_original, h_filtrado], ...
    {'Promedio original', 'Promedio filtrado'}, ...
    'Location', 'best', 'FontSize', 12)
grid on
box on
set(gca, 'FontSize', 20, 'LineWidth', 1.1)
xlim([min(t), max(t)])


% Modelo matemático y análisis de la dinámica del péndulo

m = 0.552;
l = 0.21;

% Condiciones iniciales
x0 = 0;
y0 = [muestra_prom_fil(1) 0];

% Función del modelo
model_fcn = @(x, t) pendulo_model(x, t, m, l, y0);

% Optimización del parámetro del modelo
options = optimoptions('lsqcurvefit', 'Display', 'off');

lb = 0.06;
ub = 0.08;

opt = lsqcurvefit(model_fcn, x0, t, muestra_prom_fil, lb, ub, options);

% Respuesta del modelo con el parámetro optimizado
pendulo_opt = pendulo_model(opt, t, m, l, y0);

% Residuos: diferencia entre las mediciones y el modelo
residuos = muestra_prom_fil - pendulo_opt;

% Error cuadrático medio y raíz del error cuadrático medio
mse = benchmark(muestra_prom_fil, pendulo_opt, t).MSE;
rmse = benchmark(muestra_prom_fil, pendulo_opt, t).RMSE;

fprintf('Parámetro optimizado: %.6f\n', opt);
fprintf('Error cuadrático medio (ECM): %.6f\n', mse);
fprintf('Raíz del error cuadrático medio (RECM): %.6f rad\n', rmse);



% Gráfica 4: Comparación entre mediciones y modelo
figure('Color', 'w')
hold on

h_mediciones = plot(t, muestra_prom_fil, ...
    'Color', [0.20 0.40 0.70], 'LineWidth', 1.6);

h_modelo = plot(t, pendulo_opt, ...
    'Color', [0.85 0.55 0.30], 'LineWidth', 2);

title('Ajuste del modelo matemático del péndulo', ...
    'FontSize', 16, 'FontWeight', 'bold')
xlabel('Tiempo (s)', 'FontSize', 14)
ylabel('Ángulo (rad)', 'FontSize', 14)
legend([h_mediciones, h_modelo], ...
    {'Mediciones filtradas', 'Modelo ajustado'}, ...
    'Location', 'best', 'FontSize', 12)
grid on
box on
set(gca, 'FontSize', 20, 'LineWidth', 1.1)
xlim([min(t), max(t)])


% Gráfica 5: Residuos del modelo
figure('Color', 'w')
hold on

h_residuos = plot(t, residuos, ...
    'Color', [0.40 0.55 0.65], 'LineWidth', 1.3);

h_cero = yline(0, '--', ...
    'Color', [0.45 0.45 0.45], 'LineWidth', 1.2);

title('Residuos del ajuste del modelo', ...
    'FontSize', 16, 'FontWeight', 'bold')
xlabel('Tiempo (s)', 'FontSize', 14)
ylabel('Residuo angular (rad)', 'FontSize', 14)
legend([h_residuos, h_cero], ...
    {'Medición - modelo', 'Residuo cero'}, ...
    'Location', 'best', 'FontSize', 12)
grid on
box on
set(gca, 'FontSize', 20, 'LineWidth', 1.1)
xlim([min(t), max(t)])


% Gráfica 6: Espacio de fase
% Estimación numérica de la velocidad angular
vel_angular = gradient(muestra_prom_fil, t);

figure('Color', 'w')
hold on

h_trayectoria = plot(muestra_prom_fil, vel_angular, ...
    'Color', [0.20 0.48 0.43], 'LineWidth', 1.5);

h_inicio = plot(muestra_prom_fil(1), vel_angular(1), 'o', ...
    'MarkerFaceColor', [0.20 0.48 0.43], ...
    'MarkerEdgeColor', [0.15 0.15 0.15], ...
    'MarkerSize', 7);

h_final = plot(muestra_prom_fil(end), vel_angular(end), 's', ...
    'MarkerFaceColor', [0.85 0.55 0.30], ...
    'MarkerEdgeColor', [0.15 0.15 0.15], ...
    'MarkerSize', 7);

title('Espacio de fase del péndulo', ...
    'FontSize', 16, 'FontWeight', 'bold')
xlabel('Ángulo (rad)', 'FontSize', 14)
ylabel('Velocidad angular (rad/s)', 'FontSize', 14)
legend([h_trayectoria, h_inicio, h_final], ...
    {'Trayectoria', 'Estado inicial', 'Estado final'}, ...
    'Location', 'best', 'FontSize', 12)
grid on
box on
set(gca, 'FontSize', 20, 'LineWidth', 1.1)


% BENCHMARK: PROMEDIO FILTRADO CONTRA MODELO OPTIMIZADO
B_pendulo = benchmark(muestra_prom_fil, pendulo_opt, t);

metricas = {'RMSE'; 'MAE'; 'R2'; 'FIT'; 'IAE'};
valores  = [B_pendulo.RMSE; ...
    B_pendulo.MAE; ...
    B_pendulo.R2; ...
    B_pendulo.FIT; ...
    B_pendulo.IAE];

Resultados = table(metricas, valores, ...
    'VariableNames', {'Metrica', 'Modelo_Optimizado'});

disp(' ')
fprintf('Parámetro de fricción optimizado: %.6f\n', opt)
disp('EVALUACIÓN DEL MODELO DEL PÉNDULO (PROMEDIO FILTRADO VS MODELO)')
disp(Resultados)