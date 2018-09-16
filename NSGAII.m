function [ solucion, fo1, fo2 ] = NSGAII( poblacion,generaciones )
%% NSGAII Introducción

%% Verificación de parámetros del modelo
%===========================================================================
if nargin < 2
    error('NSGA-II: Por favor, Ingrese el tamaño de la población y el número de generaciones como argumentos de entrada.');
end
% Tipo de argumentos (numéricos)
if isnumeric(poblacion) == 0 || isnumeric(generaciones) == 0
    error('Ambos argumentos de entrada Pobalación (pop) y Número de generaciones (gen) deben ser de tipo entero');
end
% El tamaño mínimo de la población debe ser de 20 individuos
if poblacion < 20
    error('El tamaño mínimo de la población debe ser de 20 individuos');
end
% La cantidad mínima de generaciones es de 5
if generaciones < 5
    error('La cantidad mínima de generaciones es de 5');
end

if isinteger(poblacion) == 0 || isinteger(generaciones)==0
    fprintf('Los valores deben ser enteros y, por tanto, para evitar errores son redondeados al entero inferior')
    % Verificar que las entradas son enteras, a partir de un redondeo
    poblacion = round(poblacion);
    generaciones = round(generaciones);
end
%%
% Carga de la función objetivo
%===========================================================================
% La función denominada "funcion_objetivo", es un guión editable en el cual
% se definen las dos funciones objetivo bajo estudio, así mismo, la
% cantidad de variables y parámetros del modelo como: Número de periodos,
% cantidad de Lotes, Cantidad de productos, número de variables de
% decisión, cantidad de restricciones, etc. Teniendo en cuenta la
% estructura del modelo, los parámetros son obtenidos a partir de de unos
% datos almacenados en un archivo .data
[ cant_objetivos, cant_variables, limite_inferior, limite_superior, ...
    funcion_1, funcion_2, cant_periodos ,cant_productos, cant_lotes, precio_venta, ...
    rendimiento, areas, demanda,familia_botanica,familia_venta,poblacion,Covkkp] = funcion_objetivo(poblacion);

%===========================================================================
%% Creación de los cromosomas iniciales
%===========================================================================
% La función denominada "inicializar_cromosomas", tiene como parámetros de
% entrada las características del modelo aproximado (con unidades de tiempo
% basadas en meses en vez de semanas como el modelo exacto) y la cantidad
% de individuos que conforman la población. Esta función carga datos
% relacionados con las características del cromosoma como cantidad de
% periodos y restricciones de siembra y demás, retorna los cromosomas y sus
% respectivas funciones objetivo.
[ Cromosomas,Matriz_objetivos ] = inicializar_cromosomas(poblacion, cant_objetivos, cant_periodos, cant_productos, cant_lotes,precio_venta, rendimiento, areas, demanda,familia_botanica,familia_venta,Covkkp);

%===========================================================================
%% Determinar dominancia de la solución inicial
% Se ordena la población usando ordenar_poblacion. La función devuelve dos
% columnas para cada individuo que son el rango y la distancia de
% apilamiento correspondiente a su posición en el frente al que pertenecen.
% En este punto el rango y la distancia de amontonamiento para cada
% cromosoma se almacena en una variable extra.
[ Cromosomas, Matriz_objetivos, orden_poblacion ] = ordenar_poblacion( Cromosomas, Matriz_objetivos,cant_objetivos );

%===========================================================================
%%
% Comienza la evolución de las generaciones
for gen = 1: generaciones
    scatter(Matriz_objetivos(2,:),Matriz_objetivos(3,:),'filled')
    drawnow
    % Los padres son seleccionados para la reproducción para generar
    % descendencia a partir de un torneo tipo binario basado en en comparar la
    % función fitness (Matriz_objetivo, fila 1), de ahí se generan lo padres
    % para realizar los diversos crices.
    
    % se crea la cantidad de grupos a enfrentarse
    pool = round(poblacion/2);
    %     se define el tipo de torneo
    torneo = 2;
    %     se construye una nueva población a partir de una función torneo
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
    
    % % ahora se construye la población intermedia, ésta es la combinación de lso
    % % padres e hijos
%     fprintf('Cromosomas intermedio\n');
    Cromosomas_intermedios=cat(2,Cromosomas_padres,Cromosomas_hijos);
    Matriz_objetivos_intermedio=cat(2,objetivos_padres,objetivos_hijos);
%     size(Cromosomas_intermedios)
%    fprintf('Generación número\n');
%     gen
%     pause
    
    [ Cromosomas_intermedios, Matriz_objetivos_intermedio, orden_poblacion_intermedio ] = ordenar_poblacion( Cromosomas_intermedios, Matriz_objetivos_intermedio,cant_objetivos );
%     fprintf('Cálculo del orden\n');
    x=orden_poblacion_intermedio';
    x(:,3)=1:length(x);
%     pause
%     fprintf('Cálculo del orden\n');
    orden=sortrows(x,[1,2],{'ascend','descend'});
    orden=orden(:,3)';
%     fprintf('Cálculo del orden\n');
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

