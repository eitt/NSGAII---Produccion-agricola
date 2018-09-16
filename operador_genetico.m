function [ Cromosomas_hijos, objetivos_hijos] = operador_genetico( Cromosomas,cant_objetivos, cant_periodos, cant_lotes,Cromosomas_padres,...
    probabilidad_mutacion,poblacion,cant_productos,Covkkp,precio_venta,rendimiento,areas,demanda,familia_botanica,familia_venta)
%% OPERADOR_GENETICO Summary of this function goes here

[~,N] = size(Cromosomas_padres);
N=N/cant_lotes;
Matriz_objetivos=zeros(cant_objetivos+1,1)

p = 1;
% Flags used to set if crossover and mutation were actually performed.
was_crossover = 0;
was_mutation = 0;
V=0;

load('parametros_maduracion.mat')
% PPP = Productos Por Periodo
% MTS = Matriz Tiempos Siembra
% MFS = Matriz Fecha Siembra
% PM  = Periodo de maduración
% PMS = Periodo de maduración en semanas
% para la prueba trabajaré con 5 sujetos


for i = 1 : N
    % With 90 % probability perform crossover
    if rand() < 1- probabilidad_mutacion
        % Initialize the children to be null vector.
        child_1 = [];
        child_2 = [];
        padres=datasample(1:N,2,'Replace',false);
        
        % Get the chromosome information for each randomnly selected
        % parents
        parent_1 = Cromosomas_padres(:,(padres(1)-1)*cant_lotes+1:(padres(1)-1)*cant_lotes+cant_lotes);
% %         pause
        parent_2 = Cromosomas_padres(:,(padres(2)-1)*cant_lotes+1:(padres(2)-1)*cant_lotes+cant_lotes);
% %         pause
        % Perform corssover for each decision variable in the chromosome.
        punto_cruce=min(randi([1 cant_lotes],1,1),cant_lotes-1);
%         pause
        parent_1(:,1:punto_cruce);
%         pause
        parent_2(:,punto_cruce+1:cant_lotes);
%         pause
        child_1=cat(2,parent_1(:,1:punto_cruce),parent_2(:,punto_cruce+1:cant_lotes));
%         pause
        child_2=cat(2,parent_2(:,1:punto_cruce),parent_1(:,punto_cruce+1:cant_lotes));
%         pause
        % Evaluate the objective function for the offsprings and as before
        % concatenate the offspring chromosome with objective value.
        objetivo_1=zeros(cant_objetivos+1,1);
        [child_1, objetivo_1]=Evaluar_individuos(child_1,objetivo_1 , 1,  ...
            cant_productos, cant_lotes, PMS, Covkkp, precio_venta,rendimiento, areas, ...
            demanda,familia_botanica,familia_venta);
        
        objetivo_2=zeros(cant_objetivos+1,1);
        [child_2, objetivo_2]=Evaluar_individuos(child_2,objetivo_2 , 1,  ...
            cant_productos, cant_lotes, PMS, Covkkp, precio_venta,rendimiento, areas, ...
            demanda,familia_botanica,familia_venta);
        
        
        %  sum(cumsum(PMS(child_2(child_2(:,recorrido)~=0,recorrido))+1)>T*4)>=1
        % Set the crossover flag. When crossover is performed two children
        % are generate, while when mutation is performed only only child is
        % generated.
        was_crossover = 1;
        was_mutation = 0;
        child=cat(2,child_1,child_2);
        obj=cat(2,objetivo_1,objetivo_2);
        
        % With 10 % probability perform mutation. Mutation is based on
        % polynomial mutation.
    else
        
        %         seleccionaré al azar dos padres y a estos en algún segmento del
        %         cromozoma realizaré un cambio
        % Initialize the children to be null vector.
        child_1 = [];
        child_2 = [];
        padres=datasample(1:N,2,'Replace',false);
        
        % Get the chromosome information for each randomnly selected
        % parents
        parent_1 = Cromosomas_padres(:,(padres(1)-1)*cant_lotes+1:(padres(1)-1)*cant_lotes+cant_lotes);
%         pause
        
        child_1=parent_1;
        punto_mutacion_1=randi([1 cant_lotes],1,1);
%         un único individuo y un único lote
        mutacion = crear_mutacion( 1, cant_objetivos, cant_periodos, 1);
        child_1(:,punto_mutacion_1)=mutacion;
        
parent_2 = Cromosomas_padres(:,(padres(2)-1)*cant_lotes+1:(padres(2)-1)*cant_lotes+cant_lotes);
        child_2=parent_2;
         punto_mutacion_2=randi([1 cant_lotes],1,1);
         mutacion = crear_mutacion( 1, cant_objetivos, cant_periodos, 1);
          child_2(:,punto_mutacion_2)=mutacion;
          
           % Evaluate the objective function for the offsprings and as before
        % concatenate the offspring chromosome with objective value.
        objetivo_1=zeros(cant_objetivos+1,1);
        [child_1, objetivo_1]=Evaluar_individuos(child_1,objetivo_1 , 1,  ...
            cant_productos, cant_lotes, PMS, Covkkp, precio_venta,rendimiento, areas, ...
            demanda,familia_botanica,familia_venta);

        objetivo_2=zeros(cant_objetivos+1,1);
        [child_2, objetivo_2]=Evaluar_individuos(child_2,objetivo_2 , 1,  ...
            cant_productos, cant_lotes, PMS, Covkkp, precio_venta,rendimiento, areas, ...
            demanda,familia_botanica,familia_venta);
        
        
        %  sum(cumsum(PMS(child_2(child_2(:,recorrido)~=0,recorrido))+1)>T*4)>=1
        % Set the crossover flag. When crossover is performed two children
        % are generate, while when mutation is performed only only child is
        % generated.
        was_crossover = 1;
        was_mutation = 0;
        child=cat(2,child_1,child_2);
        size(child);
%         pause
        obj=cat(2,objetivo_1,objetivo_2);
    end
    (i-1)*cant_lotes*2+1:(i-1)*cant_lotes*2+cant_lotes*2;
%     pause
     Cromosomas_hijos(:,(i-1)*cant_lotes*2+1:(i-1)*cant_lotes*2+cant_lotes*2)=child;
    
%     pause
    objetivos_hijos(:,(i-1)*2+1:(i-1)*2+2) =obj;
%     pause
    
    
    %%
end

