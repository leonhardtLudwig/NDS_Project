function trace = simulate_consensus(A, x0, K)
    % SIMULATE_CONSENSUS Simula la dinamica di consenso di una rete multi-agente.
    %
    % Input:
    %   A  : Matrice di consenso pesata di dimensione (N, N).
    %   x0 : Condizioni iniziali degli agenti. 
    %        Vettore colonna (N, 1) per stati scalari, o matrice (N, D) per stati D-dimensionali.
    %   K  : Numero di istanti temporali da simulare.
    %
    % Output:
    %   trace : Tensore/Matrice contenente l'evoluzione temporale del sistema.
    %           - Dimensioni (N, K) se lo stato è scalare.
    %           - Dimensioni (N, D, K) se lo stato è multi-dimensionale.

    % Estrazione delle dimensioni
    [N, ~] = size(A);
    
    % Se x0 è un vettore riga, lo forziamo a vettore colonna per sicurezza
    if isvector(x0) && size(x0, 1) == 1
        x0 = x0'; 
    end
    
    [~, D] = size(x0);
    
    % Preallocazione della memoria per l'output (fondamentale in MATLAB per le performance)
    if D == 1
        trace = zeros(N, K);
    else
        trace = zeros(N, D, K);
    end
    
    x_current = x0;
    
    % Ciclo di simulazione
    for k = 1:K
        % Salvataggio dello stato corrente nella traccia
        if D == 1
            trace(:, k) = x_current;
        else
            trace(:, :, k) = x_current;
        end
        
        % Dinamica di aggiornamento vettoriale
        x_current = A * x_current;
    end
end