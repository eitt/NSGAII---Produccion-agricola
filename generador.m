%Limpieza de variables
clear all
clc
tic
%Carga de datos y parámetros
load('matlab.mat')
% PPP = Productos Por Periodo
% MTS = Matriz Tiempos Siembra
% MFS = Matriz Fecha Siembra
% PM  = Periodo de maduración

%Cálculo de variables y parámetros
%Duración del proyecto
T=length(PPP); %Tamaño del periodo de decisión
%Cantidad de Lotes
L=10458;
%Cantidad de cromosomas
C=100;
CONTADOR=0;
% %%
% for cromosomas = 1:10:C
%    for lotes=1:1000:L
%        CONTADOR=CONTADOR+1;
%        tstart=tic;
%    %Creación del cromosoma
% CL=zeros(T,lotes*cromosomas);
% %Cromosomas auxiliares para llevar la asignación de tiempos y bloqueo de
% %lotes
% CL1=0*CL;
% CL2=CL1+1;
% %Contador de periodos del proyecto
% CPP=1:1:T;
% 
% %Bucle para asignar aleatoriamente los productos durante el horizonte de
% %planeación
% CL1=0*CL;
% CL2=CL1;
% CL3=CL1+1;
% for tiempo=1:1:T-2
%     %Para cada periodo se asignan aletoriamente los 25 productos en L
%     %lotes, siempre y cuando estos puedan ser sembrados en ese instante y
%     %existan lotes disponibles
%     CL(tiempo,:)= (datasample(find(MFS(:,tiempo)~=0),lotes*cromosomas)').*CL3(tiempo,:);
%    CL1(tiempo,:)=CL(tiempo,:);
%     %Determino un listado de los productos que pueden ser sembrados en cada
%     %periodo
%     var1=find(MFS(:,tiempo)~=0);
%     
%     for listado=1:length(var1)
%         CL2(tiempo,:) = CL2(tiempo,:) + (CL(tiempo,:)==var1(listado))*PM(var1(listado));
%     
%     end
%     while tiempo > 1
%          CL2(tiempo,:) = CL2(tiempo-1,:) - 1;
%          CL(tiempo,:)=(datasample(find(MFS(:,tiempo)~=0),lotes*cromosomas)').*(CL2(tiempo,:) <1);
%           CL1(tiempo,:)=CL(tiempo,:);
%     %Determino un listado de los productos que pueden ser sembrados en cada
%     %periodo
%     var1=find(MFS(:,tiempo)~=0);
%     
%     for listado=1:length(var1)
%         CL2(tiempo,:) = CL2(tiempo,:) + (CL(tiempo,:)==var1(listado))*PM(var1(listado));
%     
%     end
%          break
%     
%     end
% 
% end
% 
% matrix2D = reshape(CL(:), [T*lotes cromosomas]);
%    leo(ceil(cromosomas/100),ceil(lotes/1000))=toc(tstart);
%    xlswrite('leo2.csv',leo,'Tiempos')
%     cromosomas
%     lotes
%     CONTADOR
%    end
% 
% end
%%

%Creación del cromosoma
CL=zeros(T,L*C);
%Cromosomas auxiliares para llevar la asignación de tiempos y bloqueo de
%lotes
CL1=0*CL;
CL2=CL1+1;
%Contador de periodos del proyecto
CPP=1:1:T;

%Bucle para asignar aleatoriamente los productos durante el horizonte de
%planeación
CL1=0*CL;
CL2=CL1;
CL3=CL1+1;
for tiempo=1:1:T-3
    %Para cada periodo se asignan aletoriamente los 25 productos en L
    %lotes, siempre y cuando estos puedan ser sembrados en ese instante y
    %existan lotes disponibles
    CL(tiempo,:)= (datasample(find(MFS(:,tiempo)~=0),L*C)').*CL3(tiempo,:);
   CL1(tiempo,:)=CL(tiempo,:);
    %Determino un listado de los productos que pueden ser sembrados en cada
    %periodo
    var1=find(MFS(:,tiempo)~=0);
    
    for listado=1:length(var1)
        CL2(tiempo,:) = CL2(tiempo,:) + (CL(tiempo,:)==var1(listado))*PM(var1(listado));
    
    end
    while tiempo > 1
         CL2(tiempo,:) = CL2(tiempo-1,:) - 1;
         CL(tiempo,:)=(datasample(find(MFS(:,tiempo)~=0),L*C)').*(CL2(tiempo,:) <1);
          CL1(tiempo,:)=CL(tiempo,:);
    %Determino un listado de los productos que pueden ser sembrados en cada
    %periodo
    var1=find(MFS(:,tiempo)~=0);
    
    for listado=1:length(var1)
        CL2(tiempo,:) = CL2(tiempo,:) + (CL(tiempo,:)==var1(listado))*PM(var1(listado));
    
    end
         break
    
    end

end

% matrix2D = reshape(CL(:), [T*L C]);

cromosoma_a_vector
toc