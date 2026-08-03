% Esempio di utilizzo
N = 15;
m = 14;
K = 10;

% Creiamo una matrice A fittizia (stocastica per righe)
% A = [0, 0.5, 0, 0, 0.5,;
%      0.5, 0, 0.5, 0 0;
%      0, 0.5, 0, 0.5 0;
%      0, 0, 0.5, 0, 0.5;
%      0.5, 0, 0, 0.5, 0];

A = generate_stochastic_matrix(N, 'doubly');

% Condizioni iniziali x, y per i 5 agenti (matrice 5x2)
% x0 = [4.5, 6; 
%       8, 4; 
%       6, 1; 
%       3, 1; 
%       1, 4];

x0 = generate_polygon_positions(N, 15, [5,5]);

% Legge oraria per alpha corretta: 
% Inizia a isolarsi SUBITO nei primi 15 step
alpha_seq = zeros(1, K);
step = 5;
for k = 1:K
    if k <= step
        alpha_seq(k) = (k - 1) / (step-1); % Rampa lineare immediata da 0 a 1
    else
        alpha_seq(k) = 1;            % Dal 16° step in poi è isolato
    end
end

% Simulazione
%trace = simulate_consensus(A, x0, K);
%trace = simulate_dynamic_consensus(x0, alpha_seq);
stubborn_nodes = generate_stubborn_nodes(N, m, 'random');
trace = simulate_dynamic_consensus_general(A, x0, alpha_seq, stubborn_nodes);

plot_2d_consensus(trace);

plot_xy_evolution(trace);

% trace sarà un array 3D di dimensioni 5x2x50