#-
# # Análisis con intervalos 1

#-
# > Ref: W. Tucker, Validated Numerics: A Short Introduction to Rigorous Computations, Princeton University Press, 2011

#-
# ## Funciones evaluadas en intervalos

#-
# Uno de los objetivos principales de la aritmética de intervalos es obtener una estimación que contenga el *rango* de una función $f$ en un dominio (intervalo) especificado. El rango de una función $f$ sobre $D\subset \mathbb{R}$, que denotaremos por $R(f; D)$, es el conjunto de puntos que se obtiene al evaluar $f(x)$ para todo $x\in D$.

#-
# Como primer paso, extenderemos la definición de una función a funciones de intervalos. Esencialmente, esto corresponde a extender las funciones a tomar y devolver intervalos en lugar de números (reales). Con lo visto hasta ahora, esto lo podemos hacer para funciones racionales que no tengan ceros en el denominador, es decir, $f(x)=p(x)/q(x)$, donde $p(x)$ y $q(x)$ son polinomios en $x$ y $q(x)\neq 0$ para toda $x\in [x]$. Esto lo obtenemos simplemente al sustituir $x$ por $[x]$ en todas las ocurrencias de $x$ en $p(x)$ y $q(x)$, gracias a que hemos extendido las operaciones aritméticas elementales incluyendo las potencias con exponentes enteros. Esto lo obtuvimos explotando que las operaciones aritméticas son monotónicas respecto a uno de los argumentos, considerando al otro fijo. De esta manera podemos hablar de la extensión *natural* a intervalos, $F([x])$, y tenemos que $R(f; [x])\subseteq F([x])$ por la propiedad de monotonicidad isotónica.

#-
# Al igual que para las operaciones aritméticas, la propiedad que explotaremos para extender funciones a intervalos es la *monotonicidad* por segmentos. En efecto, si una función $f$ es monotóna (creciente o decreciente) en un intervalo $[x]$, entonces podemos extender $f(x)$ a $F([x])$ al evaluar $f$ en los extremos del intervalo. En este caso tenemos que $R(f,[x]) = F([x])$, y entonces la extensión a intervalos es *estrecha* en el sentido de que se cumple la igualdad.

#-
# Dado que las *funciones estándar* que usamos ($\sqrt{x}$, $\exp(x)$, $\log(x)$, $x^{p/q}$, $\sin(x)$, $\cos(x)$, $\tan(x)$, $\dots$, $\arcsin(x)$, $\arccos(x)$, $\arctan(x)$, $\dots$, $\sinh(x)$, $\cosh(x)$, $\dots$, $\textrm{arcsinh}(x)$, $\textrm{arccosh}(x)$, $\dots$) justamente son monótonas *por segmentos*, entonces las usaremos como los elementos básicos para construir otras más complejas, que es lo que llamaremos las *funciones elementales*, y que se obtienen a partir de la composición de funciones estándar y de operaciones aritméticas.

#-
# Entonces, para las funciones estándar estrictamente monótonas, podemos definir la extensión a intervalos de funciones como:
# $$
# \begin{align*}
# \sqrt{[x]} & = [\sqrt{\underline{x}}, \sqrt{\overline{x}}], & \underline{x}\ge 0,\\
# \exp([x]) & = [\exp(\underline{x}), \exp(\overline{x})], & \\
# \log([x]) & = [\log(\overline{x}), \log(\underline{x})], & \underline{x} > 0, \\
# \arctan([x]) & = [\arctan(\underline{x}), \arctan(\overline{x})]. &
# \end{align*}
# $$

#-
# Para funciones estándar que no son estrictamente monótonas, como $\sin(x)$, descompondremos primero el intervalo $[x]$ (el dominio) en segmentos donde la función cumple la monotonicidad y usamos en cada uno de estos segmentos para obtener el rango apropiado a ese segmento; esto es equivalente, en algún sentido, a localizar los máximos y mínimos de la función. Y, finalmente, usamos la cáscara (*hull*) de las evaluaciones intervalares de la función en los distintos segmentos.

#-
# Un ejemplo de esto es la extensión de la función $\sin(x)$. Partimos de la definición de $S_+=\{ 2\pi k + \pi/2: k\in \mathbb{Z}\}$ y $S_-=\{ 2\pi k - \pi/2: k\in \mathbb{Z}\}$, que corresponden a los conjuntos donde se localizan los máximos y mínimos de $\sin(x)$, entonces escribimos:
# $$
# \sin([x]) = \begin{cases}
# \begin{align*}
# & [-1,1],
# & \textrm{si } [x]\cap S_+ \neq [\emptyset] \textrm{ y } [x]\cap S_- \neq [\emptyset],\\
# & [-1, \max(\sin(\underline{x}), \sin(\overline{x}))],
# & \textrm{si } [x]\cap S_+ = [\emptyset] \textrm{ y } [x]\cap S_- \neq [\emptyset],\\
# & [\min(\sin(\underline{x}), \sin(\overline{x})), 1],
# & \textrm{si } [x]\cap S_+ \neq [\emptyset] \textrm{ y } [x]\cap S_- = [\emptyset],\\
# & [\min(\sin(\underline{x}), \sin(\overline{x})), \max(\sin(\underline{x}), \sin(\overline{x}))],
# & \textrm{si } [x]\cap S_+ = [\emptyset] \textrm{ y } [x]\cap S_- = [\emptyset].\\
# \end{align*}
# \end{cases}
# $$

#-
# El primer caso corresponde a un intervalo $[x]$ que incluye al menos a un mínimo y a un máximo de $\sin(x)$. El segundo caso ocurre si $[x]$ contiene a un mínimo, pero a ningún máximo, mientras que el tercero corresponde al caso en que $[x]$ incluye un máximo pero ningún mínimo. Finalmente, en el último caso, $[x]$ no incluye ningún máximo o mínimo de $\sin(x)$.

#-
# La evaluación de funciones elementales se hace, como lo haríamos a mano, descomponiendo la función en un árbol de subexpresiones más sencillas, que descomponemos sucesivamente, hasta llegar a la evaluación de funciones estándar. Esta descomposición se conoce como el grafo directo acíclico (DAG, por sus siglas en inglés).

#-
# Para ejemplificar el concepto del DAG, utilizaremos la paquetería [`TreeView.jl`](https://github.com/JuliaTeX/TreeView.jl) junto con [`TikzGraphs.jl`](https://github.com/JuliaTeX/TikzGraphs.jl). Nos interesa visualizar el DAG de
# $$
# f(x) = (x^2 - \sin(x)) * (x^7 + 3\sin(x^2)).
# $$

using Pkg
Pkg.activate(".") # estamos en el directorio `docs`
Pkg.instantiate()  # Hay nuevos paquetes que usaremos !

#-
# Primero representamos simplemente el árbol de las operaciones

using TreeView
@tree (x^2 - sin(x)) * (x^7 + 3sin(x^2))

#-
# Ahora mostramos el DAG:

@dag (x^2 - sin(x)) * (x^7 + 3sin(x^2))

#-
# La idea, entonces, es substituir $x$ por el intervalo $[x]$ en cada subexpresión, empezando en las hojas del árbol. Sin embargo, y por las propiedades intrínsecas de los intervalos (*el problema de la dependencia*), la extensión a intervalos $F$ que se obtiene depende de la representación particular de $f$. Esencialmente lo que esto impone es que, si la variable $x$ aparece más de una vez, podemos espera que el problema de la dependencia aparecerá, y el rango de la función estará contenido en $F([x])$, pero no de manera estrecha. El punto importante es que el rango $R(f; x)$ está contenido en la extensión a intervalos $F([x])$ por la inclusión isotónica.

#-
# **Teorema** (Teorema fundamental de la aritmética de intervalos). Dada una función elemental $f(x)$ y su extensión natural a intervalos $F$ de tal manera que $F([x])$ está bien definida para algún $[x]\in \mathbb{IR}$, entonces se cumple:
#
# 1. $[z]\subseteq [z']\subseteq [x] \Rightarrow F([z])\subseteq F([z'])$, i.e., inclusión monótona,
# 1. $R(f; x) \subseteq F([x])$, i.e., inclusión de rango.

#-
# La importancia de este teorema es que tenemos una manera de acotar el rango de funciones elementales; si bien $R(f;[x])$ es difícil de obtener, el rango estará contenido en la extensión a intervalos de la función $F([x])$. Este resultado puede ser explotado considerando su negativo: Si $y\notin F([x])$ entonces $y\notin R(f;[x])$. Esta última formulación será muy útil cuando busquemos los ceros de una función $f(x)$, ya que si $0\notin F([x])$ entonces sabremos que $[x]$ no incluye ningún punto tal que $f(x)=0$.

#-
# Para ilustrar esto, en el siguiente ejemplo consideraremos la función
# $$
# f(x) = (\sin(x) - x^2 + 1) \cos(x),
# $$
# en el intervalo $[0, 1/2]$, y para hacernos la vida más sencilla usaremos las paqueterías [`IntervalArithmetic.jl`](https://github.com/JuliaIntervals/IntervalArithmetic.jl) (ver [aquí](https://juliaintervals.github.io/pages/tutorials/tutorialArithmetic/) para un tutorial) y la paquetería [`Plots.jl`](https://github.com/JuliaPlots/Plots.jl).
using IntervalArithmetic

#-
f(x) = (sin(x) - x^2 + 1)*cos(x) # La función que evaluaremos

#-
a = Interval(0, 0.5)   # Creamos un intervalo; hay distintas formas de hacer esto

#-
Fa = f(a)  # Evaluamos la función en el intervalo `a`

#-
# El resultado anterior demuestra, en un sentido matemático(!), que $f(x)$ en el intervalo $[0,1/2]$, no tiene ceros.

#-
using Plots

#-
box_a = IntervalBox(a, Fa) # creamos una `caja` de intervalos

#-
plot(box_a, label="F([a])")
plot!(a.lo:1/128:a.hi, f, lw=2, color=:red, label="f(x)")

#-
# Como se muestra en la gráfica anterior, la extensión a intervalos de $f(x)$ produce un intervalo demasiado ancho en comparación con el rango de la función; esto está representado por la caja azul. Esta observación de que $F([x])$ es exagerada respecto a $R(f; [x])$ es una consecuencia del problema de la dependencia. Una manera de mejorar esta exageración es *subdividiendo* $[x]$ en intervalos menos anchos; la evaluación de $F$ en estos subintervalos dará en general cotas menos exageradas para cada uno de ellos, y su unión (en el sentido del `hull`) resultará en una cota más estrecha para el rango.
a_minced = mince(a, 4)   # dividimos `a` en 4 intervalos iguales

#-
Fav = f.(a_minced) # evaluamos `f` en cada uno de los subintervalos

#-
Fa_minced = hull(Fav)

#-
plot(box_a, label="F([a])")  # Dibujamos la caja inicial
plot!(IntervalBox.(a_minced, Fav), color=:purple, label="F_i.([a_i])")  # Dibujamos las cajas de subintervalos
plot!(IntervalBox.(a, Fav), color=:orange, label="hull(F_i.([a_i]))")  # Dibujamos las cajas de subintervalos
plot!(a.lo:1/128:a.hi, f, lw=2, color=:red, label="f(x)") # Dibujamos una aproximación de f(x)

#-
# Esto se puede formular de manera más precisa usando el concepto de función Lipschitz: Una función $f:D\rightarrow \mathbb{R}$ es Lipschitz, si existe una constante positiva $K$ (la constante de Lipschitz) tal que, para todos $x, y\in D$ se cumple $|f(x)-f(y)|\le K|x-y|$. Una función Lipschitz es continua pero puede no ser diferenciable; si lo es, el módulo de la derivada está acotado por $K$.

#-
# **Teorema** (Acotamiento del rango). Consideremos $f:I\to\mathbb{R}$ una función cuyas subexpresiones son todas Lipschitz, y sea $F$ una extensión de intervalos que es monótona isotónica de $f$, tal que $F([x])$ está bien definida para algún $[x]\subset I$. Entonces, existe un $K$ que depende de $F$ y de $[x]$ tal que si $[x]=\bigcup_{i=1}^k [x^{(i)}]$, entonces
# $$
# \begin{equation*}
# R(f; [x]) \subseteq \bigcup_{i=1}^k F([x^{(i)}]) \subseteq F([x]),
# \end{equation*}
# $$
# y
# $$
# \begin{equation*}
# \textrm{rad}\Big(\bigcup_{i=1}^k F([x^{(i)}])\Big) \leq \textrm{rad}\big(R(f; [x])\big) +
# K\max_{i=1\dots k} \textrm{rad}\big([x^{(i)}]\big).
# \end{equation*}
# $$

#-
# La segunda propiedad del teorema dice que, si las condiciones se satisfacen, entonces la sobreaproximación del rango tiende a cero no más lento que linealmente al contraerse el dominio.

# ---

# ## Formas centrales

# En ciertas ocasiones, uno puede mejorar la sobreestimación del rango, es decir, hacer que tienda a cero más rápido que lineal a medida de que el dominio disminuye. Esto es  posible si la función $f(x)$ satisface el Teorema del Valor Medio.

#-
# **Teorema** (Teorema del valor medio). Si la función $f$ es continua en $[a,b]$ y diferenciable en $(a,b)$, entonces existe un valor $\zeta \in [a,b]$ tal que $f^\prime(\zeta) = (f(b)-f(a))/(b-a)$.

#-
# Suponiendo que la función $f:[x]\to\mathbb{R}$ satisface las hipótesis del Teorema del Valor Medio, entonces si $x$ y $c$ son puntos en el intervalo $[x]$, existe un punto $\zeta$ entre $x$ y $c$ tal que
# $$
# f(x) = f(c) + f'(\zeta) (x-c).
# $$

#-
# Si tenemos una extensión de intervalos para la derivada, $F'([x])$, entonces
# $$
# \begin{align*}
# f(x) &= f(c) + f'(\zeta) (x-c) \in f(c) + F'([x]) (x-c)\\
# &\subseteq f(c) + F'([x]) ([x]-c),
# \end{align*}
# $$
# donde la última expresión es independiente de $x$ y $\zeta$. Entonces, para toda $x$ y $c$ en $[x]$ tenemos
# $$
# R(f; [x]) \subseteq f(c) + F'([x]) ([x]-c) \equiv F([x];c).
# $$

#-
# La extensión de intervalos $F([x]; c)$ se conoce como *forma central*, y la elección más típica para $c$ es la del punto medio del intervalo $[x]$, i.e. $\textrm{mid}([x])$. Esta elección produce la *forma del valor medio* $F_m([x])$ dada por
# $$
# F_m([x]) = F(m) + F'([x]) ([x]-m) = F(m) + F'([x]) [-r,r],
# $$
# donde $m$ es el punto medio y $r$ es el radio del intervalo.

#-
# **Teorema** (Teorema de la cota de la forma central). Consideremos $f:I\to\mathbb{R}$ que satisface las hipótesis del Teorema del Valor Medio, y sea $F'$ la extensión a intervalos de $f'(x)$ de tal manera que $F'([x])$ está bien definida para algún $[x]\subseteq I$.  Entonces, si $c \in [x]$ tenemos
# $$
# R(f; [x]) \subseteq F([x]; c)
# $$
# y
# $$
# \textrm{rad}\Big(F([x];c))\Big) \leq \textrm{rad}\big(R(f; [x])\big) +
# 4\textrm{rad}\big(F'([x])\big)\, \textrm{rad}([x]).
# $$
# Si la forma del valor medio se usa, el factor 4 debe reemplazarse por 2; esto muestra que la simetría de la forma central es útil.

#-
# Como ejemplo consideraremos $f(x) = (x^2+1)/x$, de donde
# $f'(x)=(x^2-1)/x^2$ y evaluaremos en el intervalo $[x]=[1,2]$.

using IntervalArithmetic

#-
f(x) = (x^2+1)/x
f′(x) = (x^2-1)/x^2
xI = 1 .. 2  # Esto es equivalente a `Interval(1,2)`

#-
fxI = f(xI)

#-
diam(fxI)

#-
"""
    forma_valormedio(f, f′, I)
Calcula el rango de `f` en `I` usando la forma valormedio; requiere
la forma funcional de la derivada de `f`, dada en `f′`.
"""
function forma_valormedio(f, f′, I)
    m = mid(I)
    c = m .. m # Incluye redondeo!
    #Lo siguiente es equivalente a las dos líneas anteriores
    #c = IntervalArithmetic.atomic(Interval{Float64}, mid(I))
    return f(c) + f′(I)*(I-c)
end

fc = forma_valormedio(f, f′, xI)

#-
diam(fc)

#-
# La forma del valor medio `fc` da un resultado más estrecho que `fxI`, que es la manera *ingenua* de evaluar el rango de $f(x)$ usando aritmética de intervalos directamente. Sin embargo, uno puede observar que el ínfimo de `fxI` es *mejor* que el dado por la forma del valor medio `fc`, en el sentido de que es mayor que el ínfimo producido por `fc`. Entonces, una mejor cota para el rango se puede obtener de la intersección de ambos resultados, `fxI ∩ fc`:

fxI ∩ fc

#-
# ## Monotonicidad a través de la derivada

#-
# Anteriormente vimos que la monotonicidad permite obtener cotas estrechas
# del rango. La monotonicidad se puede inferir a partir de la derivada, la cual
# es requerida para calcular la forma central. Entonces, si $f^\prime([x])$
# cumple ser mayor/menor o igual a cero (el cero sólo puede ocurrir en los
# extremos del intervalo $[x]$), tenemos que la función $f(x)$ es creciente/decreciente
# en $[x]$, y en este caso el rango de la función es:
# ```math
# R(f; [x]) = \begin{cases}
# \begin{align*}
# &[f(\underline{x}), f(\overline{x})], &\textrm{ si } \min\big(F^\prime([x])\big)\geq 0,\\
# &[f(\overline{x}), f(\underline{x})], &\textrm{ si } \min\big(F^\prime([x])\big)\leq 0.
# \end{align*}
# \end{cases}
# ```

#-
# Usando el ejemplo anterior, tenemos que

f′(xI) ≥ 0

# de donde la función es estrictamente creciente y el rango de $f(x)$ se puede determinar de manera estrecha a partir de los límites de los bordes del intervalo $[x]$:

Interval( f(xI.lo), f(xI.hi) )

# Claramente, el rango obtenido es el más estrecho de los anteriores y corresponde al rango de $f(x)$. Esto ilustra un hecho más general: cuánto más conozcamos la función, en general, podemos acotar su rango.

# ---

# ## Bibliografía

#-
# - W. Tucker, Validated Numerics: A Short Introduction to Rigorous Computations, Princeton University Press, 2001.
