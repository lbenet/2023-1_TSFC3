# # Aritmética de intervalos

#-
# ## Motivación

#-
# La idea básica atrás de la aritmética de intervalos es definir operaciones que, a pesar de los errores por redondeo o truncamiento de la computadora, el *intervalo* resultante incluya la respuesta exacta de la operación. Entonces, la aritmética de intervalos es básicamente una aritmética de desigualdades a través de una cota inferior y una superior. Estas cotas son calculadas en la computadora, con números de punto flotante incluyendo el redondeo adecuado. La motivación básica es el hecho de que los números de punto flotante no son continuos. Entonces, la respuesta exacta se encuentra en general entre dos números de punto flotante.

#-
# Como ejemplo, consideremos el cálculo del área de un rectángulo, $A=a\cdot b$, del que conocemos a través de mediciones la longitud de sus lados $a=3.1\pm 0.2$ y $b=10\pm 0.1$. Estas mediciones las podemos interpretar como desigualdades, $2.9 \le a \le 3.3$ y $9.9 \le b \le 10.1$, de donde obtenemos $28.71 = 2.9\cdot 9.9 \le A \le 33.33 = 3.3 \cdot 10.1$. Esto mismo lo podemos escribir como $A=31.02\pm 2.31$.

#-
# De manera equivalente, podemos pensar los lados del rectángulo como intervalos, $[a]=[3.1,3.3]$ y $[b]=[9.9, 10.1]$, y el el área del triángulo como $[A] = [a]\cdot [b] = [28.71, 33.33]$. La aritmética de intervalos justifica esta extensión.

#-
# ---

# ## Intervalos como conjuntos

#-
# Los elementos básicos de la aritmética de intervalos son los intervalos, que definiremos como subconjuntos *cerrados* y *acotados* de la recta real. Usaremos la siguiente notación:
# $$
# [a] = [\underline{a}, \overline{a}] = \left\{ x\in \mathbb{R} :
# \underline{a} \le x \le \overline{a} \right\}.
# $$
# Llamaremos a $\underline{a}$ el *ínfimo* del intervalo $[a]$, y a $\overline{a}$ el supremo.

#-
# El conjunto de estos intervalos lo denotaremos
# $$
# \mathbb{IR} = \left\{ [\underline{a},\overline{a}] :
# \underline{a} \le \overline{a}; \;
# \underline{a}, \overline{a} \in \mathbb{R} \right\}.
# $$

#-
# Vale la pena notar que en esta definición permitimos tener intervalos ``degenerados'' en los que $\underline{a}=\overline{a}$; nos referiremos a estos intervalos como intervalos delgados.

#-
# De la definición anterior, claramente $[-3,4]$ y $[\pi,\pi^2]$ pertenecen a $\mathbb{IR}$, pero no $(2,3]$, $[2,-1]$ *ni* tampoco $[-\infty,0]$. Más adelante veremos que es conveniente extender nuestra definición de $\mathbb{IR}$ para que incluya al último ejemplo; hay también extensiones que buscan incluir a los otros ejemplos.

#-
# Dado que los intervalos son conjuntos, los elementos de $\mathbb{IR}$ heredan las relaciones naturales entre conjuntos, esto es, las operaciones $=$, $\subseteq$, $\subset$, ⪽ (está en el interior), que se definen como:
# $$
# \begin{align*}
# [a] = [b] & \Leftrightarrow  \underline{a}=\underline{b}
#     \textrm{ y } \overline{a}=\overline{b},\\
# [a] \subseteq [b] & \Leftrightarrow  \underline{b}\le \underline{a}
#     \textrm{ y } \overline{a}\le\overline{b},\\
# [a] \subset [b] & \Leftrightarrow  [a] \subseteq [b] \textrm{ y } [a] \neq [b],\\
# [a] ⪽ [b] & \Leftrightarrow  \underline{b} < \underline{a}
#     \textrm{ y } \overline{a} < \overline{b},\\
# \end{align*}
# $$

#-
# Podemos *ordenar* parcialmente el conjunto $\mathbb{IR}$ de distintas formas. Una de éstas es preservando el orden natural de los números reales,a través de $\le$, de la siguiente forma:
# $$
# [a] \le [b] \Leftrightarrow \underline{a}\le\underline{b} \textrm{ y }
# \overline{a}\le\overline{b}.
# $$

#-
# Vale la pena notar que la definición anterior se puede formular como el conjunto
# $$
# [a] \le [b] = \left\{ (\forall a\in [a] \ \exists b\in[b]) \textrm{, y }
# (\forall b\in [b] \ \exists a\in[a]) : a\le b \right\}.
# $$
# El orden así definido es parcial, ya que se puede mostrar que hay intervalos en los que $[a]\nleq [b]$ y $[b]\nleq [a]$.

#-
# Para $a\in\mathbb{R}$ tiene  sentido usar la notación $a\in[b]$ cuando se cumple $\underline{b}\leq a \leq \overline{b}$.

#-
# También podemos extender las nociones de unión e intersección de conjuntos, $\cup$ y $\cap$, a $\mathbb{IR}$, aunque se requiere proceder con cuidado. Por ejemplo, la unión de dos intervalos puede *no* definir un intervalo, por ejemplo, cuando los dos intervalos están suficientemente separados, es decir, son disjuntos. Es por esto que se usará el concepto de *hull* (cáscara), y que se define como el menor intervalo que incluye a todos los elementos de ambos intervalos
# $$
# [a] \sqcup [b] = [\textrm{min}(\underline{a},\underline{b}), \textrm{max}(\overline{a}, \overline{b})].
# $$
# Es claro que el intervalo que se obtiene *incluye* o *contiene* a la unión de los conjuntos representados por los intervalos.

#-
# Para extender la intersección entre dos intervalos es necesario agregar al conjunto vacío a $\mathbb{IR}$, cuya extensión denotaremos $[\varnothing]$, obviamente para poder considerar el caso en que los intervalos sean disjuntos. Con esto, definimos a la intersección como
# $$
# [a] \cap [b] =
# \begin{cases}
# [\varnothing], & \overline{b}<\underline{a} \textrm{ o } \overline{a}<\underline{b}, \\
# [\textrm{max}(\underline{a},\underline{b}), \textrm{min}(\overline{a},\overline{b})], & \textrm{ en otros casos.}
# \end{cases}
# $$

#-
# Dado un intervalo $[a]$, definimos las siguientes funciones *reales* que serán útiles
# $$
# \begin{align*}
# \textrm{rad}(a) & = \frac{1}{2}(\overline{a}-\underline{a}), \;\textrm{radio de }a,\\
# \textrm{mid}(a) & = \frac{1}{2}(\underline{a}+\overline{a}), \;\textrm{punto medio de }a,\\
# \textrm{mag}([a]) & = \textrm{max}\left\{ |x|: x\in [a]\right\}, \;\textrm{magnitud de }a,\\
# \textrm{mig}([a]) & = \textrm{min}\left\{ |x|: x\in [a]\right\}, \;\textrm{mignitud de }a.\\
# \end{align*}
# $$

# Las dos últimas funciones definen cuál es la distancia máxima y mínima del cero (origen) a los elementos del intervalo $[a]$. Claramente, si $0\in[a]$, $\textrm{mig}(a)=0$.

#-
# Combinando las funciones anteriores, podemos definir
# $$
# \textrm{abs}([a]) = \left\{ |x|: x\in[a] \right\} = [\textrm{mig}([a]), \textrm{mag}([a])].
# $$
# Vale la pena notar que, al contrario de las funciones previamente definidas, $\textrm{abs}([a])$ es un intervalo.

#-
# Con las funciones definidas hasta aquí podemos escribir
# $$
# \begin{align*}
# [a] &= [ \textrm{mid}([a])-\textrm{rad}([a]), \textrm{mid}([a])+\textrm{rad}([a])]\\
# & = \textrm{mid}([a]) \pm \textrm{rad}([a]),
# \end{align*}
# $$
# de donde tenemos
# $$
# \begin{equation*}
# x \in [a] \Leftrightarrow |x-\textrm{mid}([a])|\le \textrm{rad}([a]).
# \end{equation*}
# $$

#-
# Claramente, podemos hacer de $\mathbb{IR}$ un espacio métrico, al definir la distancia de Hausdorff entre dos intervalos como
# $$
# d([a],[b]) = \textrm{max}(|\underline{a}-\underline{b}|, |\overline{a}-\overline{b}|)
# $$
# De esta definición tenemos que $d([a],[b])=0$ si y sólo si $[a]=[b]$.

#-
# Usando esta métrica se puede definir la noción de una secuencia convergente para intervalos,

# $$
# \begin{align*}
# \lim_{k\to\infty}[a_k] = [a] & \Leftrightarrow \lim_{k\to\infty} d([a_k],[a]) = 0 \\
#  & \Leftrightarrow \lim_{k\to\infty} \underline{a}_k = \underline{a}, \lim_{k\to\infty} \overline{a}_k = \overline{a} \\
#  & \quad \textrm{ y } \underline{a}_k \le \overline{a}_k\; \forall\, k.
# \end{align*}
# $$

#-
# ---

# ## Aritmética de intervalos reales

#-
# Podemos visualizar a los elementos de $\mathbb{IR}$ no sólo como conjuntos, sino además como una generalización de los números reales. Es por esto que tiene sentido establecer la aritmética en $\mathbb{IR}$.

#-
# La manera más directa es definir las operaciones aritméticas(binarias) en base a la teoría de conjuntos. Así, el resultado de las operaciones binarias aritméticas entre intervalos debe incluir todos los posibles resultados que involucren a cualquier elemento de cada uno de los intervalos, en el orden correspondiente. Esto es, si $\star$ es cualquier operador aritmético binario, $+$, $-$, $\times$ o $\div$, entonces
# $$
# [a] \star [b] = \left\{ a \star b, \forall a \in [a], b \in [b]\right\},
# $$
# con la excepción de que $[a] \div [b]$ sólo está *definido* si $0\notin [b]$.

#-
# La definición anterior no hace evidente que el resultado es *siempre* un intervalo. El hecho de que usamos sólo intervalos cerrados (y continuos), permite usar los bordes de los intervalos para obtener las cotas que sirven para definir las operaciones aritméticas. Uno puede establecer que:
# $$
# \begin{align*}
# [a] + [b] & = [ \underline{a}+\underline{b}, \overline{a}+\overline{b} ],\\
# [a] - [b] & = [ \underline{a}-\overline{b}, \overline{a}-\underline{b} ],\\
# [a] \times [b] & = [
# \textrm{min}(\underline{a}\underline{b}, \overline{a}\underline{b}, \underline{a}\overline{b}, \overline{a}\overline{b}),
# \textrm{max}(\underline{a}\underline{b}, \overline{a}\underline{b}, \underline{a}\overline{b}, \overline{a}\overline{b}) ],\\
# [a] \div [b] & = [a] \times [1/\overline{b}, 1/\underline{b}], \quad\textrm{si }0\notin [b].\\
# \end{align*}
# $$

#-
# Vale la pena mencionar que, implícitamente el concepto de *monoticidad* aparece, esto es, el hecho de que si fijamos uno de los valores que se operan las operaciones aritméticas son monótonas respecto al otro. La monoticidad es importante ya que permite usar sólo los valores extremos del intervalo para obtener el resultado de la operación. Además, como veremos más adelante, la división puede ser *extendida* si el denominador incluye al 0, si permitimos incluir entre los números reales al infinito.

#-
# Una consecuencia de las definiciones anteriores es que se cumplen las propiedades conmutativa y asociativa para la adición y la multiplicación de intervalos. Además, es fácil convencerse que $[0,0]$ y $[1,1]$ son los únicos elementos neutros respecto a la adición y multiplicación de intervalos, respectivamente. Sin embargo, *en general* **no existe** el intervalo inverso bajo la suma o el producto. Por ejemplo, si usamos las definiones de arriba, obtenemos que $[1,3]-[1,3] = [-2,2]\neq [0,0]$, y $[1,3]\div[1,3] = [1/3,3]\neq [1,1]$. Si bien ninguno de los resultados corresponde al intervalo neutro aditivo o multiplicativo, ambos resultados contienen al neutro respectivo.

#-
# Vale la pena también notar que las operaciones aritméticas *pueden* involucrar al intervalo $[\varnothing]$, en cuyo caso el resultado es el mismo intervalo.

#-
# Otra consecuencia importante en la práctica, en particular en la forma en que se hacen los cálculos, es que la propiedad distributiva *no siempre* se cumple, pero lo que sí se cumple es la *propiedad subdistributiva*:
# $$
# [a] \times ([b]+[c]) \subseteq [a]\times [b] + [a] \times [c].
# $$

#-
# Otra propiedad importante en aritmética de intervalos es la llamada monotonicidad de inclusión (*inclusion monotonicity*): Si $[a]\subseteq [a']$, $[b]\subseteq [b']$, y $\star \in \{+, -, \times, \div\}$, entonces
# $$
# [a] \star [b] \subseteq [a'] \star [b'],
# $$
# donde hemos asumido que para la división $0\notin [b]$ ni $0\notin [b']$.

#-
# ---

# ## Aritmética de intervalos *extendida*

#-
# El hecho de que tengamos que excluir al $0$ del denominador al hacer una división entre intervalos es algo incómodo. Una manera de darle la vuelta a esto es pensando que el resultado de $[c] = [a]\div [b]$ es el conjunto
# $$
# [c] = \left\{ c\in\mathbb{R}: a = bc, a\in[a], b\in[b] \right\}.
# $$

#-
# Consideremos $[a] = [1,2]$ y $[b]=[-1,1]$. Separamos $[b]$, en el sentido de conjuntos como $[b]=[-1,0)\cup[0]\cup(0,1]$. Usando la definición anterior para $[c]$,la ecuación $0\cdot c \in [a]$ no tiene sentido, por lo que ignoramos ese caso. Entonces tenemos
# $$
# \begin{align*}
# [c] & = \left\{ c\in\mathbb{R}: a\in [1,2], b\in[-1,0) \right\}
# \cup
# \left\{ c\in\mathbb{R}: a\in [1,2], b\in(0,1] \right\}\\
# & = (-\infty, -1] \cup [1,\infty),
# \end{align*}
# $$
# es decir, $\mathbb{R}$ \\ $(-1,1)$.

#-
# Claramente, para poder tener a cero en el denominador en una división, requerimos la noción de infinito en $\mathbb{R}$.

#-
# En la *extensión proyectiva*, uno considera la compactificación de $\mathbb{R}$ en el círculo (de radio 1, centrado en (0,1/2)), al considerar la intersección sobre el círculo de la recta que une al punto $x\in\mathbb{R}$ con el polo norte del círculo. Esto introduce un nuevo punto, cuya proyección es el polo norte, que identificamos con el infinito (¡sin signo!). Esta extensión, $\mathbb{R}^*$,  permite que podamos escribir $[c]$ en el ejemplo de arriba como un *intervalo extendido*, $[1, -1]$, donde este intervalo se entiende como los puntos en que $x\ge 1$ o $x\le -1$.

#-
# La *extensión afín* consiste en dotar de signo a infinito en la extensión de los reales, y se denota como $\overline{\mathbb{R}}$. Esto permite extender $\mathbb{R}$ para que los intervalos $[2,+\infty]$ o $[-\infty, +\infty]$ tengan sentido. Esta es la extensión que solemos, ingenuamente, usar. En este caso, $[c]$ no es un intervalo, pero la división se puede extender resultando en la unión de dos intervalos bien definidos. El conjunto de intervalos formados por esta extensión de los reales se denota $\overline{\mathbb{IR}}$.

#-
# Finalmente, mencionamos la *extensión del cero con signo*, y que ha sido empujada por los manufacturadores de computadoras, y que es la que usaremos en cuestiones numéricas. Lo "feo" de esta extensión es que al incluir un signo para el cero, $+0$ y $-0$ son dos números reales *distintos* aunque se comparen igual. Una ventaja es que $+\infty$ y $-\infty$ tendrán un inverso bien definido y distinto en cada caso.

#-
# Vale la pena mencionar que en cualquiera de estas extensiones, operaciones como $(\pm)\infty-(\pm)\infty$, $(\pm)\infty/(\pm)\infty$, o $(\pm)0\cdot (\pm)\infty$ son indefinidas.

#-
# La división se puede extender si uno considera estas extensiones de los reales. El resultado en los casos en que el denominador incluye el cero se vuelve más cómoda en $\overline{\mathbb{IR}}$, aunque en varios casos el resultado corresponde a la unión de intervalos. La división extendida la definimos como:
# $$
# [a]\div[b] = \begin{cases}
# \begin{align*}
# & [a] \times [1/\overline{b}, 1/\underline{b}], &\textrm{si }& 0\notin [b], \\
# & [-\infty,+\infty], &\textrm{si }& 0\in[a] \textrm{ y } 0\in[b], \\
# & [\overline{a}/\underline{b}, +\infty], &\textrm{si }& \overline{a}<0 \textrm{ y } \underline{b}<\overline{b}=0, \\
# & [\overline{a}/\underline{b},+\infty]\cup[-\infty,\overline{a}/\overline{b}], &\textrm{si }& \overline{a}<0 \textrm{ y } \underline{b}<0<\overline{b}, \\
# & [-\infty, \overline{a}/\overline{b}], &\textrm{si }& \overline{a}<0 \textrm{ y } 0=\underline{b}<\overline{b}, \\
# & [-\infty, \underline{a}/\underline{b}], &\textrm{si }& 0<\underline{a} \textrm{ y } \underline{b}<\overline{b}=0, \\
# & [\underline{a}/\overline{b}, +\infty]\cup[-\infty,\underline{a}/\underline{b}], &\textrm{si }& 0<\underline{a} \textrm{ y } \underline{b}<0<\overline{b}, \\
# & [\underline{a}/\overline{b}, +\infty], &\textrm{si }& 0<\underline{a} \textrm{ y } 0=\underline{b}<\overline{b}, \\
# & [\varnothing], &\textrm{si }& 0\notin [a] \textrm{ y } [b]=[0,0].\\
# \end{align*}
# \end{cases}
# $$

#-
# Esta definición de la división extendida, puede demostrarse, es monótona de inclusión. Además, permite evitar los errores al dividir por cero. Finalmente, y como veremos adelante, ciertos algoritmos como el método de Newton  para intervalos, utilizan la división extendida.

#-
# ---

# ## Conjuntos contenedores

#-
# Al trabajar con intervalos, la evaluación de ciertas funciones *inocentes* puede llevar a problemas de tipo conceptual. Por ejemplo, consideremos la función $f(x) = \sqrt{x-x^2}$, con $x\in[0,1]$. Es fácil convencerse que el rango de esta función es $R(f; [0,1))=[0,1/\sqrt{2}]$. Sin embargo, el uso *ingenuo* de intervalos puede llevar a situaciones raras. Por ejemplo, si evaluamos directamente la función con intervalos se obtiene $F([0,1])=\sqrt{[0,1]-[0,1]^2}=\sqrt{[0,1]-[0,1]}=\sqrt{[-1,1]}$, lo que es problemático por la parte negativa del intervalo $[-1,1]$.

#-
# Una manera de salir de esta situación problemática es consider el *dominio natural* de las funciones involucradas, en el ejemplo anterior el de la raíz cuadrada, y tomar la intersección de este dominio natural con el intervalo a evaluar. En el ejemplo anterior esto significa $\sqrt{x} = \sqrt{[x]\cap[0,+\infty]}$, lo que nos lleva a $F([0,1])=\sqrt{[-1,1]\cap[0,+\infty]}=\sqrt{[0,1]}=[0,1]$. Vale la pena notar que, si bien no obtuvimos al intervalo más delgado que acota al rango, tenemos que el rango está conteido en el resultado obtenido, i.e., $R(f,[0,1])\subseteq F([0,1])$.

#-
# La manera de proceder anterior, que incluye la evaluación de la intersección con el dominio natural de las funciones, se conoce como *conjuntos contenedores*. La ventaja de usar  conjuntos contenedores es que las evaluaciones no tienen excepciones (errores).

#-
# La idea de los conjuntos contenedores es un poco más amplia, siendo el objetivo tener una evaluación de funciones libre de excepciones, donde todas evaluaciones están bien definidas. En este caso, los intervalos se definen en $\overline{\mathbb{R}}$, es decir, incluyen $+\infty$ y $-\infty$. Así, se define la extensión *cset*, a conjuntos contenedores, como
#
# $$
# f^*(S) = R(f; S\cap D_f) \cup \{ \lim_{\zeta\to\zeta^*}\, f(\zeta): \zeta\in D_f, \zeta^*\in S\setminus D_f \},
# $$
#
# donde $D_f$ es el dominio natural de $f$. En el ejemplo anterior, el segundo conjunto que aparece en esta definición resulta ser el conjunto vacío.

#-
# Antes de finalizar, vale la pena observar otra cuestión del ejemplo $f(x) = \sqrt{x-x^2}$ evaluada en $x\in[0,1]$. Podemos reescribir $f(x)=\sqrt{x(1-x)}$; evaluando en $[0,1]$ esta expresión obtenemos $F([0,1])=\sqrt{[0,1]*[0,1]}=[0,1]$. Más allá del uso (o no) dl dominio natural de la raíz cuadrada, observamos que reescribiendo la expresión resulta en un intervalo *más estrecho* ($[0,1]$) del argumento de la raíz cuadrada, que el obtenido inicialmente ($[-1,1]$). Este es un ejemplo de un *problema* que aparece a la hora de usar intervalos: el *problema de la dependencia*.

#-
# ---

# ## Aritmética de intervalos de punto flotante

# Cuando se implementa la aritmética de intervalos en la computadora, lo primero hay que tener en cuenta es que la implementación usará números de punto flotante $\mathbb{F}$ y no $\mathbb{R}$, y por lo mismo, debemos implementar el redondeo apropiado. En este caso, el redondeo apropiado es el redonde *direccionado* o *hacia afuera*, para garantizar que el intervalo obtenido contiene a la respuesta exacta. El redondeo *hacia afuera* se obtiene redondeando hacia abajo (a menos infinito) la cota inferior, y hacia arriba (a más infinito) la cota superior.

#-
# Para ser simplistas, implementaremos una forma sencilla y conveniente para obtener este tipo de redondeo, simplemente considerando el número de punto flotante anterior a la cota inferior del intervalo, y el siguiente número de punto flotante para la cota superior. Esta implementación no producirá intervalos óptimos, en el sentido de que la anchura es mínima, pero es sencilla de implementar y correcta. Las funcione que utilizaremos en Julia son `prevfloat()` y `nextfloat()`. Estas funciones, evaluadas en `a::Float64`, literalmente devuelven el número de punto flotante anterior y posterior a `a`. Esto corresponde a aumentar o disminuir el último bit de precisión de `a`.

a = 0.25 # `a` es exactamente representable como número de punto flotante
bitstring(a)

#-
ap = prevfloat(a)
bitstring(ap)


#-
an = nextfloat(a)
bitstring(an)

# Entonces, a la hora de crear los intervalos, deberemos considerar el número de punto flotante *anterior* para el ínfimo del intervalo, y el *siguiente* para el supremo. Esto garantizará que el intervalo creado *incluya* a los límites que introducimos (que son números de punto flotante no necesariamente exactamente representables), con la consecuencia de que no tendremos intervalos *delgados*.

#-
# En el caso de las operaciones aritméticas, para $[a], [b] \in \mathbb{IF}$ tendremos:
# $$
# \begin{align*}
# [a] + [b] & = \big[\bigtriangledown(\underline{a}+\underline{b}),
# \bigtriangleup(\overline{a}+\overline{b})\big], \\
# [a] - [b] & = \big[\bigtriangledown(\underline{a}-\overline{b}),
# \bigtriangleup(\overline{a}-\underline{b})\big], \\
# [a] \times [b] & = \big[
#     \textrm{min}\big\{ \bigtriangledown(\underline{a}\underline{b}),
#     \bigtriangledown(\underline{a}\overline{b}),
#     \bigtriangledown(\overline{a}\underline{b}),
#     \bigtriangledown(\overline{a}\overline{b})\big\},\\
#     & \qquad\textrm{max}\big\{ \bigtriangleup(\underline{a}\underline{b}),
#     \bigtriangleup(\underline{a}\overline{b}),
#     \bigtriangleup(\overline{a}\underline{b}),
#     \bigtriangleup(\overline{a}\overline{b})\big\}\big], \\
# [a] \div [b] & = \big[
#     \textrm{min}\big\{ \bigtriangledown(\underline{a}/\underline{b}),
#     \bigtriangledown(\underline{a}/\overline{b}),
#     \bigtriangledown(\overline{a}/\underline{b}),
#     \bigtriangledown(\overline{a}/\overline{b})\big\},\\
#     & \qquad\textrm{max}\big\{ \bigtriangleup(\underline{a}/\underline{b}),
#     \bigtriangleup(\underline{a}/\overline{b}),
#     \bigtriangleup(\overline{a}/\underline{b}),
#     \bigtriangleup(\overline{a}/\overline{b})\big\}\big], \ (0\notin [b]),
# \end{align*}
# $$
# donde $\bigtriangledown$ corresponde a `prevfloat()` y $\bigtriangleup$ a `nextfloat()`.

#-
# La gran ventaja de este esquema es que es muy fácil de implementar; la desventaja es que los intervalos sobreestimarán sistemáticamente las operaciones elementales.

# ---

# ## Bibliografía

#-
# - W. Tucker, Validated Numerics: A Short Introduction to Rigorous Computations, Princeton University Press, 2001.
#
# - R. Moore, Interval Analysis, Prentice-Hall, 1966.
#
