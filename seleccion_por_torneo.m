function [ ST_Cromosomas_padres,ST_criterio_evaluacion_padres,...
    ST_Matriz_objetivos_padres ] = seleccion_por_torneo( ST_Cromosomas, ...
    ST_Matriz_objetivos, ST_criterio_evaluacion, ST_pool, ST_torneo )
%===========================================================================
% La selección de los padres de hace de manera aleatoria a partir del
% conjunto total de soluciones (variable denominada 'Cromosomas'), cada
% par de padres se enfrenta teniendo en cuenta dos parámetros: 1) el
% valor del frente a cual pertenece cada individuo, seleccionando el
% individuo de menor frente y, 2) el valor de la distancia de
% apilamiento, en caso de pertenecer al mismo frente, como criterio de
% selección está el individuo con mayor valor de distancia.
%
% las variables de entrada son ST_Cromosomas (Soluciones a competir), ...
% ST_Matriz_objetivos (Funciones de ajuste), ST_criterio_evaluacion (
% la primera fila corresponde al frente al cual pertenece cada solución y
% la segunda fila la distancia de apilamiento de la solución en su
% respectivo frente), ST_pool (cantidad de grupos a enfrentarse) y
% ST_torneo (cantidad de contrincantes). Como variables de salida la
% función genera: ST_Cromosomas_padres (Soluciones seleccionadas como
% ganadoras del torneo), ST_criterio_evaluacion_padres (los respectivos
% valores de frente y distancia de apilamiento de las soluciones
% seleccionadas) y ST_Matriz_objetivos_padres (matriz de soluciones de
% ajuste).
%===========================================================================
%%
%===========================================================================
% Se calcula la cantidad de cromosomas a evaluar
[~, cant_cromosomas]=size(ST_Cromosomas);
% Se calcula la cantidad de individuos
[variables, poblacion] = size(ST_criterio_evaluacion);
% Se almacena la cantidad de individuos en una variable auxiliar
Poblacion_total=poblacion;
% Se computa la cantidad de lotes del problema
cant_lotes=cant_cromosomas/poblacion;
% Se crea un vector auxiliar para determinar cuáles miembros son
% seleccionados:
poblacion=1:poblacion;

% Se almacena el frente al que pertenece cada solución en la variable rango
rango = ST_criterio_evaluacion(variables - 1,:);
% Se almacena el valor de distancia de cada solución en la variable
% distancia
distancia = ST_criterio_evaluacion(variables,:);

% Se genera un contador con todos la cantidad de combates o enfrentamientos
for i = 1 : ST_pool
    % Como a medida que pasan los enfrentamientos la cantidad de individuos
    % disminuye, se crea una condición de selección, la cual sólo aplica luego
    % del primer enfrentamiento.
    % para el primer enfrentamiento
    if i==1
        %         seleccione los contrincantes
        combatientes=datasample(poblacion,ST_torneo,'Replace',false);
        %         almacene el valor del frente
        rango=ST_criterio_evaluacion(1,combatientes);
        %         almacene el valor de la distancia
        distancia=ST_criterio_evaluacion(2,combatientes);
        % Para el resto de enfrentamientos
    else
        %         Seleccione los contrincantes que no han sido seleccionado
        %         anteriormente
        combatientes=datasample(poblacion(poblacion~=0),ST_torneo,'Replace',false);
        %         almacene el valor del frente
        rango=ST_criterio_evaluacion(1,combatientes);
        %         almacene el valor de la distancia
        distancia=ST_criterio_evaluacion(2,combatientes);
    end
    
    % Seleccione el candidato con el menor rango
    min_candidato = find(rango == min(rango));
    % Como es posible que los dos contrincantes pertenezcan al mismo rango, el
    % valor de miembros de 'min_candidato' puede ser mayor de 1, pro tanto:
    % si hay más de una solución:
    if length(min_candidato) ~= 1
        %     seleccione el candidato con la mayor distancia
        max_candidato = find(distancia(min_candidato) == max(distancia(min_candidato)));
        % si los dos sujetos tienen la misma distnacia, seleccione cualquiera (por
        % defecto, el primero)
        if length(max_candidato) ~= 1
            max_candidato = max_candidato(1);
        end
        % Se selecciona el valor de la solución y se almacena el la variable de
        % salida
        ST_Matriz_objetivos_padres(:,i)=ST_Matriz_objetivos(:,combatientes(min_candidato(max_candidato)));
        % Se almacenan los correspondientes criteros de evaluación (valor de frente
        % y distancia)
        ST_criterio_evaluacion_padres(:,i)=ST_criterio_evaluacion(:,combatientes(min_candidato(max_candidato)));
        % Se almacena la solución en la nueva variable de cromosomas
        ST_Cromosomas_padres(:,(i-1)*cant_lotes+1:(i-1)*cant_lotes+cant_lotes) = ST_Cromosomas(:,((combatientes(min_candidato(max_candidato)))-1)*cant_lotes+1:((combatientes(min_candidato(max_candidato)))-1)*cant_lotes+cant_lotes);
        %         se elimina el ganador del pool
        poblacion(combatientes(min_candidato(max_candidato)))=0;
        % Sí sólo existe un único contrincante por frente:
    else
        % Se selecciona el valor de la solución y se almacena el la variable de
        % salida
        ST_Matriz_objetivos_padres(:,i)=ST_Matriz_objetivos(:,combatientes(min_candidato(1)));
        % Se almacenan los correspondientes criteros de evaluación (valor de frente
        % y distancia)
        ST_criterio_evaluacion_padres(:,i)=ST_criterio_evaluacion(:,combatientes(min_candidato(1)));
        %       (combatientes(min_candidate(1)))*cant_lotes-1:(combatientes(min_candidate(1)))*cant_lotes
        ((combatientes(min_candidato(1)))-1)*cant_lotes+1:((combatientes(min_candidato(1)))-1)*cant_lotes+cant_lotes;
        % Se almacena la solución en la nueva variable de cromosomas
        ST_Cromosomas_padres(:,(i-1)*cant_lotes+1:(i-1)*cant_lotes+cant_lotes) = ST_Cromosomas(:,((combatientes(min_candidato(1)))-1)*cant_lotes+1:((combatientes(min_candidato(1)))-1)*cant_lotes+cant_lotes);
        %         se elimina el ganador del pool
        poblacion(combatientes(min_candidato(1)))=0;
    end
end
%===========================================================================
end
