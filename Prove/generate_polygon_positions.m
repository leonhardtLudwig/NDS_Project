function x0 = generate_polygon_positions(N, radius, center)
    % GENERATE_POLYGON_POSITIONS Genera le coordinate iniziali (X, Y) per N agenti
    % disponendoli ai vertici di un poligono regolare.
    %
    % Input:
    %   N      : Numero di agenti (vertici del poligono).
    %   radius : (Opzionale) Raggio del cerchio circoscritto. Default: 10.
    %   center : (Opzionale) Vettore [cx, cy] col centro del poligono. Default: [0, 0].
    %
    % Output:
    %   x0     : Matrice (N, 2) contenente le coordinate X e Y.

    % Gestione degli input opzionali
    if nargin < 2
        radius = 10; % Valore di default del raggio
    end
    if nargin < 3
        center = [0, 0]; % Valore di default del centro
    end

    % Gestione del caso limite N=1 (un solo agente, messo al centro)
    if N == 1
        x0 = center;
        return;
    end

    % Creiamo un vettore colonna di N angoli equispaziati.
    % Aggiungiamo pi/2 (90 gradi) come offset per far partire il Nodo 1 in alto.
    theta = (0:N-1)' * (2*pi / N) + (pi / 2);

    % Calcolo vettorializzato delle coordinate tramite trigonometria
    x = center(1) + radius * cos(theta);
    y = center(2) + radius * sin(theta);

    % Assembliamo la matrice finale Nx2
    x0 = [x, y];
end