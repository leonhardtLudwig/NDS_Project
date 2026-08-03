function A = generate_stochastic_matrix(N, type)
    % GENERATE_STOCHASTIC_MATRIX Genera una matrice NxN stocastica.
    %
    % Input:
    %   N    : Dimensione della matrice quadrata (numero di nodi/agenti).
    %   type : Stringa che specifica il tipo di stocasticità.
    %          Opzioni valide: 'row' (default) o 'doubly'.
    %
    % Output:
    %   A    : Matrice generata con le proprietà richieste.

    % Se il tipo non viene specificato, impostiamo 'row' come default
    if nargin < 2
        type = 'row';
    end
    
    % Generiamo una matrice NxN con valori casuali uniformi tra 0 e 1
    % I valori strettamente positivi sono necessari per la convergenza
    A = rand(N);
    
    % Applichiamo la logica in base alla scelta dell'utente
    switch lower(type)
        case {'row', 'row-stochastic'}
            % --- STOCASTICA PER RIGHE ---
            % Dividiamo ogni elemento per la somma della sua rispettiva riga.
            % sum(A, 2) calcola la somma lungo la seconda dimensione (le righe).
            A = A ./ sum(A, 2);
            
        case {'doubly', 'doubly-stochastic'}
            % --- DOPPIAMENTE STOCASTICA ---
            % Utilizziamo l'algoritmo iterativo di Sinkhorn-Knopp
            max_iter = 1000; % Limite di sicurezza per le iterazioni
            tol = 1e-8;      % Tolleranza di convergenza
            
            for iter = 1:max_iter
                % 1. Normalizza le righe
                A = A ./ sum(A, 2);
                
                % 2. Normalizza le colonne
                % sum(A, 1) calcola la somma lungo la prima dimensione (le colonne).
                A = A ./ sum(A, 1);
                
                % 3. Controllo della convergenza
                % Verifichiamo se sia le righe che le colonne sommano a 1 
                % a meno di una tolleranza infinitesima
                err_righe = max(abs(sum(A, 2) - 1));
                err_colonne = max(abs(sum(A, 1) - 1));
                
                if err_righe < tol && err_colonne < tol
                    % Se l'errore è sotto la tolleranza, l'algoritmo è convergente
                    break;
                end
            end
            
            if iter == max_iter
                warning('Algoritmo di Sinkhorn-Knopp fermato al limite di iterazioni. Precisione potrebbe non essere ottimale.');
            end
            
        otherwise
            error('Errore: parametro "type" non valido. Scegli tra ''row'' o ''doubly''.');
    end
end