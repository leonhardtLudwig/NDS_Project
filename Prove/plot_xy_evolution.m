function plot_xy_evolution(trace)
    % PLOT_XY_EVOLUTION Traccia l'evoluzione temporale delle coordinate X e Y.
    
    % Forza MATLAB a usare sempre la finestra numero 102 e la svuota
    figure(102); 
    clf; 
    set(gcf, 'Name', 'Evoluzione Temporale Coordinate X e Y', 'Color', 'w');

    [N, D, K] = size(trace);
    if D ~= 2
        error('Errore: La traccia deve avere dimensione spaziale D=2 (coordinate x, y).');
    end

    time = 1:K;
    colors = lines(N); 
    labels = cell(N, 1);
    for i = 1:N
        labels{i} = sprintf('Agente %d', i);
    end
    
    % SUBPLOT SUPERIORE: Coordinata X
    subplot(2, 1, 1);
    hold on;
    grid on;
    h_agents_x = zeros(N, 1);
    for i = 1:N
        xi_traj = squeeze(trace(i, 1, :)); 
        h_agents_x(i) = plot(time, xi_traj, '-', 'LineWidth', 1.5, 'Color', colors(i,:));
    end
    title('Evoluzione temporale della coordinata X', 'FontSize', 12);
    ylabel('Posizione X', 'FontWeight', 'bold');
    xlim([1 K]);
    legend(h_agents_x, labels, 'Location', 'best', 'FontSize', 10);
    hold off;
    
    % SUBPLOT INFERIORE: Coordinata Y
    subplot(2, 1, 2);
    hold on;
    grid on;
    for i = 1:N
        yi_traj = squeeze(trace(i, 2, :)); 
        plot(time, yi_traj, '-', 'LineWidth', 1.5, 'Color', colors(i,:));
    end
    title('Evoluzione temporale della coordinata Y', 'FontSize', 12);
    xlabel('Istante temporale (k)', 'FontWeight', 'bold');
    ylabel('Posizione Y', 'FontWeight', 'bold');
    xlim([1 K]);
    hold off;
end