function [ IC_Cromosomas,IC_Matriz_objetivos ] =...
    inicializar_cromosomas(poblacion, cant_objetivos, cant_periodos, ...
    cant_productos, cant_lotes,precio_venta, rendimiento, areas, ...
    demanda,familia_botanica,familia_venta,Covkkp)
%===========================================================================
% La función denominada "inicializar_cromosomas", tiene como parámetros de
% entrada las características del modelo aproximado (con unidades de tiempo
% basadas en meses en vez de semanas como el modelo exacto) y la cantidad
% de individuos que conforman la población. Esta función carga datos
% relacionados con las características del cromosoma como cantidad de
% periodos y restricciones de siembra y demás, retorna los cromosomas y sus
% respectivas funciones objetivo. Para cambiar el modelo, es necesario
% modificar el archivo .data ya que este indica los periodos de siembra,
% duración del periodo de madurez y otros elementos que caracterizan el
% caso de estudio a trabajar.

% Las variables de entrada son: poblacion (tamaño de la población),
% cant_objetivos (cantidad de objetivos a evaluar), cant_periodos (tamaño
% del horizonte del planeación), cant_productos (cantidad de productos a
% cultivar), cant_lotes (cantidad de ltoes a ser cultivados), precio_venta
% (Precio de venta de cada producto para cada semana), rendimiento (
% cantidad de kilogramos por metro cuadrado a recoger de cada producto),
% areas (tamaño en metros cuadrados de cada lote), demanda (Demanda de cada
% categoría de productos),familia_botanica (Familia botánica a la que
% pertenece cada producto),familia_venta (Categorías o familia de venta a
% la cual pertenece cada producto) y Covkkp (covarianza entre los
% rendimientos o retornos económicos de cada producto).

% Las variables de salida son: IC_Cromosomas (Conjunto de cromosomas o
% soluciones generadas de manera aleatoria) y IC_Matriz_objetivos (Matriz
% de objetivos, la cual incluye en primera linea o fila la penalización por
% inclumplimiento de restricciones, la segunda fila es el primer objetivo
% (Maximizar ingresos) menos la penalización y la tercera fila corresponde
% al segundo objetivo (Minimizar riesgo financiero) penalizada (sumando)
% por el valor de la fila 1.
%===========================================================================
%%

%===========================================================================
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
%===========================================================================
%%
%===========================================================================
%Cálculo de variables y parámetros
%===========================================================================
%Duración del proyecto
T=cant_periodos;
% Cantidad de Lotes
L=cant_lotes;
% Cantidad de cromosomas
C=poblacion;
% Se contruye la matriz donde se almacenarán la función de ajuste, seguida
% de las funciones objetivo
IC_Matriz_objetivos=zeros(cant_objetivos+1,poblacion);
% Creación del cromosoma
IC_Cromosomas=zeros(T,L*C);
% Cromosomas auxiliares para llevar la asignación de tiempos y bloqueo de
% Ayuda a organizar los productos en los diversos periodos
Cromosoma_aux1=0*IC_Cromosomas;
% Almacena el contador de meses en que dura ocupado cada terreno
Cromosoma_aux2=Cromosoma_aux1;
% Ayuda a verificar condiciones del cromosoma
Cromosoma_aux3=Cromosoma_aux1+1;
% Se realiza un bucle durante la duración del proyecto, por ahorro en
% recursos computacionales, no se tiene en cuenta los tres últimos periodos
% ya que ningún producto puede ser sembrado en ese instante:
for tiempo=1:1:T-3
    %     Para cada periodo se asignan aletoriamente los 25 productos en L
    %     lotes, siempre y cuando estos puedan ser sembrados en ese instante y
    %     existan lotes disponibles
    IC_Cromosomas(tiempo,:)= (datasample(find(MFS(:,tiempo)~=0),L*C)').*Cromosoma_aux3(tiempo,:);
    %     Se contruye el vector auxiliar 1
    Cromosoma_aux1(tiempo,:)=IC_Cromosomas(tiempo,:);
    %     Se crea un listado de los productos que pueden ser sembrados en cada
    %     periodo
    var_aux1=find(MFS(:,tiempo)~=0);
    %     Se registra en el vector auxiliar la cantidad de periodos de
    %     maduración para cada producto
    for listado=1:length(var_aux1)
        Cromosoma_aux2(tiempo,:) = Cromosoma_aux2(tiempo,:) + (IC_Cromosomas(tiempo,:)==var_aux1(listado))*PM(var_aux1(listado));
    end
    %     Una vez asignado el primer cultivo, se recorren los vectores
    %     auxiliares con el fin de evitar doble asignación mientras cada lote
    %     está ocupado (durante el periodo de madurez de cada lote), para ello,
    %     un vector auxiliar es el contador de madurez y una vez sea cero,
    %     puede sembrarse otro cultivo.
    while tiempo > 1
        Cromosoma_aux2(tiempo,:) = Cromosoma_aux2(tiempo-1,:) - 1;
        %         Se asigna aleatoriamente los cultivos para el subconjunto de
        %         productos respectivo a cada mes.
        IC_Cromosomas(tiempo,:)=(datasample(find(MFS(:,tiempo)~=0),L*C)').*(Cromosoma_aux2(tiempo,:) <1);
        %         Se actualiza el valor del cromosoma auxiliar
        Cromosoma_aux1(tiempo,:)=IC_Cromosomas(tiempo,:);
        %         Determino un listado de los productos que pueden ser sembrados
        %         en cada periodo
        var_aux1=find(MFS(:,tiempo)~=0);
        %         Se bloquea la asignación de productos mientras esté el periodo de
        %         madurez
        for listado=1:length(var_aux1)
            Cromosoma_aux2(tiempo,:) = Cromosoma_aux2(tiempo,:) + (IC_Cromosomas(tiempo,:)==var_aux1(listado))*PM(var_aux1(listado));
        end
        break
    end
end
%===========================================================================
%% 
%===========================================================================
% Evaluación de las soluciones
%===========================================================================
% La función denominada "Evaluar_individuos" toma como parámetros de
% entrada la población de soluciones y una variable en la cual se
% almacenarán los resultados de tres funciones: 1) Función de ajuste, 2)
% Maximizar ingresos y 3) minimizar riesgo financiero del portafolio.
% Dentro de la función los datos son transformados parcialmente con el
% propósito de evaluar el cumplimiento de ciertas restricciones y valorar
% el desempeño de las soluciones.
%===========================================================================
[  IC_Cromosomas,IC_Matriz_objetivos ]=Evaluar_individuos(IC_Cromosomas,...
    IC_Matriz_objetivos , poblacion, cant_productos, cant_lotes, PMS, ...
    Covkkp, precio_venta,rendimiento, areas, demanda,familia_botanica,...
    familia_venta);
%===========================================================================

end

