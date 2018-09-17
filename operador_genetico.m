function [ Cromosomas_hijos, objetivos_hijos] = operador_genetico( OG_cant_objetivos, OG_cant_periodos, OG_cant_lotes,OG_Cromosomas_padres,...
    OG_probabilidad_mutacion,OG_poblacion,OG_cant_productos,OG_Covkkp,OG_precio_venta,OG_rendimiento,OG_areas,OG_demanda,OG_familia_botanica,OG_familia_venta)
%     la funci�n 'operador_genetico' crea hijos a partir de los padres
%     seleccionados, para ello existen dos posibildiades: 1) generar dos
%     hijos a partir del cruce -en un �nico punto- entre dos padres. 2) la
%     generaci�n de 2 hijos a partir de la mutaci�n en un segmento del
%     cromosoma de ambos padres. la funci�n genera la soluci�n y el
%     respectivo valor de las funciones de ajuste.

% Como el existe la posibilidad de generar nuevos segmentos del cromosoma
% (cuando se aplica la mutaci�n), es necesario cargar las variables para
% generar los cromosomas. las variables de entrada del modelo son:
% OG_cant_objetivos (cantidad de objetivos a evaluar), % OG_cant_periodos
% (tama�o del horizonte del planeaci�n), OG_cant_lotes (cantidad de lotes
% a ser cultivados), OG_Cromosomas_padres(conjunto de soluciones ya pre
% seleccionads) OG_probabilidad_mutacion (Probabilidad de generar el hijo a
% partir de la mutaci�n del padre), OG_poblacion (tama�o de la poblaci�n),
% OG_cant_productos (cantidad de productos a cultivar), OG_Covkkp
% (covarianza entre los rendimientos o retornos econ�micos de cada
% producto), OG_precio_venta (Precio de venta de cada producto para cada
% semana), OG_rendimiento (cantidad de kilogramos por metro cuadrado a
% recoger de cada producto), OG_areas (tama�o en metros cuadrados de cada
% lote), OG_demanda (Demanda de cada categor�a de productos),
% OG_familia_botanica (Familia bot�nica a la que pertenece cada producto),
% OG_familia_venta (Categor�as o familia de venta a la cual pertenece cada
% producto). y como variables de salida: Cromosomas_hijos (conjunto de
% soluciones generadas a partir de las transformaciones gen�ticas) y
% objetivos_hijos (valor de las funciones de ajuste para las soluciones
% creadas).

% Las variables de entrada son: poblacion
% cant_objetivos  cant_periodos cant_productos  cant_lotes  precio_venta
%  rendimiento
% areas  demanda familia_botanica familia_venta  y Covkkp
%===========================================================================
% Se calcula la cantidad de individuos en la poblaci�n de padres
[~,N] = size(OG_Cromosomas_padres);
N=N/OG_cant_lotes;
% Se genera una variable auxiliar para almacenar el valor de las funciones
% de ajuste de cada nuevo indidviduo
Matriz_objetivos=zeros(OG_cant_objetivos+1,1);
% Se cargan los par�metros
load('parametros_maduracion.mat')
% PPP = Productos Por Periodo
% MTS = Matriz Tiempos Siembra
% MFS = Matriz Fecha Siembra
% PM  = Periodo de maduraci�n
% PMS = Periodo de maduraci�n en semanas
% para la prueba trabajar� con 5 sujetos

% Se genera un bucle para todos los padres
for i = 1 : N
    % Se determina si se aplica una mutaci�n o cruce
    if rand() < 1- OG_probabilidad_mutacion
        % Se crean los hivos (para el caso de cruce)
        hijo_1 = [];
        hijo_2 = [];
        % Se seleccionan los padres
        padres=datasample(1:N,2,'Replace',false);
        % Se utilzia la informaci�n (cromosomas) de cada padre
        padre_1 = OG_Cromosomas_padres(:,(padres(1)-1)*OG_cant_lotes+1:(padres(1)-1)*OG_cant_lotes+OG_cant_lotes);
        padre_2 = OG_Cromosomas_padres(:,(padres(2)-1)*OG_cant_lotes+1:(padres(2)-1)*OG_cant_lotes+OG_cant_lotes);
        % Se determina un punto de cruce, el cual es aleatorio entre 1 y la
        % cantidad de lotes -1
        punto_cruce=min(randi([1 OG_cant_lotes],1,1),OG_cant_lotes-1);
        % Se construyen los hijos con la informaci�n de los padres teniendo en
        % cuenta el punto de cruce
        hijo_1=cat(2,padre_1(:,1:punto_cruce),padre_2(:,punto_cruce+1:OG_cant_lotes));
        hijo_2=cat(2,padre_2(:,1:punto_cruce),padre_1(:,punto_cruce+1:OG_cant_lotes));
        % Se declara el vector donde se almacena la funci�n objetivo del hijo 1, y
        % se evalua utilziando la funci�n 'Evaluar_individuos'
        objetivo_1=zeros(OG_cant_objetivos+1,1);
        %===========================================================================
        [hijo_1, objetivo_1]=Evaluar_individuos(hijo_1,objetivo_1 , 1,  ...
            OG_cant_productos, OG_cant_lotes, PMS, OG_Covkkp, ...
            OG_precio_venta,OG_rendimiento, OG_areas, ...
            OG_demanda,OG_familia_botanica,OG_familia_venta);
        %===========================================================================
        % Se declara el vector donde se almacena la funci�n objetivo del hijo 2, y
        % se evalua utilziando la funci�n 'Evaluar_individuos'
        objetivo_2=zeros(OG_cant_objetivos+1,1);
        %===========================================================================
        [hijo_2, objetivo_2]=Evaluar_individuos(hijo_2,objetivo_2 , 1,  ...
            OG_cant_productos, OG_cant_lotes, PMS, OG_Covkkp, ...
            OG_precio_venta,OG_rendimiento, OG_areas, ...
            OG_demanda,OG_familia_botanica,OG_familia_venta);
        %===========================================================================
        % Se concatena (almacena) la unformaci�n de ambos hijos en forma de
        % cromosoma y su respectivo valor de funci�n de ajuste
        % Cromosoma
        hijos=cat(2,hijo_1,hijo_2);
        % Valor de la funci�n de ajuste
        objetivos=cat(2,objetivo_1,objetivo_2);
    else
        % Se declaran dos hijos vacios, para el caso de mutaci�n
        hijo_1 = [];
        hijo_2 = [];
        % Se seleccionan al azar dos padres
        padres=datasample(1:N,2,'Replace',false);
        % Se utiliza la informaci�n (cromosomas) del padre 1
        padre_1 = OG_Cromosomas_padres(:,(padres(1)-1)*OG_cant_lotes+1:(padres(1)-1)*OG_cant_lotes+OG_cant_lotes);
        % Se iguala la informaci�n del padre a la del hijo
        hijo_1=padre_1;
        % Se identifica el punto (subcromosoma) donde se realizar� la
        % mutaci�n
        punto_mutacion_1=randi([1 OG_cant_lotes],1,1);
        % un �nico individuo y un �nico lote
        %===========================================================================
        % Se genera la mutaci�n
        %===========================================================================
        % Se contruye una funci�n denominada 'crear-mutacion', la cual en
        % escencia est� estructurada como la funci�n
        % -inicializar-cromosomas' pero enfocada en un �nico lote.
        mutacion = crear_mutacion( 1, OG_cant_objetivos, OG_cant_periodos, 1);
        %===========================================================================
        % Se actualiza el cromosoma en la soluci�n hijo
        hijo_1(:,punto_mutacion_1)=mutacion;
        % Se crea una variable para almacenar la soluci�n del hijo 1
        objetivo_1=zeros(OG_cant_objetivos+1,1);
        %===========================================================================
        % Se evalua la soluci�n del hijo 1
        %===========================================================================
        [hijo_1, objetivo_1]=Evaluar_individuos(hijo_1,objetivo_1 , 1,  ...
            OG_cant_productos, OG_cant_lotes, PMS, OG_Covkkp, ...
            OG_precio_venta,OG_rendimiento, OG_areas, OG_demanda,...
            OG_familia_botanica,OG_familia_venta);
        %===========================================================================
        
        % Se utiliza la informaci�n (cromosomas) del padre 2
        padre_2 = OG_Cromosomas_padres(:,(padres(2)-1)*OG_cant_lotes+1:(padres(2)-1)*OG_cant_lotes+OG_cant_lotes);
        % Se iguala la informaci�n del padre a la del hijo
        hijo_2=padre_2;
        % Se identifica el punto (subcromosoma) donde se realizar� la
        % mutaci�n
        punto_mutacion_2=randi([1 OG_cant_lotes],1,1);
        %===========================================================================
        % Se genera la mutaci�n
        %===========================================================================
        % Se contruye una funci�n denominada 'crear-mutacion', la cual en
        % escencia est� estructurada como la funci�n
        % -inicializar-cromosomas' pero enfocada en un �nico lote.
        mutacion = crear_mutacion( 1, OG_cant_objetivos, OG_cant_periodos, 1);
        %===========================================================================
        % Se actualiza el cromosoma en la soluci�n hijo
        hijo_2(:,punto_mutacion_2)=mutacion;
        %         Se crea una variable para almacenar la soluci�n del hijo 2
        objetivo_2=zeros(OG_cant_objetivos+1,1);
        %===========================================================================
        % Se evalua la soluci�n del hijo 2
        %===========================================================================
        [hijo_2, objetivo_2]=Evaluar_individuos(hijo_2,objetivo_2 , 1,  ...
            OG_cant_productos, OG_cant_lotes, PMS, OG_Covkkp, OG_precio_venta,OG_rendimiento, OG_areas, ...
            OG_demanda,OG_familia_botanica,OG_familia_venta);
        %===========================================================================
        % Se concatena (almacena) la unformaci�n de ambos hijos en forma de
        % cromosoma y su respectivo valor de funci�n de ajuste
        % Cromosoma
        hijos=cat(2,hijo_1,hijo_2);
        % Valor de la funci�n de ajuste
        objetivos=cat(2,objetivo_1,objetivo_2);
    end
    % Se actualiza la informaci�n de la soluci�n
    % soluci�n
    Cromosomas_hijos(:,(i-1)*OG_cant_lotes*2+1:(i-1)*OG_cant_lotes*2+OG_cant_lotes*2)=hijos;
    %     Valor de las funciones de ajuste
    objetivos_hijos(:,(i-1)*2+1:(i-1)*2+2) =objetivos;
    
end
%===========================================================================
end