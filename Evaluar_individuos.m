function [  Cromosomas,Matriz_objetivos ] = Evaluar_individuos(Cromosomas,Matriz_objetivos , poblacion,  ...
   cant_productos, cant_lotes, PMS, Covkkp, precio_venta,rendimiento, areas, ...
    demanda,familia_botanica,familia_venta)
%%
% Se actualizan las variables

%%
% Se construye una variable en la cual se almacenar�n tres valores para
% cada individuo. La primera fila corresponde a la funci�n fitness, la cual
% es la suma de la primera funci�n objetivo menos diferentes
% penalizaciones relacionadas con el incumplimiento de restricciones: 1)
% restricciones_tiempo (la cual cuantifica la cantidad de variables en
% todos los lotes que exceden el horizonte de planeaci�n), 2)
% restricciones_holgura (cuantifica cu�ntos periodos por encima o por
% debajo del horizonte de planeaci�n se encuentra), 3) sobre producci�n, la
% cual no se almacena como variable sino cuantifica la cantidad total de
% kilogramos de productos (por familia de venta) sembrados y recogidos, que
% no pueden ser vendidos ya que no existe demanda), 4)  rotaciones (cuenta
% la cantidad de veces que quedaron sembrados de manera seguida dos
% productos que pertenecen a la misma familia.
%% 
% Cromosomas
[T,~]=size(Cromosomas);

% Se realiza un recorrido para evaluar cada individuo
for individuo=1:poblacion
%     individuo
%     pause
    % Se crean una matriz para almacenar la cantidad de producto (en
    % kilogramos) que se recoge de cada producto para cada individuo.
    Matriz_productos=zeros(1,cant_productos);
    % Se construye un vector para almacenar el volumen de producci�n, este
    % vector posteriormente se contrasta con la demanda para el horizonte
    % de planeaci�n
    Matriz_venta=zeros(length(demanda),1);
    % Se contruye una variable para contabilizar la cantidad de veces que
    % son sembrados dos productos de manera consecutiva que pertenecen a la
    % misma familia bot�nica.
    rotaciones=0;
    % Se genra un recorrido para todos los lotes de cada uno de los
    % individuos.
    for lote=1:cant_lotes
%         cant_lotes
%         lote
%         pause
        % Se construye una variable auxiliar
        recorrido=cant_lotes*(individuo-1)+lote;
%         recorrido
%         pause
        %%
        % A continuaci�n de documenta a manera de comentario la construcci�n de las
        % funciones que permiten calcular los diferentes valores:
        % =========================================================================
%          Cromosomas
%         Cromosomas(:,recorrido)
%          pause
%         %         % en cu�l instante se sembr� un producto
%                 Cromosomas(:,recorrido)~=0;
%         %         % Cu�les productos han sido sembrados
%                 Cromosomas(Cromosomas(:,recorrido)~=0,recorrido);
%         %         % Cu�l es la duraci�n del producto en semanas (tiempo de maduraci�n)
%                 PMS(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido));
%         %         % Es necesario agregar la semana de preparaci�n del terreno
%                 PMS(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))+1;
%                 pause
%         %         % �cu�nto es el tiempo acumulado (el instante en el cual se espera recoger
%         %         % y vender el producto)
        % =========================================================================
        restricciones_tiempo=0;
        % Se determina si la soluci�n excede el horizonte de planeaci�n
        if sum(cumsum(PMS(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))+1)>T*4)>=1
            % Determinar cu�ntos productos en cada lote exceden el
            % horizonte de planeaci�n
            % Sumo la cantidad de veces que excede el horizonte de
            % planeaci�n
            restricciones_tiempo=sum(cumsum(PMS(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))+1)>T*4);
            % transformo el valor de recogida de la �ltima soluci�n por el valor m�ximo
            % del horizonte de planeaci�n, con el prop�sito de determinar el precio de
            % venta y calcular las penalizaicones por holguras, para ello construyo una
            % varible auxiliar:
            periodo=cumsum(PMS(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))+1);
            %  reemplazo el valor del tiempo de recogida del �ltimo producto
            periodo(find(periodo>T*4))=T*4;
            % % �Cu�l es el precio de venta por kilo para cada producto?
            % diag(precio_venta(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido),periodo));
            % % �Cu�nta fue  la cantidad de kilos recogida de cada producto?
            % rendimiento(lote,Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))'*areas(lote);
            % % �Cu�nto fue el dinero recibido por la venta de cada producto?
            % rendimiento(lote,Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))'*areas(lote).*diag(precio_venta(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido),periodo));
            % % �Cu�nto fue el ingreso de la venta de todos los productos?
            % sum(rendimiento(lote,Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))'*areas(lote).*diag(precio_venta(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido),periodo)));
            % % Se agrega el valor de venta de cada individuo, para todos los lotes
            % % tratados
            % Almaceno el valor de la primera funci�n objetivo (mazimizar ingresos) en
            % la variable de salida:
            Matriz_objetivos(2,individuo)=Matriz_objetivos(2,individuo)+sum(rendimiento(lote,Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))'*areas(lote).*diag(precio_venta(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido),periodo)));
            % para cada lote, se almacena la cantidad de producto cosechado
            Matriz_productos(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido)')=Matriz_productos(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido)')+ (rendimiento(lote,Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))'*areas(lote))';
        else
            Matriz_objetivos(2,individuo)=Matriz_objetivos(2,individuo)+sum(rendimiento(lote,Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))'*areas(lote).*diag(precio_venta(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido),cumsum(PMS(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))+1))));
            % para cada lote, se almacena la cantidad de producto cosechado
            Matriz_productos(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido)')=Matriz_productos(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido)')+ (rendimiento(lote,Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))'*areas(lote))';
        end
        % Se cuantifican la cantidad de periodos de sub utilziaci�n o sobre
        % utilziaci�n del terreno:
        restricciones_holgura=abs((T*4-max(cumsum(PMS(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))+1))));
        
        % Se almacena la cantidad de kilos recogida de cada producto
        kilos= rendimiento(lote,Cromosomas(Cromosomas(:,recorrido)~=0,recorrido))'*areas(lote);
        % �A cu�l grupo de venta pertenece cada producto?
        recorrido2=familia_venta(Cromosomas(Cromosomas(:,recorrido)~=0,recorrido));
        % Se suma la cantidad de veces que no existe rotaci�n de familias
        % bot�nicas:
        rotaciones=rotaciones+sum(recorrido2(2:length(recorrido2))==recorrido2(1:length(recorrido2)-1));
        % Se crea un bucle para almacenar la producci�n en las respectivas
        % familias de venta, con el fin de contrastar con la demanda
        for productos_vendidos=1:length(recorrido2)
            % Se actualiza el valor de la matriz venta
            Matriz_venta(recorrido2(productos_vendidos))=Matriz_venta(recorrido2(productos_vendidos))+kilos(productos_vendidos);
        end
        % Se evaluan variables una vez finalizado el recorrido por todos
        % los lotes para cada ndividuo.
        if lote==cant_lotes
            % Se actualiza el valor de la funci�n fitness
            Matriz_objetivos(1,individuo)= -...
                restricciones_tiempo -...
                restricciones_holgura -...
                sum(Matriz_venta-demanda.*Matriz_venta>demanda) - ...
                rotaciones; 
            Matriz_objetivos(2,individuo)=Matriz_objetivos(1,individuo)+Matriz_objetivos(2,individuo);
            % Se calcula el riesgo del portafolio
            Matriz_objetivos(3,individuo)=Matriz_productos*Covkkp*Matriz_productos'+Matriz_objetivos(1,individuo);
        end
    end
end

end

