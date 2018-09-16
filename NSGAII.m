function [ solucion, fo1, fo2 ] = NSGAII( poblacion,generaciones )
%% NSGAII Introducci�n

%% Verificaci�n de par�metros del modelo
%===========================================================================
if nargin < 2
    error('NSGA-II: Por favor, Ingrese el tama�o de la poblaci�n y el n�mero de generaciones como argumentos de entrada.');
end
% Tipo de argumentos (num�ricos)
if isnumeric(poblacion) == 0 || isnumeric(generaciones) == 0
    error('Ambos argumentos de entrada Pobalaci�n (pop) y N�mero de generaciones (gen) deben ser de tipo entero');
end
% El tama�o m�nimo de la poblaci�n debe ser de 20 individuos
if poblacion < 20
    error('El tama�o m�nimo de la poblaci�n debe ser de 20 individuos');
end
% La cantidad m�nima de generaciones es de 5
if generaciones < 5
    error('La cantidad m�nima de generaciones es de 5');
end

if isinteger(poblacion) == 0 || isinteger(generaciones)==0
    fprintf('Los valores deben ser enteros y, por tanto, para evitar errores son redondeados al entero inferior')
    % Verificar que las entradas son enteras, a partir de un redondeo
    poblacion = round(poblacion);
    generaciones = round(generaciones);
end
%%
% Carga de la funci�n objetivo
%===========================================================================
% La funci�n denominada "funcion_objetivo", es un gui�n editable en el cual
% se definen las dos funciones objetivo bajo estudio, as� mismo, la
% cantidad de variables y par�metros del modelo como: N�mero de periodos,
% cantidad de Lotes, Cantidad de productos, n�mero de variables de
% decisi�n, cantidad de restricciones, etc. Teniendo en cuenta la
% estructura del modelo, los par�metros son obtenidos a partir de de unos
% datos almacenados en un archivo .data
[ cant_objetivos, cant_variables, limite_inferior, limite_superior, ...
    funcion_1, funcion_2, cant_periodos ,cant_productos, cant_lotes, precio_venta, ...
    rendimiento, areas, demanda,familia_botanica,familia_venta,poblacion,Covkkp] = funcion_objetivo(poblacion);

%===========================================================================
%% Creaci�n de los cromosomas iniciales
%===========================================================================
% La funci�n denominada "inicializar_cromosomas", tiene como par�metros de
% entrada las caracter�sticas del modelo aproximado (con unidades de tiempo
% basadas en meses en vez de semanas como el modelo exacto) y la cantidad
% de individuos que conforman la poblaci�n. Esta funci�n carga datos
% relacionados con las caracter�sticas del cromosoma como cantidad de
% periodos y restricciones de siembra y dem�s, retorna los cromosomas y sus
% respectivas funciones objetivo.
[ Cromosomas,Matriz_objetivos ] = inicializar_cromosomas(poblacion, cant_objetivos, cant_periodos, cant_productos, cant_lotes,precio_venta, rendimiento, areas, demanda,familia_botanica,familia_venta,Covkkp);

%===========================================================================
%% Determinar dominancia de la soluci�n inicial
% Se ordena la poblaci�n usando ordenar_poblacion. La funci�n devuelve dos
% columnas para cada individuo que son el rango y la distancia de
% apilamiento correspondiente a su posici�n en el frente al que pertenecen.
% En este punto el rango y la distancia de amontonamiento para cada
% cromosoma se almacena en una variable extra.
[ Cromosomas, Matriz_objetivos, orden_poblacion ] = ordenar_poblacion( Cromosomas, Matriz_objetivos,cant_objetivos );

%===========================================================================
%%
% Comienza la evoluci�n de las generaciones
for gen = 1: generaciones
    scatter(Matriz_objetivos(2,:),Matriz_objetivos(3,:),'filled')
    drawnow
    % Los padres son seleccionados para la reproducci�n para generar
    % descendencia a partir de un torneo tipo binario basado en en comparar la
    % funci�n fitness (Matriz_objetivo, fila 1), de ah� se generan lo padres
    % para realizar los diversos crices.
    
    % se crea la cantidad de grupos a enfrentarse
    pool = round(poblacion/2);
    %     se define el tipo de torneo
    torneo = 2;
    %     se construye una nueva poblaci�n a partir de una funci�n torneo
    [Cromosomas_padres ,criterio_evaluacion_padres,objetivos_padres]= seleccion_por_torneo(Cromosomas, Matriz_objetivos, orden_poblacion, pool, torneo);
%    fprintf('Cromosomas padres\n');
%     Cromosomas_padres
%     size(Cromosomas_padres)
%     pause
    %     criterio_evaluacion_padres
    probabilidad_mutacion=0.10;
    
    [Cromosomas_hijos, objetivos_hijos]= operador_genetico(Cromosomas,cant_objetivos, ...
        cant_periodos, cant_lotes,Cromosomas_padres,probabilidad_mutacion,poblacion,cant_productos,...
        Covkkp,precio_venta,rendimiento,areas,demanda,familia_botanica,familia_venta);
%     fprintf('Cromosomas hijos\n');
%     Cromosomas_hijos
%     size(Cromosomas_hijos)
%     pause
    % objetivos_hijos
    
    % % ahora se construye la poblaci�n intermedia, �sta es la combinaci�n de lso
    % % padres e hijos
%     fprintf('Cromosomas intermedio\n');
    Cromosomas_intermedios=cat(2,Cromosomas_padres,Cromosomas_hijos);
    Matriz_objetivos_intermedio=cat(2,objetivos_padres,objetivos_hijos);
%     size(Cromosomas_intermedios)
%    fprintf('Generaci�n n�mero\n');
%     gen
%     pause
    
    [ Cromosomas_intermedios, Matriz_objetivos_intermedio, orden_poblacion_intermedio ] = ordenar_poblacion( Cromosomas_intermedios, Matriz_objetivos_intermedio,cant_objetivos );
%     fprintf('C�lculo del orden\n');
    x=orden_poblacion_intermedio';
    x(:,3)=1:length(x);
%     pause
%     fprintf('C�lculo del orden\n');
    orden=sortrows(x,[1,2],{'ascend','descend'});
    orden=orden(:,3)';
%     fprintf('C�lculo del orden\n');
%     orden
%     poblacion
%     cant_lotes
%     pause
%     fprintf('Individuos que conforman la nueva poblacion\n');
%     orden(1:poblacion);
%     pause
    for ajuste=1:length(orden(1:poblacion))
    Cromosomas(:,(ajuste-1)*cant_lotes+1:(ajuste-1)*cant_lotes+cant_lotes)=...
        Cromosomas_intermedios(:,(orden(ajuste)-1)*cant_lotes+1:(orden(ajuste)-1)*cant_lotes+cant_lotes);
%     ajuste
%     orden(ajuste)
%     pause
    end
    
    Matriz_objetivos=Matriz_objetivos_intermedio(:,orden(1:poblacion));
    orden_poblacion=orden_poblacion_intermedio(:,orden(1:poblacion));
    % sortrows(A',[2,7],{'ascend','descend'})
end
%===========================================================================
end

