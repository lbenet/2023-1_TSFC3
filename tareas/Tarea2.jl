# # Tarea 2

#-
# > **Fecha de entrega** (aceptación del *Pull Request*): 25 de noviembre
#

#-
# > **NOTA:** Esta tarea requiere que suban código que escribirán en los archivos
# > que se indican en los enunciados, y que deberán estar en el *subdirectorio*
# `Intervalos/src/subdir_equipo/`.
# > El código deberá estar adecuadamente documentado usando
# > [docstrings](https://docs.julialang.org/en/v1/manual/documentation/#Writing-Documentation),
# > o en su defecto, comentarios.
# > Para la aprobación de la tarea se requiere que pasen **todos** los tests que, nuevamente,
# > se verificarán automáticamente en GitHub.

#-
# ### Ejercicio 1: `Intervalo` y `ForwardDiff`
#
# Modifiquen la estructura `Intervalo` de tal manera que uno pueda calcular derivadas
# usando `ForwardDiff.derivate(f, dom)`, con `dom` un `Intervalo`. El requisito básico
# que `ForwardDiff` impone es que el tipo (en este caso `Intervalo`) sea un subtipo de `Real`.
# La paquetería `ForwardDiff` deberá ser cargada (`using`) desde su módulo para intervalos.
# Eventualmente, notarán que resultará además necesario sobrecargar dos funciones
# más; lean con cuidado los tests que no pasan y traten de entender los
# errores que aparecen para sobrecargar las funciones necesarias.
#
# Estas modificaciones deben únicamente aparecer en su archivo `intervalos.jl`.

#-
# ### Ejercicio 2: Verificando la monotonicidad
#
# Escriban la función `esmonotona(f,D)` que verifica si una función $f(x)$ es
# monótona en el intervalo $D$, explotando de manera adecuada `ForwardDiff`. El resultado de la
# función debe ser `true` o `false`, es decir, del tipo `Bool`. Incluyan esta función
# en su archivo `intervalos.jl`. Noten que el resultado de su implementación puede
# no coincidir con el matemático que uno espera, lo que resulta de la implementación
# que hemos hecho del redondeo, que es demasiado exagerado.

#-
# ### Ejercicio 3: Método de Newton intervalar extendido en 1d
#
# El código que corresponde a este ejercicio deberá escribirse en un nuevo archivo `raices.jl`.
# Este archivo deberá ser llamado (usando `include`) desde su archivo `intervalos.jl` y ahí
# exportarán las funciones que sean necesarias para que los tests pasen.
# - Definan una estructura `Raiz` que incluya dos campos, `raiz::Intervalo{T}` y `unicidad::Bool`.
#    *Puede* ser útil parametrizar el tipo.
# - Escriban una (o varias) funciones que permitan implementar el método de Newton intervalar
#    *extendido* para una función (de una variable) $f(x)$, dentro del dominio `dom::Intervalo`,
#    con tolerancia `tol`. La función `ceros_newton(f, dom, tol)` deberá ser exportada.
#    El método debe arrojar *todos* los intervalos que son candidatos a incluir una raíz
#    (hasta cierta tolerancia) a través de un *vector* que contiene objetos tipo `Raiz`, y
#    entonces deberá también dar información si la raíz es única o no.
#    El diámetro de los intervalos dentro del vector deberá ser menor que la tolerancia `tol`.
#    Recuerden que es útil filtrar los resultados de manera apropiada.
# - Documenten apropiadamente cada una de las funciones que implementen.
#

#-
# ### Ejercicio 4: Optimización
#
# El objetivo de este ejercicio es escibir una función `minimiza(f, D)` que encuentre el
# mínimo global de la función $f(x)$ en el dominio $D\subset\mathbb{R}$. Esto es, queremos
# obtener el valor $y^*$ que es el mínimo global de la función en $D$, y el lugar en que
# esto ocurre, es decir, $x^*$. Supondremos que $f(x)$ es continua en $D$, y que $D$ es
# un intervalo (conjunto compacto).
#
# La idea del método que implementarán es fijar un valor $\tilde{y}$, que es la cota *superior*
# de prueba para $y^*$ con la que se trabaja (y que se irá ajustando), y excluir subconjuntos
# de $[x_i]\subset D$ en que se satisface $f([x_i]) > \tilde{y}$, es decir, que no incluyen
# al mínimo global de $f$. Inicializaremos el método considerando $E^{(0)}=D$ (conjunto inicial
# donde se busca el mínimo) y $y^* = +\infty$. En el paso $k$ tendremos $y^*\leq \tilde{y}^{(k)}$
# y los candidatos
# $$
# E^*\subseteq \{ x\in D: f(x)\leq \tilde{y}^{(k)}\} \subseteq E^{(k)} = \bigcup_{i=1}^{N_k}D_i^{(k)},
# $$
# del conjunto que minimiza. Para cada uno de estos candidatos $D_i^{(k)}$ procederemos así:
# - Calculamos $[y_i]=F(D_i^{(k)})$.
# - Verificamos si se cumple $\tilde{y}^{(k)} < \underline{[y_i]}$ (se compara con el ínfimo
#    de [y_i]). Si sí es el caso (es decir, si la extensión intervalar de $[y_i] = f(D_i^{(k)})$
#    está por arriba de $y^*$), eliminamos el intervalo $D_i^{(k)}$ de la lista de candidatos.
#    De lo contrario, calculamos el valor de la función en el punto medio de ese intervalo,
#    $m_i=f\big(\textrm{mid}(D_i^{(k)})\big)$ y lo comparamos con $\tilde{y}^{(k)}$.
#    Si $m_i<\tilde{y}^{(k)}$ entonces asignamos $\tilde{y}\leftarrow m_i$.
#    Independientemente de la comparación que involucra $m_i$, bisectaremos $D_i^{(k)}$, y
#    añadimos los intervalos a la lista de candidatos.
# - Estos pasos se repiten para cada elemento de la lista de candidatos $D_i^{(k)}$.
#    Una vez que se concluye se fija $\tilde{y}^{(k+1)}=\tilde{y}$.
# - El proceso se repite hasta que se satisfaga un criterio para parar el algoritmo definiendo
#    una tolerancia. En este caso, definiremos el criterio usando el diámetro de los intervalos
#    $D_i^{(k)}$.
#  - Explotando la función `minimiza`, escriban una función `maximiza`.
#
# Todas las funciones que requieran para completar este ejercicio deberán ser incluidas en el
# archivo `optimizacion.jl`, que deberá ser llamado desde `intervalos.jl`. Documenten todas las
# funciones apropiadamente que escriban.
