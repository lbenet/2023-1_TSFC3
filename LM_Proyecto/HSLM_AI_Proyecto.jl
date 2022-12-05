# Proyecto: Implementación del concepto de ''caja''.

#Descripción: En este proyecto se busca implementar el concepto de "caja", 
#el cual se refiere al producto carteriano de n intervalos.
#Además, se pretende extender el concepto a n-dimensiones

#Por otro lado, se pretende que esta estructura sea lo suficientmente
#adecuada para poderla utilizar en alguna aplcación, por ejemplo, en 
#la busqueda de ceros de sistemas de ecuaciones.

###########################################################

## Introducción

# Un n-dimensional vector de intervalos: Este se refiere a un vector cuyos 
# elementos son intervalos. En el caso de un vector de intervalos 2-Dimensional
# se tiene algo como X=(Intervalo(x1,X1),Intervalo(x2,X2)).

# Luego, este vector de intervalos (2-dimensional) se puede visualizar en el plano 
# cartesiano como el rectangulo que contine el conjunto de puntos que cumplen que
# x1<x<X1 y x2<y<X2. Vemos que esto corresponde justamente al producto cartesiano 
# de los intervalos dentro del vector de intervalos y más aún, si pensamos en un 
# vector de intervalos 3-dimensional podemos ver que lo que se representa en el plano
# cartesiano es el conjunto de puntos contenidos en una "caja".

## Propiedades:
# 1. Si x=(x1,x2,...,xn) es un conjunto de valores reales y X=(X1,...Xn) es n vector de
# intervalos, entonces decimos que x está contenido en X si xi pertenece a Xi para i=1,..,n.

#         x \in X si x_i \in X_i para i=1,\cdots,n

# 2. La intersección de dos vectores de intervalos es vacía si cualqueira de las 
# intersecciones Xi ∩ Yi, i=1,..n, es vacía. Dr otra forma se tiene que la intersección
# entre los vectores de intervalos corresponde al vector de intervalos cuyas entradas
# son Xi ∩ Yi, i=1,..n.

#         X_i \cap Y_i=(X_1 \cap Y_1,X_2 \cap Y_2,\cdots,X_n \cap Y_n)

# 3. Si X=(X1,...Xn) y Y=(Y1,...Yn) son vectores de interavalos entonces se dice que X 
# está contenido en Y si Xi está contenido en Yi, i=1,..,n.

#         X \supset Y si  X_i \supset Y_i para i=1,\cdots,N

# 4. El ancho de un vector de intervalos X=(X1,...Xn) se define como el ancho
# más grande de sus componentes.

#         diam(X)=max(diam(X_i)), i=1,\cdots, n

# 5. El punto medio de un vector de intervalos X=(X1,...Xn) se define como el vector
# cuyas entradas son los puntos medios de cada Xi.

#         mid(X)=(mid(X1),mid(X2),...,mid(X3))

# 6. La norma de un vector de intervalos X=(X1,...Xn) se define como el máximo de los valores
# absolutos de las componentes de cada intervalo.

#         ||X||=max(max(abs(X_i))), i=1,...,n

##  Funciones a implementar