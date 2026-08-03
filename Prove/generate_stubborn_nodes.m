function stubborn_nodes = generate_stubborn_nodes(N, m, method)
    % GENERATE_STUBBORN_NODES Seleziona m nodi stubborn da una rete di N agenti.
    %
    % Input:
    %   N      : Numero totale di nodi nella rete.
    %   m      : Numero di nodi che devono diventare stubborn.
    %   method : (Opzionale) 'random' per selezione casuale, 'first' per i primi m nodi.
    %            Default: 'random'.
    %
    % Output:
    %   stubborn_nodes : Vettore riga contenente gli indici dei nodi isolati.

    % Gestione dei parametri opzionali
    if nargin < 3
        method = 'random';
    end

    % Controllo di coerenza
    if m > N
        error('Errore: Il numero di nodi stubborn (m) non può superare il numero totale di agenti (N).');
    end
    if m < 0
        error('Errore: m deve essere maggiore o uguale a zero.');
    end
    if m == 0
        stubborn_nodes = [];
        return;
    end

    % Selezione dei nodi
    switch lower(method)
        case 'random'
            % randperm(N, m) estrae m interi univoci tra 1 e N
            % sort() li ordina per comodità di lettura
            stubborn_nodes = sort(randperm(N, m));
            
        case 'first'
            % Seleziona deterministicamente i primi m nodi
            stubborn_nodes = 1:m;
            
        otherwise
            error('Errore: Metodo non valido. Scegli tra ''random'' o ''first''.');
    end
end