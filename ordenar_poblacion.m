function [  OP_Cromosomas, OP_Matriz_objetivos, OP_criterio_evaluacion ] = ordenar_poblacion(  OP_Cromosomas, OP_Matriz_objetivos, OP_cant_objetivos )
% La función clasifica la población actual basada en la no dominancia.
% Todos los individuos en el primer frente reciben un rango de 1, a los
% individuos del segundo frente se les asigna el rango 2 y así
% sucesivamente. Después de asignar el rango se calcula la distancia de
% apilamiento.
%%
% Se cargan las variables en la función
OP_Cromosomas=OP_Cromosomas;
OP_cant_objetivos=OP_cant_objetivos;
% para comodidad e cálculos, se almacena el conjunto de valores de las
% funciones objetivo en una variable auxiliar.
x=OP_Matriz_objetivos';
% Para el ordenamiento se utiliza solamente los objetivos de maximizar
% ingresos y disminuir riesgo.
x=x(:,2:OP_cant_objetivos+1);
% por comodidad de cálculo, los valores de la función de maximizar son
% premultiplicados por -1 con el propósito de codificar el cálculo en
% funcion de variables de minimización
x(:,1)=-x(:,1);

% se extrae la cantidad de individuos a organizar
[N, ~] = size(x);

% se utiliza una variable auxiliar para hacr cálculos con los frnetes de
% cada objetivo (se reemplaza ocn el fin de facilitar la escritura dle
% código)
M=OP_cant_objetivos;
% Se inicializa un contador de frentes de pareto
frente = 1;
% se cosntruyen dos estructuras para almacenar la dominancia y frente al
% que pertenecen los individuos
F(frente).f = [];
individuo = [];

%% Conformación del frente de pareto.
% para cada par de individuos (incluyendo el individuo en sí), se realzia
% una comparación de sus objetivos, con el propósito de determinar la
% dominanci.

% Para cada individuo i
for i = 1 : N
    % Número de individuos que dominan a este individuo
    individuo(i).n = 0;
    % Número de individuos que domina este individuo
    individuo(i).p = [];
%     para cada individuo j
    for j = 1 : N
%         contadores de cominancia
        domina_menos = 0;
        domina_igual = 0;
        domina_mas = 0;
%         para cada objetivo
        for k = 1 : M
%             se compara el valor del objetivo k, entre el dindividuo i e
%             individuo j
            if (x(i, k) < x(j, k))
                domina_menos = domina_menos + 1;
            elseif (x(i, k) == x(j, k))
                domina_igual = domina_igual + 1;
            else
                domina_mas = domina_mas + 1;
            end
        end
%         se determina la dominancia entre cada par de individuos
        if domina_menos == 0 && domina_igual ~= M
            individuo(i).n = individuo(i).n + 1;
        elseif domina_mas == 0 && domina_igual ~= M
            individuo(i).p = [individuo(i).p j];
        end
    end
%     si el individuo i no es dominado, se le asigna el individuo i al
%     frente f
    if individuo(i).n == 0
        x(i,M +  1) = 1;
        F(frente).f = [F(frente).f i];
    end
end

% Una vez formado los frentes mediante la identificación de dominancia, son
% organizados (rank) los individuos de cada frente, para posteriormente
% calcular la distancia de apilamiento:

% mientras existan individuos en cada frente
while ~isempty(F(frente).f)
%     se crea una variable auxiliar para almacenar a lso individuos
    Q = [];
%     se realiza un recorrido por todos los miembros del frente
    for i = 1 : length(F(frente).f)
%         si el individuo domina a otro
        if ~isempty(individuo(F(frente).f(i)).p)
%             se compara la dominancia de lso individuos en el frente
            for j = 1 : length(individuo(F(frente).f(i)).p)
                individuo(individuo(F(frente).f(i)).p(j)).n = individuo(individuo(F(frente).f(i)).p(j)).n - 1;
%                 se actualzian los valores de dominancia para los
%                 individuos del mismo frente y se organizan en la variable
%                 auxiliar Q
                if individuo(individuo(F(frente).f(i)).p(j)).n == 0
                    x(individuo(F(frente).f(i)).p(j),M +  1) = frente + 1;
                    Q = [Q individuo(F(frente).f(i)).p(j)];
                end
            end
        end
    end
%     se pasa al siguiente frente
    frente =  frente + 1;
%     Se actualiza el orden de los individuos según el frente auxiliar Q
    F(frente).f = Q;
end
% se extrae el orden de lso individuos en la varialbe de funciones objetivo
[temp,indice_frentes] = sort(x(:,M +  1));
% se organizan los individuso por cada frente
for i = 1 : length(indice_frentes)
    organizado_por_frentes(i,:) = x(indice_frentes(i),:);
end


%% 
% Distancia de apilamiento
% Se calcula la distancia de apilamiento, para ello se evalúa cada frente
% teniendo en cuenta las funciones objetivo, reorganizando la población en
% cada frente para asignarle a los valores extremos (máximo y mínimo de
% cada individuo en la función objetivo el valor de infinito),
% posteriormente se organizan lso individuos según su distancia.
% se crea un contador
indice_actual = 0;

% para todos los frentes menos el último (el cual está vacio por defecto)
for frente = 1 : (length(F) - 1)
%     se crea una variable de distancia
    distancia = 0;
%     se crea una variable auxiliar para almacenar la distancia de
%     apilamiento en cada frente
    y = [];
%     se crean dos contadores de índices para comparar los individuos
    indice_previo = indice_actual + 1;
%     para todos los individuos que comparten frente
    for i = 1 : length(F(frente).f)
%         se actualizan los individuos en la variable auziliar
        y(i,:) = organizado_por_frentes(indice_actual + i,:);
    end
%     se actualizan los contadores
    indice_actual = indice_actual + i;
%     como se van a organizar por cada función objetivo, se crea una
%     variable auxiliar
    organizado_por_objetivos = [];
%     se recorren todos los objetivos
    for i = 1 : M
%         se extrae la organización de los individuos que pertenecen a cada
% frente, según su valor en la función objetivo M
        [organizado_por_objetivos, indice_de_objetivos] = sort(y(:, i));
%         se borra el contenido de la variable auxiliar
        organizado_por_objetivos = [];
%         para todos los individuos que se están comparando
        for j = 1 : length(indice_de_objetivos)
%             se almacena el orden
            organizado_por_objetivos(j,:) = y(indice_de_objetivos(j),:);
        end
%         se calcula el valor máximo de la función objetivo obtenido por
%         algún individuo en el frente bajo estudio
        f_max = organizado_por_objetivos(length(indice_de_objetivos),  i);
        %         se calcula el valor mínimo de la función objetivo obtenido por
%         algún individuo en el frente bajo estudio
        f_min = organizado_por_objetivos(1,  i);
%         se iguala a infinito los valores de distancia de los individuos
%         extremos
        y(indice_de_objetivos(length(indice_de_objetivos)),M +  1 + i)= Inf;
        y(indice_de_objetivos(1),M +  1 + i) = Inf;
%         se calcula la distancia para todos los individuos que estén en el
%         frente, menos aquellos que pertenecen a los extremos
        for j = 2 : length(indice_de_objetivos) - 1
            objetivo_siguiente  = organizado_por_objetivos(j + 1, i);
            objetivo_previo  = organizado_por_objetivos(j - 1, i);
%             si los valores de la función objetivo es igual a cero, se le
%             asigna una distancia igual a infinito
            if (f_max - f_min == 0)
                y(indice_de_objetivos(j),M +  1 + i) = Inf;
%             si el valor de la función objetivo es diferente, se calcula
%             la distancia de apilamiento
            else
                y(indice_de_objetivos(j),M +  1 + i) = ...
                    (objetivo_siguiente - objetivo_previo)/(f_max - f_min);
            end
        end
    end
%     se reinicia el valor de distancia
    distancia = [];
%     se asigna dimensión a la variable distancia, según la cantidad de
%     individuos en el frente
    distancia(:,1) = zeros(length(F(frente).f),1);
%     se le asigna el valor de distancia según cada objetivo al vector
%     creado
    for i = 1 : M
        distancia(:,1) = distancia(:,1) + y(:,M +  1 + i);
    end
%     se actualiza en la variable y el valor de la distancia
    y(:,M +  2) = distancia;
        y = y(:, M +  2);
%     se almacena el valor de distancia en la variable z, la cual contempla
%     todos los frentes
        z(indice_previo:indice_actual,:) = y;
%         plot(z)
%         drawnow
%         pause
end

OP_criterio_evaluacion(1,:)=x(:,3)';
OP_criterio_evaluacion(2,:)=z()';

end

