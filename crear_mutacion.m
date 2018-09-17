function [ CM_Cromosoma ] = crear_mutacion( CM_poblacion, CM_cant_objetivos, CM_cant_periodos, CM_cant_lotes)
%===========================================================================
% Se contruye una funci�n denominada 'crear-mutacion', la cual en
% escencia est� estructurada como la funci�n % -inicializar-cromosomas' 
% pero enfocada en un �nico lote. Los par�metros de entrada son 
% CM_poblacion (poblaci�n, la cual en este caso es un �nico individuo),
% CM_cant_objetivos (cantidad de objetivos a evaluar), CM_cant_periodos (la 
% cantidad de periodos del horizonte de planeaci�n) y CM_cant_lotes
% (cantidad de lotes a crear, en este caso, un �nico lote). Como salida la
% funci�n presenta un �nico cromosoma denominado: 'CM_Cromosoma' 
%===========================================================================
%%
%===========================================================================
load('parametros_maduracion.mat')
% PPP = Productos Por Periodo
% MTS = Matriz Tiempos Siembra
% MFS = Matriz Fecha Siembra
% PM  = Periodo de maduraci�n
% PMS = Periodo de maduraci�n en semanas
% para la prueba trabajar� con 5 sujetos

%%
%C�lculo de variables y par�metros
%Duraci�n del proyecto
T=CM_cant_periodos;
% Cantidad de Lotes
L=CM_cant_lotes;
% Cantidad de cromosomas
C=CM_poblacion;
% Contador para los bucles
CONTADOR=0;
% Se contruye la matriz donde se almacenar�n la funci�n de ajuste, seguida
% de las funciones objetivo
Matriz_objetivos=zeros(CM_cant_objetivos+1,CM_poblacion);
%%
% Creaci�n del cromosoma
CM_Cromosoma=zeros(T,L*C);
% Contador de periodos del proyecto
CPP=1:1:T;

% Bucle para asignar aleatoriamente los productos durante el horizonte de
% planeaci�n
% Cromosomas auxiliares para llevar la asignaci�n de tiempos y bloqueo de
% lotes
% Ayuda a organizar los productos en los diversos periodos
Cromosoma_aux1=0*CM_Cromosoma;
% Almacena el contador de meses en que dura ocupado cada terreno
Cromosoma_aux2=Cromosoma_aux1;
% Ayuda a verificar condiciones del cromosoma
Cromosoma_aux3=Cromosoma_aux1+1;
% se realiza un bucle durante la duraci�n del proyecto, por ahorro en
% recursos computacionales, no se tiene en cuenta los tres �ltimos periodos
% ya que ning�n producto puede ser sembrado en ese instante:
for tiempo=1:1:T-3
    %Para cada periodo se asignan aletoriamente los 25 productos en L
    %lotes, siempre y cuando estos puedan ser sembrados en ese instante y
    %existan lotes disponibles
    CM_Cromosoma(tiempo,:)= (datasample(find(MFS(:,tiempo)~=0),L*C)').*Cromosoma_aux3(tiempo,:);
    Cromosoma_aux1(tiempo,:)=CM_Cromosoma(tiempo,:);
    %Determino un listado de los productos que pueden ser sembrados en cada
    %periodo
    var_aux1=find(MFS(:,tiempo)~=0);
    for listado=1:length(var_aux1)
        Cromosoma_aux2(tiempo,:) = Cromosoma_aux2(tiempo,:) + (CM_Cromosoma(tiempo,:)==var_aux1(listado))*PM(var_aux1(listado));
    end
    while tiempo > 1
        Cromosoma_aux2(tiempo,:) = Cromosoma_aux2(tiempo-1,:) - 1;
        CM_Cromosoma(tiempo,:)=(datasample(find(MFS(:,tiempo)~=0),L*C)').*(Cromosoma_aux2(tiempo,:) <1);
        Cromosoma_aux1(tiempo,:)=CM_Cromosoma(tiempo,:);
        % Determino un listado de los productos que pueden ser sembrados en cada
        % periodo
        var_aux1=find(MFS(:,tiempo)~=0);
        for listado=1:length(var_aux1)
            Cromosoma_aux2(tiempo,:) = Cromosoma_aux2(tiempo,:) + (CM_Cromosoma(tiempo,:)==var_aux1(listado))*PM(var_aux1(listado));
        end
        break
    end
end
%===========================================================================
end

