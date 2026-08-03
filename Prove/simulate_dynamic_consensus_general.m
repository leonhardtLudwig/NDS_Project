function trace = simulate_dynamic_consensus_general(A_nom, x0, alpha_seq, stubborn_nodes)
    % SIMULATE_DYNAMIC_CONSENSUS_GENERAL Simula la dinamica con matrice time-varying.
    % I nodi specificati si isolano progressivamente in base al parametro alpha.
    %
    % Input:
    %   A_nom          : Matrice di consenso nominale (N x N) ad alpha = 0.
    %   x0             : Condizioni iniziali. Matrice (N, D) o vettore (N, 1).
    %   alpha_seq      : Vettore di lunghezza K con i valori di alpha nel tempo.
    %   stubborn_nodes : Vettore con gli indici dei nodi che diventano stubborn (es. [1]).
    %
    % Output:
    %   trace : Tensore (N, D, K) con l'evoluzione temporale.

    % --- Controlli dimensionali ---
    [N, N_cols] = size(A_nom);
    if N ~= N_cols
        error('Errore: La matrice nominale A_nom deve essere quadrata.');
    end
    
    if isvector(x0) && size(x0, 1) == 1
        x0 = x0'; 
    end
    
    [N_x, D] = size(x0);
    if N_x ~= N
        error('Errore: Le righe di x0 devono corrispondere al numero di nodi in A_nom.');
    end
    
    K = length(alpha_seq);
    
    % --- Preallocazione ---
    if D == 1
        trace = zeros(N, K);
    else
        trace = zeros(N, D, K);
    end
    
    x_current = x0;
    
    % Identifichiamo i nodi regolari (non stubborn)
    regular_nodes = setdiff(1:N, stubborn_nodes);
    
    % --- Ciclo di simulazione ---
    for k = 1:K
        % 1. Salvataggio stato
        if D == 1
            trace(:, k) = x_current;
        else
            trace(:, :, k) = x_current;
        end
        
        alpha = alpha_seq(k);
        A_k = A_nom; % Partiamo dalla matrice base per poi modificarla
        
        % 2. Aggiornamento dinamico dei pesi per i nodi Stubborn
        for i = 1:length(stubborn_nodes)
            s = stubborn_nodes(i);
            % Il nodo stubborn smette di ascoltare gli altri
            A_k(s, :) = (1 - alpha) * A_nom(s, :);
            % Il nodo stubborn ascolta sempre di più solo se stesso
            A_k(s, s) = A_k(s, s) + alpha; 
        end
        
        % 3. Aggiornamento dinamico per i nodi Regolari
        for i = 1:length(regular_nodes)
            r = regular_nodes(i);
            
            % Calcoliamo quanto peso questo nodo sta "perdendo" 
            % a causa dell'isolamento dei nodi stubborn
            lost_weight = 0;
            for j = 1:length(stubborn_nodes)
                s = stubborn_nodes(j);
                % Riduciamo il peso verso il nodo stubborn
                peso_perso = alpha * A_nom(r, s);
                A_k(r, s) = A_nom(r, s) - peso_perso;
                
                lost_weight = lost_weight + peso_perso;
            end
            
            % Il peso perso viene riassegnato all'auto-anello (inerzia)
            % per garantire che la somma della riga rimanga esattamente 1.
            A_k(r, r) = A_k(r, r) + lost_weight;
        end
        
        % 4. Evoluzione dello stato
        x_current = A_k * x_current;
    end
end