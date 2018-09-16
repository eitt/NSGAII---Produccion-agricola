function [ IC_Cromosomas,IC_Matriz_objetivos ] = inicializar_cromosomas(poblacion, cant_objetivos, cant_periodos, cant_productos, cant_lotes,precio_venta, rendimiento, areas, demanda,familia_botanica,familia_venta,Covkkp)
%%
% Se actualizan las variables de la funci�n

% poblacion=poblacion;
% cant_objetivos=cant_objetivos;
% cant_periodos=cant_periodos;
% cant_lotes=cant_lotes;
% precio_venta=precio_venta;
% rendimiento=rendimiento;
% areas=areas;
% demanda=demanda;
% familia_botanica=familia_botanica;
% familia_venta=familia_venta;
%%
% Se cargan en el sistema los par�metros relacionados con las restricciones
% de producci�n, como los tiempo en los cuales se puede sembrar cada
% producto, la duraci�n del mismo. Todo lo anterior, para la estructura de
% cromosoma, la cual est� en meses y no semanas como el problema original.
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
T=cant_periodos;
% Cantidad de Lotes
L=cant_lotes;
% Cantidad de cromosomas
C=poblacion;
% Contador para los bucles
CONTADOR=0;
% Se contruye la matriz donde se almacenar�n la funci�n de ajuste, seguida
% de las funciones objetivo
IC_Matriz_objetivos=zeros(cant_objetivos+1,poblacion);
%%
% Creaci�n del cromosoma
IC_Cromosomas=zeros(T,L*C);
% Contador de periodos del proyecto
CPP=1:1:T;

% Bucle para asignar aleatoriamente los productos durante el horizonte de
% planeaci�n
% Cromosomas auxiliares para llevar la asignaci�n de tiempos y bloqueo de
% lotes
% Ayuda a organizar los productos en los diversos periodos
Cromosoma_aux1=0*IC_Cromosomas;
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
    IC_Cromosomas(tiempo,:)= (datasample(find(MFS(:,tiempo)~=0),L*C)').*Cromosoma_aux3(tiempo,:);
    Cromosoma_aux1(tiempo,:)=IC_Cromosomas(tiempo,:);
    %Determino un listado de los productos que pueden ser sembrados en cada
    %periodo
    var_aux1=find(MFS(:,tiempo)~=0);
    for listado=1:length(var_aux1)
        Cromosoma_aux2(tiempo,:) = Cromosoma_aux2(tiempo,:) + (IC_Cromosomas(tiempo,:)==var_aux1(listado))*PM(var_aux1(listado));
    end
    while tiempo > 1
        Cromosoma_aux2(tiempo,:) = Cromosoma_aux2(tiempo-1,:) - 1;
        IC_Cromosomas(tiempo,:)=(datasample(find(MFS(:,tiempo)~=0),L*C)').*(Cromosoma_aux2(tiempo,:) <1);
        Cromosoma_aux1(tiempo,:)=IC_Cromosomas(tiempo,:);
        % Determino un listado de los productos que pueden ser sembrados en cada
        % periodo
        var_aux1=find(MFS(:,tiempo)~=0);
        for listado=1:length(var_aux1)
            Cromosoma_aux2(tiempo,:) = Cromosoma_aux2(tiempo,:) + (IC_Cromosomas(tiempo,:)==var_aux1(listado))*PM(var_aux1(listado));
        end
        break
    end
end
%% Evaluaci�n de las soluciones
% La funci�n denominada "Evaluar_individuos" toma como par�metros de
% entrada la poblaci�n de soluciones y una variable en la cual se
% almacenar�n los resultados de tres funciones: 1) Funci�n de ajuste, 2)
% Maximizar ingresos y 3) minimizar riesgo financiero del portafolio.
% Dentro de la funci�n los datos son transformados parcialmente con el
% prop�sito de evaluar el cumplimiento de ciertas restricciones y valorar
% el desempe�o de las soluciones.
%===========================================================================
[  IC_Cromosomas,IC_Matriz_objetivos ]=Evaluar_individuos(IC_Cromosomas,IC_Matriz_objetivos , poblacion, ...
    cant_productos, cant_lotes, PMS, Covkkp, precio_venta,rendimiento, areas, ...
    demanda,familia_botanica,familia_venta);
%===========================================================================
end

