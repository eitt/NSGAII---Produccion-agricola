function [ ST_Cromosomas_padres,ST_criterio_evaluacion_padres,ST_Matriz_objetivos_padres ] = seleccion_por_torneo( ST_Cromosomas, ST_Matriz_objetivos, ST_criterio_evaluacion, ST_pool, ST_torneo )
%% Tournament selection process
% El torneo se realiza mediante la selección aleatoria de individuos
% donde n es igual a la cantidad de torneos, el ganador del torneo es
% agregado a la población para el cruce, donde el tamaño de crices es igual
% a la dimensión de la variable pool. la Selección se basa en dos criterios
% el primero es el rango del individuo en el frente u como segundo criterio
% la distancia de apolamiento.
%%
% Se actualizan los valores de la función
[~, cant_cromosomas]=size(ST_Cromosomas);

% Get the size of Cromosomas. The number of Cromosomas is not important
% while the number of elements in Cromosomas are important.
[variables, poblacion] = size(ST_criterio_evaluacion)
Poblacion_total=poblacion
cant_lotes=cant_cromosomas/poblacion
poblacion=1:poblacion

% The peunltimate element contains the information about rank.
rango = ST_criterio_evaluacion(variables - 1,:);
% The last element contains information about crowding distance.
distancia = ST_criterio_evaluacion(variables,:);

% Until the mating pool is filled, perform tournament selection
for i = 1 : ST_pool

    if i==1
        combatientes=datasample(poblacion,ST_torneo,'Replace',false);
        rango=ST_criterio_evaluacion(1,combatientes);
        distancia=ST_criterio_evaluacion(2,combatientes);
    else
        combatientes=datasample(poblacion(poblacion~=0),ST_torneo,'Replace',false);
        rango=ST_criterio_evaluacion(1,combatientes);
        distancia=ST_criterio_evaluacion(2,combatientes);
    end
  
    % Find the candidate with the least rank
    min_candidate = find(rango == min(rango));
    % If more than one candiate have the least rank then find the candidate
    % within that group having the maximum crowding distance.
%     ST_criterio_evaluacion
    if length(min_candidate) ~= 1
        max_candidate = find(distancia(min_candidate) == max(distancia(min_candidate)));
        % If a few individuals have the least rank and have maximum crowding
        % distance, select only one individual (not at random).
        if length(max_candidate) ~= 1
            max_candidate = max_candidate(1);
        end
        % Add the selected individual to the mating pool
        ST_Matriz_objetivos_padres(:,i)=ST_Matriz_objetivos(:,combatientes(min_candidate(max_candidate)));
        ST_criterio_evaluacion_padres(:,i)=ST_criterio_evaluacion(:,combatientes(min_candidate(max_candidate)));
%         (combatientes(min_candidate(max_candidate)))*cant_lotes-1:(combatientes(min_candidate(max_candidate)))*cant_lotes
        
%         pause
        ST_Cromosomas_padres(:,(i-1)*cant_lotes+1:(i-1)*cant_lotes+cant_lotes) = ST_Cromosomas(:,((combatientes(min_candidate(max_candidate)))-1)*cant_lotes+1:((combatientes(min_candidate(max_candidate)))-1)*cant_lotes+cant_lotes);
        poblacion(combatientes(min_candidate(max_candidate)))=0;
    else
        % Add the selected individual to the mating pool
        ST_Matriz_objetivos_padres(:,i)=ST_Matriz_objetivos(:,combatientes(min_candidate(1)));
        ST_criterio_evaluacion_padres(:,i)=ST_criterio_evaluacion(:,combatientes(min_candidate(1)));
%       (combatientes(min_candidate(1)))*cant_lotes-1:(combatientes(min_candidate(1)))*cant_lotes
      ((combatientes(min_candidate(1)))-1)*cant_lotes+1:((combatientes(min_candidate(1)))-1)*cant_lotes+cant_lotes;
%       pause
        ST_Cromosomas_padres(:,(i-1)*cant_lotes+1:(i-1)*cant_lotes+cant_lotes) = ST_Cromosomas(:,((combatientes(min_candidate(1)))-1)*cant_lotes+1:((combatientes(min_candidate(1)))-1)*cant_lotes+cant_lotes);
        poblacion(combatientes(min_candidate(1)))=0;
    end
    
    ST_Cromosomas_padres;
    ST_criterio_evaluacion_padres;
    ST_Matriz_objetivos_padres;
end
%     ST_Cromosomas_padres=ST_Cromosomas_padres(:,1:Poblacion_total);
end
