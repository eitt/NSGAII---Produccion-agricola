function [ IC_Cromosomas,IC_Matriz_objetivos ] = inicializar_cromosomas(poblacion, cant_objetivos, cant_periodos, cant_productos, cant_lotes,precio_venta, rendimiento, areas, demanda,familia_botanica,familia_venta,Covkkp)
%%
% Se actualizan las variables de la función

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
% Se cargan en el sistema los parámetros relacionados con las restricciones
% de producción, como los tiempo en los cuales se puede sembrar cada
% producto, la duración del mismo. Todo lo anterior, para la estructura de
% cromosoma, la cual está en meses y no semanas como el problema original.
load('parametros_maduracion.mat')
% PPP = Productos Por Periodo
% MTS = Matriz Tiempos Siembra
% MFS = Matriz Fecha Siembra
% PM  = Periodo de maduración
% PMS = Periodo de maduración en semanas
% para la prueba trabajaré con 5 sujetos

%%
%Cálculo de variables y parámetros
%Duración del proyecto
T=cant_periodos;
% Cantidad de Lotes
L=cant_lotes;
% Cantidad de cromosomas
C=poblacion;
% Contador para los bucles
CONTADOR=0;
% Se contruye la matriz donde se almacenarán la función de ajuste, seguida
% de las funciones objetivo
IC_Matriz_objetivos=zeros(cant_objetivos+1,poblacion);
%%
% Creación del cromosoma
IC_Cromosomas=zeros(T,L*C);
% Contador de periodos del proyecto
CPP=1:1:T;

% Bucle para asignar aleatoriamente los productos durante el horizonte de
% planeación
% Cromosomas auxiliares para llevar la asignación de tiempos y bloqueo de
% lotes
% Ayuda a organizar los productos en los diversos periodos
Cromosoma_aux1=0*IC_Cromosomas;
% Almacena el contador de meses en que dura ocupado cada terreno
Cromosoma_aux2=Cromosoma_aux1;
% Ayuda a verificar condiciones del cromosoma
Cromosoma_aux3=Cromosoma_aux1+1;
% se realiza un bucle durante la duración del proyecto, por ahorro en
% recursos computacionales, no se tiene en cuenta los tres últimos periodos
% ya que ningún producto puede ser sembrado en ese instante:
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
%% Evaluación de las soluciones
% La función denominada "Evaluar_individuos" toma como parámetros de
% entrada la población de soluciones y una variable en la cual se
% almacenarán los resultados de tres funciones: 1) Función de ajuste, 2)
% Maximizar ingresos y 3) minimizar riesgo financiero del portafolio.
% Dentro de la función los datos son transformados parcialmente con el
% propósito de evaluar el cumplimiento de ciertas restricciones y valorar
% el desempeño de las soluciones.
%===========================================================================
[  IC_Cromosomas,IC_Matriz_objetivos ]=Evaluar_individuos(IC_Cromosomas,IC_Matriz_objetivos , poblacion, ...
    cant_productos, cant_lotes, PMS, Covkkp, precio_venta,rendimiento, areas, ...
    demanda,familia_botanica,familia_venta);
%===========================================================================
end

