function trace = simulate_dynamic_consensus(x0, alpha_seq)
    % SIMULATE_DYNAMIC_CONSENSUS Simula la dinamica con matrice time-varying
    % parametrizzata dal valore alpha per l'isolamento del nodo 1.
    %
    % Input:
    %   x0        : Condizioni iniziali. Matrice (5, D) o vettore (5, 1).
    %   alpha_seq : Vettore riga o colonna di lunghezza K contenente i 
    %               valori di alpha per ogni istante di simulazione.
    %               alpha = 0 -> Rete ad anello completa
    %               alpha = 1 -> Nodo 1 isolato (stubborn), anello tra 2-3-4-5
    %
    % Output:
    %   trace : Tensore (5, D, K) con l'evoluzione temporale.

    % Controllo sulle dimensioni di input
    if isvector(x0) && size(x0, 1) == 1
        x0 = x0'; 
    end
    
    [N, D] = size(x0);
    if N ~= 5
        error('Errore: Questa matrice parametrizzata è definita strettamente per N=5 nodi.');
    end
    
    K = length(alpha_seq);
    
    % Preallocazione della memoria
    if D == 1
        trace = zeros(N, K);
    else
        trace = zeros(N, D, K);
    end
    
    x_current = x0;
    
    % Ciclo di simulazione
    for k = 1:K
        % 1. Salvataggio dello stato corrente
        if D == 1
            trace(:, k) = x_current;
        else
            trace(:, :, k) = x_current;
        end
        
        % 2. Estrazione del parametro alpha per l'istante corrente
        alpha = alpha_seq(k);
        
        % 3. Costruzione della matrice A(alpha)
        A_alpha = [
            alpha,         (1-alpha)/2, 0,   0,   (1-alpha)/2;
            (1-alpha)/2,   0,           0.5, 0,   alpha/2;
            0,             0.5,         0,   0.5, 0;
            0,             0,           0.5, 0,   0.5;
            (1-alpha)/2,   alpha/2,     0,   0.5, 0
        ];
        
        % 4. Aggiornamento dinamico
        x_current = A_alpha * x_current;
    end
end