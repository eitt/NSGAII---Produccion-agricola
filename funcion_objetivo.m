function [ FO_cant_objetivos, FO_cant_variables,  ...
    FO_cant_periodos ,FO_cant_productos, FO_cant_lotes, FO_precio_venta, ...
    FO_rendimiento, FO_areas, FO_demanda,FO_familia_botanica,FO_familia_venta,FO_Covkkp] = funcion_objetivo()
%===========================================================================
% Carga de la funci�n objetivo
%===========================================================================
% La funci�n denominada "funcion_objetivo", es un gui�n editable en el cual
% se definen las dos funciones objetivo bajo estudio, as� mismo, la
% cantidad de variables y par�metros del modelo como: N�mero de periodos,
% cantidad de Lotes, Cantidad de productos, n�mero de variables de
% decisi�n, cantidad de restricciones, etc. Teniendo en cuenta la
% estructura del modelo, los par�metros son obtenidos a partir de de unos
% datos almacenados en un archivo .data Para cambiar caracter�sticas como
% el rendimiento agr�cola poe lote, el tama�o de cada lote, etc. Es
% necesario cambiar el conjunto de datos.
%===========================================================================
% Los datos de salida de la funci�n son: FO_cant_objetivos (Cantidad de 
% objetivos), FO_cant_variables (Cantidad de variables),FO_cant_periodos 
% (Cantidad de periodos en el horizonte de planeaci�n),FO_cant_productos ( 
% cantidad de productos a cultivar y recoger), FO_cant_lotes (cantidad de 
% lotes a cultivar), FO_precio_venta (precio de venta de cada producto en 
% el horizonte de planeaci�n), FO_rendimiento (Cantidad de kilogramos de 
% cad aproducto a recoger en cada lote), FO_areas (tama�o en metros 
% cuadrados de cada lote), FO_demanda (Demanda de cada familia de 
% productos), FO_familia_botanica (Familia bot�nica a la cual pertenece 
% cada producto),FO_familia_venta (Familia de productos sustitutos para
% satisfacer la demanda)y FO_Covkkp (covarianza de los rendimientos 
% econ�micos de cada producto).
% se carga la instancia general, para este caso, se trabajar� con dos lotes
%===========================================================================
%%
% Se cargan las caracter�sticas generales del problema a atender: 7039
% Lotes, 21 Productos, 96 semanas para el horizonte de planeaci�n, 5
% familias bot�nicas, 4 categor�as de producto de venta, La demanda para 
% cada categor�a de venta, durante el horizonte de planeaci�n.
load('productos_parametros')
% Conjunto_s: Vector con los instantes donde puede sembrarse cada producto.
% q:          Familia bot�nica a la que pertenece cada producto.
% Ni:         N�mero de periodos que se demora el producto k en "Madurar".
% Pkt:        Precio de venta del producto K en el instante t
% Rkl:        Rendimiento en Kg/m2 de cada producto (col) por lote (fil)
% Al:         �rea en metros de cada lote
% Gv          Grupo de productos sustitutos para satisfacer una demanda

% Se calcula la cantidad de periodos del cromosoma (en mes)
T=length(Conjunto_s)/4;
% Cantidad de productos
K=length(Ni);
% Cantidad de lotes para cada caso de prueba se trabajar� con L lotes
L=40;
% Selecciono al azar L lotes
lotes=datasample(1:length(Rkl(:,1)),L,'Replace',false);
% Actualizo los rendimientos para los dos lotes seleccionados
Rkl=Rkl(lotes,:);
% Calculo el �rea de los dos lotes
Al=Al(lotes');

% Se estima la matriz de Covarianza de los precios;
Covkkp=cov(diff(log(Pkt)',1));
% Determinar la cantidad de variables de decisi�n para cada una de las
% familias de variables:
% {Y_t }^{l,k}
Cant_Y=K*T*L;
% {V_t }^{l,k}
Cant_V=K*T*L;
% {Z_t }^{l,k}
Cant_Z=K*T*L;
% {_y }^{k,k}
Cant_U=K*K*T*L;
% Cantidad de variables
FO_cant_variables=Cant_Y+Cant_V+Cant_Z+Cant_U;
% Cantidad de objetivos: por defecto son dos
FO_cant_objetivos=2;
%%

% para este caso, la cantidad de periodos es de 24 meses, los cuales
% corresponden a la aproximaci�n de las 96 semanas de duraci�n del
% horizonte de planeaci�n propuesto para el modelo exacto.
FO_cant_periodos=T;
FO_cant_productos=K;
FO_cant_lotes=L;
FO_precio_venta=Pkt;
FO_rendimiento=Rkl;
FO_areas=Al;
FO_demanda=Demanda_Gv;
FO_familia_botanica=q;
FO_familia_venta=Gv;
FO_Covkkp=Covkkp;
end

