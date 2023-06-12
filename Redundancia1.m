clc

% Crear una matriz de datos de ejemplo
data = rand(10, 4); %(filas, columnas)
disp(data);

% Reservar espacio para los resultados
sums = zeros(1, size(data, 1));

% Configurar el número de hilos
numThreads = 4;

% Verificar si hay un pool de trabajadores abierto, si no lo hay, crear uno con el número de hilos indicado
if isempty(gcp('nocreate'))
    parpool(numThreads);
end

% Ejecutar cálculos en paralelo utilizando parfor
parfor i = 1:size(data, 1)
    try
        % Simular un fallo en un hilo específico (por ejemplo, el hilo 2)
        if i == 25 %|| 8
            error('Simulated failure in current thread');
        end

        % Calcular la suma de la fila i
        sums(i) = sum(data(i, :));
    catch err
        % Manejar la excepción (en este caso, simplemente mostrar un mensaje de error)
        disp(['Error en el ciclo ', num2str(i), ': ', err.message,'-> ',  num2str(getCurrentTask().ID)]);
    end
end

% Mostrar los resultados
disp(sums);

%Elimina el pool de threads creado
delete(gcp('nocreate'));
