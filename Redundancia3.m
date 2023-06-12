clc
% Crear una matriz de datos de ejemplo
data = rand(10, 5);
disp(data);

% Reservar espacio para los resultados
sums = zeros(1, size(data, 1));

% Configurar el número de hilos y nodos de respaldo
numThreads = 4;
%numBackupNodes = numThreads/2;
if isempty(gcp('nocreate'))
    parpool(numThreads);
end

% Crear una copia de los datos para la replicación
dataCopy = data;

% Crear una matriz para almacenar el estado de los hilos (1 = exitoso, 0 = fallido)
threadStatus = ones(1, numThreads);

%Crear una matriz para almacenar los ciclos fallidos (1 = completado, 0 = vacio)
errorCycles = zeros(1, size(data, 1));

% Variable para almacenar el hilo que encontró el error
failedThread = -1;

%Bandera para ejecutar solo la primera vez del ciclo while
flagDo = -1;

%Dentro de un ciclo while hasta que no haya fallos.
endProcess = 0;
while endProcess == 0

    % Ejecutar cálculos en paralelo utilizando parfor
    parfor i = 1:size(data, 1)
        try
            %Si aun no se completa este ciclo:
            if errorCycles(i) == 0
                
                % Simular un fallo en un hilo específico (por ejemplo, el hilo 2)
                if getCurrentTask().ID == 2 && flagDo == -1
                    error('Simulated failure in thread: ');
                end

                % Seleccionar la matriz de datos según el índice del hilo
                if mod(i, 2) == 0
                    dataToUse = data;
                else
                    dataToUse = dataCopy;
                end

                % Calcular la suma de la fila i
                sums(i) = sum(dataToUse(i, :));

                %Indica que se ha llenado este ciclo
                errorCycles(i) = 1;

            end

        catch err
            % Si ocurre un error, marcar el hilo como fallido y almacenar el hilo y ciclo donde se encontró el error
            %threadStatus(currentTask.ID) = 0;
            disp(['Error en el ciclo ', num2str(i), ': ', err.message, num2str(getCurrentTask().ID)]);
            errorCycles(i) = 0;
            %failedThread = currentTask.ID;
        end
    end
    disp(errorCycles);
    %Indica que ya pasó la primera vez
    flagDo = 1;
    if ~any(errorCycles == 0)
        disp('NO HAY MAS ERRORES');
        endProcess = 1;
    end
end

% Mostrar los resultados
disp(sums);
%Elimina el pool de threads creado
%delete(gcp('nocreate'));
