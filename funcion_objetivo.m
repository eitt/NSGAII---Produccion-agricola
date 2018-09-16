function [ FO_cant_objetivos, FO_cant_variables, FO_limite_inferior, FO_limite_superior, ...
    FO_funcion_1, FO_funcion_2, FO_cant_periodos ,FO_cant_productos, FO_cant_lotes, FO_precio_venta, ...
    FO_rendimiento, FO_areas, FO_demanda,FO_familia_botanica,FO_familia_venta,FO_poblacion,FO_Covkkp] = funcion_objetivo(poblacion)
% se cargan los archivos
% esta instancia es con la cual se probó el modelo exacto
% load('instancia_prueba.mat');
% se carga la instancia general, para este caso, se trabajará con dos lotes

load('productos_parametros')
%Cantidad de periodos
T=length(Conjunto_s)/4;
% Cantidad de productos
K=length(Ni);
% Cantidad de lotes
% L=length(Al);
% para este caso d eprueba se trabajará con 2 lotes
L=1500;
% Selecciono al azar L lotes
lotes=datasample(1:length(Rkl(:,1)),L,'Replace',false);
% Actualizo los rendimientos para los dos lotes seleccionados
Rkl=Rkl(lotes,:);
% Calculo el área de los dos lotes
Al=Al(lotes');

% Estimar la matriz de Covarianza de los precios;
% Covkkp=cov((Pkt)');
Covkkp=cov(diff(log(Pkt)',1));
% Determinar la cantidad de variables de decisión para cada una de las
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
% Cálculo de los pesos de las variables de decisión
% Objetivo 1
f = -repmat(Pkt(:),L,1);
FO_funcion_1=cat(1,zeros(Cant_Y+Cant_V,1),f,zeros(Cant_U,1));
% Objetivo 2
cova=zeros(1,Cant_U/L);
for k1= 1:K
    for k2=1:K
        recorrido=((K*T)*(k1-1))+T*(k2-1);
        cova(recorrido+1:recorrido+T)=Covkkp(k1,k2);
    end
end
% cova=repmat(cova,1,L);


FO_funcion_2 =cat(1,zeros(FO_cant_variables-Cant_U,1),cova');
% Cálculo de los límites inferiores y superiores:
FO_limite_inferior = zeros(length(f),1);
FO_limite_superior =  cat(1,ones(Cant_Y+Cant_V,1),Inf(Cant_Z+Cant_U,1));
% para este caso, la cantidad de periodos es de 24 meses, los cuales
% corresponden a la aproximación de las 96 semanas de duración del
% horizonte de planeación propuesto para el modelo exacto.
FO_cant_periodos=24;
FO_cant_productos=K;
FO_cant_lotes=L;
FO_precio_venta=Pkt;
FO_rendimiento=Rkl;
FO_areas=Al;
FO_demanda=Demanda_Gv;
FO_familia_botanica=q;
FO_familia_venta=Gv;
FO_poblacion=poblacion
FO_Covkkp=Covkkp;
end

