%% MA563 HW2 Solution - Runnable MATLAB Script

clear; close all; clc;

set(0, 'DefaultFigureColor', 'white');
set(0, 'DefaultAxesColor', 'white');
set(0, 'DefaultAxesGridColor', 'k');
set(0, 'DefaultAxesMinorGridColor', 'k');

script_dir = fileparts(mfilename('fullpath'));
figures_dir = fullfile(script_dir, '..', 'figures');
if ~exist(figures_dir, 'dir')
    mkdir(figures_dir);
end

addpath(script_dir);

fprintf('========================================\n');
fprintf('MA563 HW2 - Generating Results\n');
fprintf('========================================\n\n');

%% ========================================================================
% QUESTION 2: Newton Form Implementation
% ========================================================================
fprintf('Question 2: Newton Form Implementation\n');

%% Local Function: dividif (From Textbook Page 342)
function [d] = dividif(x, y)
    [n_rows, m_cols] = size(y);
    if n_rows == 1
        n = m_cols;
    else
        n = n_rows;
    end
    
    n = n - 1;
    d = zeros(n+1, n+1);
    d(:, 1) = y(:); 
    
    for j = 2 : n+1
        for i = j : n+1
            numerator = d(i-1, j-1) - d(i, j-1);
            denominator = x(i-j+1) - x(i);
            d(i, j) = numerator / denominator;
        end
    end
end

x_nodes = [0, 1, 2, 4];
y_vals = [1, 3, 2, 5];

d_table = dividif(x_nodes, y_vals);
n = length(x_nodes);
coeffs = diag(d_table)'; 

x_test = linspace(min(x_nodes), max(x_nodes), 100);
y_newton = newt_polyval(x_nodes, coeffs, x_test);
p_standard = polyfit(x_nodes, y_vals, n-1); 
y_polyfit = polyval(p_standard, x_test);

max_error = max(abs(y_newton - y_polyfit));

fprintf('Comparison Results:\n');
fprintf('-------------------\n');
fprintf('Number of nodes: %d\n', n);
fprintf('Maximum difference between newt_polyval and polyfit: %e\n', max_error);

if max_error < 1e-12
    disp('SUCCESS: The Newton implementation agrees with polyfit.');
else
    disp('WARNING: Large discrepancy detected.');
end

figure('Position', [100, 100, 800, 600]);
set(gcf, 'Color', 'white');
plot(x_nodes, y_vals, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Nodes'); hold on;
plot(x_test, y_newton, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Newton Form');
plot(x_test, y_polyfit, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Matlab polyfit');
legend;
title('Comparison of Interpolation Methods');
xlabel('x'); ylabel('y');
grid on;

saveas(gcf, fullfile(figures_dir, 'Q2_comparison.png'));
fprintf('Saved: Q2_comparison.png\n\n');


%% ========================================================================
% QUESTION 3: Chebyshev Nodes and Runge Phenomenon
% ========================================================================
fprintf('Question 3: Runge Phenomenon and Node Comparison\n');

warning('off', 'MATLAB:polyfit:RepeatedPointsOrRescale');
warning('off', 'MATLAB:polyfit:PolyNotUnique');

runge_f = @(x, a) 1 ./ (1 + a * x.^2);
x_fine = linspace(-1, 1, 1000);

%% Part (a): Divergence test (Equally Spaced Nodes)

N_values = 2:2:40;
error_a1 = zeros(size(N_values));
error_a25 = zeros(size(N_values));

for k = 1:length(N_values)
    n = N_values(k);
    x_nodes = linspace(-1, 1, n);
    
    y_nodes_1 = runge_f(x_nodes, 1);
    p_1 = polyfit(x_nodes, y_nodes_1, n-1);
    y_interp_1 = polyval(p_1, x_fine);
    y_true_1 = runge_f(x_fine, 1);
    error_a1(k) = max(abs(y_interp_1 - y_true_1));
    
    y_nodes_25 = runge_f(x_nodes, 25);
    p_25 = polyfit(x_nodes, y_nodes_25, n-1);
    y_interp_25 = polyval(p_25, x_fine);
    y_true_25 = runge_f(x_fine, 25);
    error_a25(k) = max(abs(y_interp_25 - y_true_25));
end

fprintf('\nPart (a): Numerical Comparison (Equidistant Nodes)\n');
fprintf('---------------------------------------------------\n');
fprintf('n\t\ta=1 Error\t\ta=25 Error\n');
fprintf('---------------------------------------------------\n');
for k = 1:5:length(N_values)
    fprintf('%d\t\t%.2e\t\t%.2e\n', N_values(k), error_a1(k), error_a25(k));
end
fprintf('...\n');
fprintf('%d\t\t%.2e\t\t%.2e\n', N_values(end), error_a1(end), error_a25(end));
fprintf('\n');

figure('Name', 'Part (a): Convergence vs Divergence', 'Position', [100, 100, 800, 600]);
set(gcf, 'Color', 'white');
semilogy(N_values, error_a1, '-o', 'LineWidth', 1.5, 'DisplayName', 'a=1 (Converges)');
hold on;
semilogy(N_values, error_a25, '-x', 'LineWidth', 1.5, 'DisplayName', 'a=25 (Diverges)');
xlabel('Number of Nodes (n)');
ylabel('Max Error (log scale)');
title('Interpolation Error with Equidistant Nodes');
legend;
grid on;
saveas(gcf, fullfile(figures_dir, 'Q3a_runge.png'));
fprintf('Saved: Q3a_runge.png\n');

%% Part (b) & (c): Chebyshev vs. Spline vs. Equidistant (a=25)

N_values_b = 5:5:60;
err_equi = zeros(size(N_values_b));
err_cheb = zeros(size(N_values_b));
err_spline = zeros(size(N_values_b));

for k = 1:length(N_values_b)
    n = N_values_b(k);
    
    x_eq = linspace(-1, 1, n);
    y_eq = runge_f(x_eq, 25);
    [p_eq, ~, mu] = polyfit(x_eq, y_eq, n-1); 
    y_eval_eq = polyval(p_eq, x_fine, [], mu);
    err_equi(k) = max(abs(y_eval_eq - runge_f(x_fine, 25)));
    
    i_idx = 0:n-1;
    x_cheb = cos( pi * (2*i_idx + 1) / (2*n) );
    y_cheb = runge_f(x_cheb, 25);
    [p_cheb, ~, mu_c] = polyfit(x_cheb, y_cheb, n-1);
    y_eval_cheb = polyval(p_cheb, x_fine, [], mu_c);
    err_cheb(k) = max(abs(y_eval_cheb - runge_f(x_fine, 25)));
    
    y_eval_spline = spline(x_eq, y_eq, x_fine);
    err_spline(k) = max(abs(y_eval_spline - runge_f(x_fine, 25)));
end

fprintf('\nPart (b) & (c): Numerical Comparison (a=25)\n');
fprintf('---------------------------------------------------\n');
fprintf('n\t\tEquidistant\t\tChebyshev\t\tCubic Spline\n');
fprintf('---------------------------------------------------\n');
for k = 1:length(N_values_b)
    fprintf('%d\t\t%.2e\t\t%.2e\t\t%.2e\n', N_values_b(k), err_equi(k), err_cheb(k), err_spline(k));
end
fprintf('\n');

n_compare = [10, 20, 30, 40];
fprintf('Improvement Factors (Equidistant vs Others) at specific n:\n');
fprintf('---------------------------------------------------\n');
fprintf('n\t\tChebyshev/Equidistant\t\tSpline/Equidistant\n');
fprintf('---------------------------------------------------\n');
for n_val = n_compare
    idx = find(N_values_b == n_val, 1);
    if ~isempty(idx)
        cheb_improvement = err_equi(idx) / err_cheb(idx);
        spline_improvement = err_equi(idx) / err_spline(idx);
        fprintf('%d\t\t%.2e\t\t\t\t%.2e\n', n_val, cheb_improvement, spline_improvement);
    end
end
fprintf('\n');

figure('Name', 'Part (b): Chebyshev vs Equidistant', 'Position', [100, 100, 800, 600]);
set(gcf, 'Color', 'white');
semilogy(N_values_b, err_equi, 'k--o', 'LineWidth', 1.5, 'MarkerSize', 8, 'DisplayName', 'Equidistant (Diverges)');
hold on;
semilogy(N_values_b, err_cheb, 'b-s', 'LineWidth', 1.5, 'MarkerSize', 8, 'DisplayName', 'Chebyshev (Converges)');
xlabel('Number of Nodes (n)');
ylabel('Max Error (log scale)');
title('Chebyshev vs Equidistant Nodes (Runge Function a=25)');
legend('Location', 'best');
grid on;
saveas(gcf, fullfile(figures_dir, 'Q3b_chebyshev.png'));
fprintf('Saved: Q3b_chebyshev.png\n');

figure('Name', 'Part (c): All Methods Comparison', 'Position', [100, 100, 1000, 600]);
set(gcf, 'Color', 'white');
semilogy(N_values_b, err_equi, 'k--o', 'DisplayName', 'Poly: Equidistant (Diverges)');
hold on;
semilogy(N_values_b, err_cheb, 'b-s', 'LineWidth', 1.5, 'DisplayName', 'Poly: Chebyshev (Converges)');
semilogy(N_values_b, err_spline, 'r-^', 'LineWidth', 1.5, 'DisplayName', 'Cubic Spline: Equidistant (Converges)');
xlabel('Number of Nodes (n)');
ylabel('Max Error (log scale)');
title('Comparison of All Interpolation Methods (Runge Function a=25)');
legend('Location', 'best');
grid on;
saveas(gcf, fullfile(figures_dir, 'Q3c_all_methods.png'));
fprintf('Saved: Q3c_all_methods.png\n');

%% Visualization of the actual oscillation (Example with n=15)
n_demo = 15;
fprintf('\nPart (c): Detailed Comparison at n=%d\n', n_demo);
fprintf('---------------------------------------------------\n');

x_nodes = linspace(-1, 1, n_demo);
y_nodes = runge_f(x_nodes, 25);
p_demo = polyfit(x_nodes, y_nodes, n_demo-1);
y_poly_demo = polyval(p_demo, x_fine);
y_spline_demo = spline(x_nodes, y_nodes, x_fine);

i_idx = 0:n_demo-1;
x_c_nodes = cos(pi*(2*i_idx+1)/(2*n_demo));
y_c_nodes = runge_f(x_c_nodes, 25);
p_c_demo = polyfit(x_c_nodes, y_c_nodes, n_demo-1);
y_cheb_demo = polyval(p_c_demo, x_fine);

y_true = runge_f(x_fine, 25);
err_poly_demo = max(abs(y_poly_demo - y_true));
err_cheb_demo = max(abs(y_cheb_demo - y_true));
err_spline_demo = max(abs(y_spline_demo - y_true));

fprintf('Method\t\t\tMax Error\n');
fprintf('---------------------------------------------------\n');
fprintf('Equidistant Polynomial\t%.2e\n', err_poly_demo);
fprintf('Chebyshev Polynomial\t%.2e\n', err_cheb_demo);
fprintf('Cubic Spline\t\t%.2e\n', err_spline_demo);
fprintf('\n');
fprintf('Improvement over Equidistant:\n');
fprintf('Chebyshev:\t\t%.2e times better\n', err_poly_demo / err_cheb_demo);
fprintf('Cubic Spline:\t\t%.2e times better\n', err_poly_demo / err_spline_demo);
fprintf('\n');

figure('Name', 'Visualizing Runge Phenomenon', 'Position', [100, 100, 1000, 600]);
set(gcf, 'Color', 'white');
plot(x_fine, runge_f(x_fine, 25), 'k-', 'LineWidth', 2, 'DisplayName', 'True Function');
hold on;
plot(x_fine, y_poly_demo, 'm--', 'DisplayName', 'Poly: Equidistant (Oscillates)');
plot(x_fine, y_cheb_demo, 'b-.', 'LineWidth', 1.5, 'DisplayName', 'Poly: Chebyshev');
plot(x_fine, y_spline_demo, 'r:', 'LineWidth', 2, 'DisplayName', 'Cubic Spline');
ylim([-0.5, 1.5]);
xlabel('x'); ylabel('f(x)');
title(['Interpolation with n = ' num2str(n_demo) ' nodes']);
legend;
grid on;
saveas(gcf, fullfile(figures_dir, 'Q3c_spline.png'));
fprintf('Saved: Q3c_spline.png\n\n');

warning('on', 'MATLAB:polyfit:RepeatedPointsOrRescale');
warning('on', 'MATLAB:polyfit:PolyNotUnique');

fprintf('========================================\n');
fprintf('All figures generated successfully!\n');
fprintf('Figures saved to: %s\n', figures_dir);
fprintf('========================================\n');
