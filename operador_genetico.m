function [ Cromosomas_hijos, objetivos_hijos] = operador_genetico( OG_cant_objetivos, OG_cant_periodos, OG_cant_lotes,OG_Cromosomas_padres,...
    OG_probabilidad_mutacion,OG_poblacion,OG_cant_productos,OG_Covkkp,OG_precio_venta,OG_rendimiento,OG_areas,OG_demanda,OG_familia_botanica,OG_familia_venta)
%     la función 'operador_genetico' crea hijos a partir de los padres
%     seleccionados, para ello existen dos posibildiades: 1) generar dos
%     hijos a partir del cruce -en un único punto- entre dos padres. 2) la
%     generación de 2 hijos a partir de la mutación en un segmento del
%     cromosoma de ambos padres. la función genera la solución y el
%     respectivo valor de las funciones de ajuste.

% Como el existe la posibilidad de generar nuevos segmentos del cromosoma
% (cuando se aplica la mutación), es necesario cargar las variables para
% generar los cromosomas. las variables de entrada del modelo son:
% OG_cant_objetivos (cantidad de objetivos a evaluar), % OG_cant_periodos
% (tamaño del horizonte del planeación), OG_cant_lotes (cantidad de lotes
% a ser cultivados), OG_Cromosomas_padres(conjunto de soluciones ya pre
% seleccionads) OG_probabilidad_mutacion (Probabilidad de generar el hijo a
% partir de la mutación del padre), OG_poblacion (tamaño de la población),
% OG_cant_productos (cantidad de productos a cultivar), OG_Covkkp
% (covarianza entre los rendimientos o retornos económicos de cada
% producto), OG_precio_venta (Precio de venta de cada producto para cada
% semana), OG_rendimiento (cantidad de kilogramos por metro cuadrado a
% recoger de cada producto), OG_areas (tamaño en metros cuadrados de cada
% lote), OG_demanda (Demanda de cada categoría de productos),
% OG_familia_botanica (Familia botánica a la que pertenece cada producto),
% OG_familia_venta (Categorías o familia de venta a la cual pertenece cada
% producto). y como variables de salida: Cromosomas_hijos (conjunto de
% soluciones generadas a partir de las transformaciones genéticas) y
% objetivos_hijos (valor de las funciones de ajuste para las soluciones
% creadas).

% Las variables de entrada son: poblacion
% cant_objetivos  cant_periodos cant_productos  cant_lotes  precio_venta
%  rendimiento
% areas  demanda familia_botanica familia_venta  y Covkkp
%===========================================================================
% Se calcula la cantidad de individuos en la población de padres
[~,N] = size(OG_Cromosomas_padres);
N=N/OG_cant_lotes;
% Se genera una variable auxiliar para almacenar el valor de las funciones
% de ajuste de cada nuevo indidviduo
Matriz_objetivos=zeros(OG_cant_objetivos+1,1);
% Se cargan los parámetros
load('parametros_maduracion.mat')
% PPP = Productos Por Periodo
% MTS = Matriz Tiempos Siembra
% MFS = Matriz Fecha Siembra
% PM  = Periodo de maduración
% PMS = Periodo de maduración en semanas
% para la prueba trabajaré con 5 sujetos

% Se genera un bucle para todos los padres
for i = 1 : N
    % Se determina si se aplica una mutación o cruce
    if rand() < 1- OG_probabilidad_mutacion
        % Se crean los hivos (para el caso de cruce)
        hijo_1 = [];
        hijo_2 = [];
        % Se seleccionan los padres
        padres=datasample(1:N,2,'Replace',false);
        % Se utilzia la información (cromosomas) de cada padre
        padre_1 = OG_Cromosomas_padres(:,(padres(1)-1)*OG_cant_lotes+1:(padres(1)-1)*OG_cant_lotes+OG_cant_lotes);
        padre_2 = OG_Cromosomas_padres(:,(padres(2)-1)*OG_cant_lotes+1:(padres(2)-1)*OG_cant_lotes+OG_cant_lotes);
        % Se determina un punto de cruce, el cual es aleatorio entre 1 y la
        % cantidad de lotes -1
        punto_cruce=min(randi([1 OG_cant_lotes],1,1),OG_cant_lotes-1);
        % Se construyen los hijos con la información de los padres teniendo en
        % cuenta el punto de cruce
        hijo_1=cat(2,padre_1(:,1:punto_cruce),padre_2(:,punto_cruce+1:OG_cant_lotes));
        hijo_2=cat(2,padre_2(:,1:punto_cruce),padre_1(:,punto_cruce+1:OG_cant_lotes));
        % Se declara el vector donde se almacena la función objetivo del hijo 1, y
        % se evalua utilziando la función 'Evaluar_individuos'
        objetivo_1=zeros(OG_cant_objetivos+1,1);
        %===========================================================================
        [hijo_1, objetivo_1]=Evaluar_individuos(hijo_1,objetivo_1 , 1,  ...
            OG_cant_productos, OG_cant_lotes, PMS, OG_Covkkp, ...
            OG_precio_venta,OG_rendimiento, OG_areas, ...
            OG_demanda,OG_familia_botanica,OG_familia_venta);
        %===========================================================================
        % Se declara el vector donde se almacena la función objetivo del hijo 2, y
        % se evalua utilziando la función 'Evaluar_individuos'
        objetivo_2=zeros(OG_cant_objetivos+1,1);
        %===========================================================================
        [hijo_2, objetivo_2]=Evaluar_individuos(hijo_2,objetivo_2 , 1,  ...
            OG_cant_productos, OG_cant_lotes, PMS, OG_Covkkp, ...
            OG_precio_venta,OG_rendimiento, OG_areas, ...
            OG_demanda,OG_familia_botanica,OG_familia_venta);
        %===========================================================================
        % Se concatena (almacena) la unformación de ambos hijos en forma de
        % cromosoma y su respectivo valor de función de ajuste
        % Cromosoma
        hijos=cat(2,hijo_1,hijo_2);
        % Valor de la función de ajuste
        objetivos=cat(2,objetivo_1,objetivo_2);
    else
        % Se declaran dos hijos vacios, para el caso de mutación
        hijo_1 = [];
        hijo_2 = [];
        % Se seleccionan al azar dos padres
        padres=datasample(1:N,2,'Replace',false);
        % Se utiliza la información (cromosomas) del padre 1
        padre_1 = OG_Cromosomas_padres(:,(padres(1)-1)*OG_cant_lotes+1:(padres(1)-1)*OG_cant_lotes+OG_cant_lotes);
        % Se iguala la información del padre a la del hijo
        hijo_1=padre_1;
        % Se identifica el punto (subcromosoma) donde se realizará la
        % mutación
        punto_mutacion_1=randi([1 OG_cant_lotes],1,1);
        % un único individuo y un único lote
        %===========================================================================
        % Se genera la mutación
        %===========================================================================
        % Se contruye una función denominada 'crear-mutacion', la cual en
        % escencia está estructurada como la función
        % -inicializar-cromosomas' pero enfocada en un único lote.
        mutacion = crear_mutacion( 1, OG_cant_objetivos, OG_cant_periodos, 1);
        %===========================================================================
        % Se actualiza el cromosoma en la solución hijo
        hijo_1(:,punto_mutacion_1)=mutacion;
        % Se crea una variable para almacenar la solución del hijo 1
        objetivo_1=zeros(OG_cant_objetivos+1,1);
        %===========================================================================
        % Se evalua la solución del hijo 1
        %===========================================================================
        [hijo_1, objetivo_1]=Evaluar_individuos(hijo_1,objetivo_1 , 1,  ...
            OG_cant_productos, OG_cant_lotes, PMS, OG_Covkkp, ...
            OG_precio_venta,OG_rendimiento, OG_areas, OG_demanda,...
            OG_familia_botanica,OG_familia_venta);
        %===========================================================================
        
        % Se utiliza la información (cromosomas) del padre 2
        padre_2 = OG_Cromosomas_padres(:,(padres(2)-1)*OG_cant_lotes+1:(padres(2)-1)*OG_cant_lotes+OG_cant_lotes);
        % Se iguala la información del padre a la del hijo
        hijo_2=padre_2;
        % Se identifica el punto (subcromosoma) donde se realizará la
        % mutación
        punto_mutacion_2=randi([1 OG_cant_lotes],1,1);
        %===========================================================================
        % Se genera la mutación
        %===========================================================================
        % Se contruye una función denominada 'crear-mutacion', la cual en
        % escencia está estructurada como la función
        % -inicializar-cromosomas' pero enfocada en un único lote.
        mutacion = crear_mutacion( 1, OG_cant_objetivos, OG_cant_periodos, 1);
        %===========================================================================
        % Se actualiza el cromosoma en la solución hijo
        hijo_2(:,punto_mutacion_2)=mutacion;
        %         Se crea una variable para almacenar la solución del hijo 2
        objetivo_2=zeros(OG_cant_objetivos+1,1);
        %===========================================================================
        % Se evalua la solución del hijo 2
        %===========================================================================
        [hijo_2, objetivo_2]=Evaluar_individuos(hijo_2,objetivo_2 , 1,  ...
            OG_cant_productos, OG_cant_lotes, PMS, OG_Covkkp, OG_precio_venta,OG_rendimiento, OG_areas, ...
            OG_demanda,OG_familia_botanica,OG_familia_venta);
        %===========================================================================
        % Se concatena (almacena) la unformación de ambos hijos en forma de
        % cromosoma y su respectivo valor de función de ajuste
        % Cromosoma
        hijos=cat(2,hijo_1,hijo_2);
        % Valor de la función de ajuste
        objetivos=cat(2,objetivo_1,objetivo_2);
    end
    % Se actualiza la información de la solución
    % solución
    Cromosomas_hijos(:,(i-1)*OG_cant_lotes*2+1:(i-1)*OG_cant_lotes*2+OG_cant_lotes*2)=hijos;
    %     Valor de las funciones de ajuste
    objetivos_hijos(:,(i-1)*2+1:(i-1)*2+2) =objetivos;
    
end
%===========================================================================
end