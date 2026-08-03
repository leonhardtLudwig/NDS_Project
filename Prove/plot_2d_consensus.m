function plot_2d_consensus(trace)
    % PLOT_2D_CONSENSUS Traccia le traiettorie 2D di una rete multi-agente.
    
    % Forza MATLAB a usare sempre la finestra numero 101 e la svuota
    figure(101); 
    clf; 
    set(gcf, 'Name', 'Traiettorie di Consenso 2D', 'Color', 'w');
    
    [N, D, K] = size(trace);
    if D ~= 2
        error('Errore: La traccia deve avere dimensione spaziale D=2 (coordinate x, y).');
    end

    hold on;
    grid on;
    colors = lines(N); 
    h_agents = zeros(N, 1);
    
    for i = 1:N
        agent_path = squeeze(trace(i, :, :)); 
        xi = agent_path(1, :);
        yi = agent_path(2, :);
        
        h_agents(i) = plot(xi, yi, '-', 'LineWidth', 1.5, 'Color', colors(i,:));
        plot(xi(1), yi(1), 'o', 'MarkerSize', 6, 'MarkerFaceColor', 'w', ...
             'MarkerEdgeColor', colors(i,:), 'LineWidth', 1.5);
        plot(xi(end), yi(end), 'x', 'MarkerSize', 10, 'Color', colors(i,:), 'LineWidth', 2.5);
    end
    
    xlabel('Posizione X', 'FontWeight', 'bold');
    ylabel('Posizione Y', 'FontWeight', 'bold');
    title('Evoluzione spaziale della rete multi-agente', 'FontSize', 14);
    axis equal; 
    
    labels = cell(N, 1);
    for i = 1:N
        labels{i} = sprintf('Agente %d', i);
    end
    legend(h_agents, labels, 'Location', 'best', 'FontSize', 10);
    hold off;
end