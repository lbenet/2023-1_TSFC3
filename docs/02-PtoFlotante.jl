# # Números en la computadora: números de punto flotante

#-
#Preliminares
using Pkg
Pkg.activate("..")  # Activa el directorio "." respecto al lugar donde estamos

#-
# ## Ejemplos: sutilezas al usar la aritmética de la computadora

# ### El orden de las operaciones importa

# Consideren los siguientes dos vectores $a$ y $b$

a = [1e20, 2.0, -1e22, 1e13, 2111, 1e16]

#-
b = [1e20, 1223, 1e18, 1e15, 3, -1e12]

# La pregunta es cuánto vale el producto punto de estos vectores, ``a\cdot b``.

#-
# Primero usaremos la manera más directa, que es el cálculo de la suma de productos elemento a elemento de los vectores; para obtener el producto elemento a element usaremos *broadcasting* (`.*`)

sum( a .* b )

#-
# Ahora, repetiremos el cálculo usando la función `dot`, de la librería (estándar) `LinearAlgebra.jl`

using LinearAlgebra

dot(a, b)

# En ambos casos hemos obtenido `0.0`. Suena entonces bastante plausible concluir que $a$ y $b$ son ortogonales; simplemente, no hay razón por la que debemos esperar otra cosa.

#-
# Una tercer manera de hacer lo mismo es reagrupando las operaciones, es decir, usando la *propiedad asociativa de la suma*. En particular, haremos el cálculo calculando primero
f1 = a[1] * b[1] + a[3] * b[3] + a[4] * b[4] + a[6] * b[6]

# seguido de
f2 = a[2] * b[2] + a[5] * b[5]

# Y ahora sumamos ambos términos, para obtener
f1 + f2

# El resultado obtenido no es cero, y resulta que éste es el correcto; esto lo podemos verificar "a mano", o usando precisión extendida.

# Claramente, el orden en que realizamos las operaciones numéricas en la computadora es importante.

# ### Magnitudes relativas

# Consideremos la función $$f(x,y) = 333.75 y^6 + x^2(11x^2y^2-y^6-121y^4-2)+5.5y^8+x/(2y)$$. La pregunta es ¿cuál es el valor (¡correcto!) de $f(x,y)$ en el punto $(77617,33096)$?

# Para responder la pregunta definiremos primero las siguientes funciones:

f₁(x,y) = 333.75*y^6 + x^2*(11*x^2*y^2-y^6-121*y^4-2)

f₂(x,y) = 5.5*y^8

f(x,y) = f₁(x,y) + f₂(x,y) + x/(2*y)

# Procedamos por el camino más sencillo: Evaluemos *directamente* `f(77617, 33096)`

f(77617, 33096)

# Ahora haremos lo mismo usando precisión extendida
f( big(77617),  big(33096))

#-
# La pregunta es ¿cuál es el resultado correcto?

# Para saber cuál es el resultado correcto, evaluaremos por separado las distintas funciones involucradas.

f₁(77617, 33096)

#-
f₁(big(77617), big(33096))

#-
f₂(77617, 33096)

#-
f₂(big(77617), big(33096))

#-
f₁(77617, 33096) + f₂(77617, 33096)

#-
f₁(big(77617), big(33096)) + f₂(big(77617), big(33096))

# La moraleja aquí es clara: adiciones y substracciones de cantidades cuyo order de magnitud rebasa los dígitos significativos utilizados, pueden llevar a resultados erróneos.

#-
# ### Sobre la manera de escribir las funciones

# La idea es, a partir de la gráfica del polinomio $p(t)=t^6-6t^5+15t^4-20t^3+15t^2-6t+1$ cerca de 1, estimar el número de ceros del polinomio. Recordando el teorema fundamental de la aritmética, a lo mucho debemos tener 6 raíces reales (ya que el polinomio es de grado 6). Este polinomio, puede ser reescrito como $$q(t) = (t-1)^6$$, siendo ambos polinomios *exactamente* iguales.

# Para graficar usaremos la librería `Plots.jl` que permite graficar usando `Gnuplot`. Graficaremos $p(t)$ en el intervalo $[0.9951171875, 1.0048828125]$ usando pasos de $1/2^{16}$; la idea de usar estos números es que son exactamente representables en la computadora. Usaremos el siguiente código

#
Pkg.add("Plots") # Esto agrega la paquetería Plots.jl

#-
using Plots

#-
p(t) = t^6 - 6t^5 + 15t^4 - 20t^3 + 15t^2 - 6t + 1
q(t) = (t-1)^6

#-
x = 1-5/2^10 : 1/2^16 : 1+5/2^10

#-
plot( x, p.(x), color=:blue, label="p(t)")
plot!(x, q.(x), color=:red, lw=2, label="q(t)")


# El resultado de este ejemplo es que la manera en que uno escribe una función es importante numéricamente; si bien $p(t)=q(t)$ matemáticamente, su implementación numérica no lo muestra.

#-
# ## Números en la computadora

# Aquí veremos las cuestiones básicas de la aritmética implementada en la computadora, qué números se representan, cómo se guardan y cómo se manipulan, cuestiones que van más allá del lenguaje concreto que se utiliza. La idea es mostrar por qué algunas operaciones dan resultados sencillamente *incorrectos* si los pensamos como números reales.

#-
# ### Notación posicional
#
# Empezaremos recordando la notación posicional para los números reales $\mathbb{R}$, en una *base* arbitraria $\beta\ge 2$ (donde $\beta$ es un número entero). Cualquier número real $x$ puede ser escrito como una cadena infinita de la forma:
# $$
# x = (-1)^\sigma \left( b_n b_{n-1}\dots b_0 . b_{-1} b_{-2} \dots \right)_\beta\ .
# $$
#
# Aquí, $\sigma=\{0,1\}$ sirve para definir el signo de $x$, y $b_n, b_{n-1}, \dots$ son números *enteros* tales que $0 \le b_i \le \beta-1$ para todo $i$.

#-
# Claramente, el número real $x$ se puede reescribir como:
#
# $$
# \begin{align*}
# x &= (-1)^\sigma \sum_{i=-\infty}^n b_i \,\beta^i\\
#   &= (-1)^\sigma ( b_n \beta^n + b_{n-1} \beta^{n-1} + \dots + b_0 + b_{-1}\beta^{-1} + b_{-2}\beta^{-2} + \dots).
# \end{align*}
# $$
#
# lo que muestra que la notación posicional no es única.

#-
# En la notación posicional entonces se utilizan una serie de reglas de conveniencia, esencialmente para evitar redundancias en la representación. Por ejemplo, si hay una cola infinita de ceros, ésta se omite. De igual manera, se omiten los ceros que están antes (a la izquierda) de la parte entera.

# A pesar de esto, la representación posicional tiene problemas en toda base $\beta$, dado que hay números reales que no tienen una representación única. Por ejemplo, $(3.1415999999\dots)_{10}\,$, con una cola infinita de nueves, es igual a $(3.1416)_{10}\,$. Esta redundancia se puede eliminar si, además de las reglas de conveniencia anteriores, se añade el requisito de que $0\le b_i \le \beta-2$, para un número *infinito* de $i$. Esto es, se eliminan las colas de $\beta-1$ infinitas, a lo mucho permitiendo una cola infinita donde se repite hasta $\beta-2$.

#-
# ### Números de punto flotante

#-
# Los *números de punto flotante* proporcionan una manera conveniente de representar los números reales, donde el lugar del punto "decimal", o mejor dicho, el punto en base $\beta$, es importante. Los números de punto flotante se representan como:
#
# $$
# x = (-1)^\sigma \, m \times \beta^\varepsilon,
# $$
#
# donde $\sigma$ se relaciona con el signo igual que antes, $m$ es la *mantisa* (o *significante*) y $\varepsilon$ es un exponente.
#
# Para los números de punto flotante el lugar del punto en base $\beta$ se fija por convención: el punto en base $\beta$ viene después del primer dígito de $m$,
#
# $$
# m=(b_0.b_{1}b_{2}\dots)_\beta,
# $$
#
# donde los subíndices de la parte *fraccionaria* de la mantisa (a la derecha del punto) ahora se etiquetan con enteros positivos (antes usábamos enteros negativos).

#-
# El conjunto de números descritos de esta manera se conoce como los *números de punto flotante* en base $\beta$, y a este conjunto se le representa con $\mathbb{F}_\beta$. Igual que antes, $\beta\ge 2$ es un entero, $\sigma=\{0,1\}$, el exponente $\varepsilon$ es algún entero, $0\leq b_i \leq \beta-1$ para todo $i$, y $0\leq b_i \leq \beta-2$ y para un número infinito de $i$, a fin de evitar las colas infinitas de $\beta-1$.

#-
# ### Números normales y subnormales

#-
# Los números de punto flotanto descritos antes introducen una nueva redundancia, por ejemplo, $(42)_{10}$ es igual que $(0.0042)_{10}\times 10^4$ y también a $(42000)_{10}\times 10^{-3}$. Para evitar esta redundancia, se pide que la parte entera del número consista de un "dígito", $b_0$, que es el dígito que está inmediatamente antes del punto "decimal", y que éste sea distinto de cero; la única excepción es el caso especial $x=0$. Este requisito adicional hace que el exponente $\varepsilon$ sea único, y de hecho, el mínimo que hace que $b_0$ sea distinto de cero. Los números de punto flotante que satisfacen este requisito se llaman *normales* o *normalizados*.

#-
# Sin embargo, dado que la memoria de la computadora es finita, no podemos representar a $\mathbb{R}$ en la computadora, ni tampoco a $\mathbb{F}_\beta$, ya que ambos conjuntos son densos. Es por esto que debemos limitarnos a un subconjunto de números que sirvan para aproximar a los números reales, siendo éste un conjunto *finito*.

#-
# Para definir un conjunto finito, en primer lugar, restringimos el número de "dígitos" que representan la mantisa $m$ a un número finito, es decir, $m=(b_0.b_1 b_2 \dots b_{p-1})_\beta$; el número $p$ se conoce como *precisión*. Vale la pena notar que la restricción de que $0\leq b_i \leq \beta-2$ se vuelve irrelevante con precisión finita, ya que no puede haber colas infinitas de ningún tipo. El conjunto que resulta, que representaremos como $\mathbb{F}_{\beta,p}$, se puede demostrar que es un conjunto contable infinito (es un subconjunto de los racionales), por lo que aún debemos restringirlo más.

#-
# Para obtener un conjunto finito y útil en la computadora, fijamos la precisión $p$ a un valor finito, y además acotamos (por arriba y abajo) los posibles valores del exponente $\varepsilon$, es decir, $e_- \le \varepsilon \le e_+$. Al conjunto (finito) definido de esta manera lo denotaremos por $\mathbb{F}_{\beta,p}^{e_-, e_+}$.

#-
# La cardinalidad de $\mathbb{F}^{e_-,e_+}_{\beta,p}$, es decir, el número de elementos que tiene un conjunto, es
#
# $$
# \#\{\mathbb{F}^{e_-,e_+}_{\beta,p}\} = 1 + 2(e_+-e_-+1)(\beta-1)\beta^{\,p-1}.
# $$

#-
# El valor más pequeño distinto de cero, $x_\textrm{min}$, se obtiene con la mantisa $(1.0)_\beta$ y el exponente $\varepsilon=e_-$. De manera similar, el valor más grande del conjunto, $x_\textrm{max}$, tiene una mantisa con todos los "dígitos" de la mantisa iguales a $\beta-1$, y con el máximo exponente $\varepsilon=e_+$. Estos valores vienen dados por:
#
# $$
# \begin{align*}
# x_\textrm{min} &= (1.0)_\beta \beta^{\,e_-} = \beta^{\,e_-},\\
# x_\textrm{max} &= ( b_m. b_m\dots b_m)_\beta \beta^{\,e_+} = (\beta-1)\beta^{\,e_+}\sum_{i=0}^{p-1}\beta^{\,-i} \\
#        &= \beta^{\,e_++1-p}(\beta^{\,p}-1).
# \end{align*}
# $$

#-
# Para ilustrar la construcción, usaremos como ejemplo $\mathbb{F}^{-1,2}_{2,3}$. De las expresiones anteriores tenemos que $\#\{\mathbb{F}^{-1,2}_{2,3}\}=33$, $x_\textrm{min}=0.5$ y $x_\textrm{max}=7$. En este caso podemos obtener explícitamente todos los elementos de este conjunto.

#-
#Generamos todos los números normales dados e_-, e_+, prec, para $\beta=2$
𝔽 = Float64[0.0]
b₀ = 1.0
for ε = -1:2
	for b₁=0:1
		for b₂=0:1
			x = (b₀ + b₁*(2.0)^(-1) + b₂*(2.0)^(-2))*2.0^ε
			push!(𝔽, x, -x)
		end
	end
end
sort!(𝔽)

#-
# Una representación gráfica de este conjunto se observa en la siguiente gráfica.

#-
#Usamos Gaston.jl (que es muy parecido a gnuplot) para representar este conjunto
xmax = maximum(𝔽)
plot(size=(600,100))
plot!( 𝔽, zero.(𝔽), yerr=0.5, markerstrokecolor=:auto, lw=2,
    xlims=(-xmax-0.5, xmax+0.5), ylims=(-1,1),
    xticks=collect(-xmax:xmax), yticks=:none,
    label=:none)
plot!( [-xmax-0.5, xmax+0.5], zeros(2), color=:black, lw=2,
    label=:none)

#-
# Como se puede observar de la gráfica, la distancia entre puntos vecinos de $\mathbb{F}_{2,3}^{-1,2}$ es constante por segmentos. Estos segmentos están separados por potencias consecutivas de $\beta$ obtenidas al variar $\varepsilon$, y la distancia entre números consecutivos disminuye a medida que el exponente $\varepsilon$ disminuye, excepto alrededor del $0$.
# Esta "propiedad" hace que haya una gran pérdida de *exactitud* cuando se aproximan números muy pequeños. De hecho, también hace que ciertas propiedades aritméticas no se cumplan en la computadora.
#
# Una manera de evitar el *hueco* tan amplio alrededor del cero, al menos de manera parcial, es permitiendo tener números que no son *normales*. Los números de punto flotante en $\mathbb{F}_{\beta,p}^{e_-,e_+}$ con $b_0=0$ y $\varepsilon=e_-$ se llaman números *subnormales*.

#-
#Generamos todos los números subnormales para beta=2 y se los añadimos a los normales
s𝔽 = Float64[]
ε = -1
b₀ = 0.0
for b₁=0:1
	for b₂=0:1
        b₁ == b₂ == 0 && continue # no repetimos al 0
		x = ( b₀ + b₁*(2.0)^(-1) + b₂*(2.0)^(-2))*2.0^ε
		push!(s𝔽, x, -x)
	end
end
sort!(s𝔽)

#-
#Representación gráfica de s𝔽
plot(size=(600,100))
plot!( 𝔽, zero.(𝔽), yerr=0.5, markerstrokecolor=:auto, lw=2,
    xlims=(-xmax-0.5, xmax+0.5), ylims=(-1,1),
    xticks=collect(-xmax:xmax), yticks=:none,
    label=:none)
plot!( s𝔽, zero.(s𝔽), yerr=0.5, markerstrokecolor=:auto, label=:none)
plot!( [-xmax-0.5, xmax+0.5], zeros(2), color=:black, lw=2,
    label=:none)


#-
# Incluir a los números subnormales junto con los números normales (de punto flotante) permite que haya una transición gradual hacia $0$. Una propiedad importante que se puede demostrar es que la representación de todos los números (normales y subnormales) distintos de cero es única.
#
# El conjunto $\mathbb{F}_{\beta,p}^{e_-,e_+}$, entendido como los números de punto flotante normales y subnormales, son esencialmente los que la computadora utiliza.

#-
# Sólo nos falta entonces establecer la manera de mapear $\mathbb{R}$ a $\mathbb{F}$."

#-
# ## Redondeo

#-
# El mapeo que se encarga de pasar de $\mathbb{R}$ a $\mathbb{F}$ es el *redondeo*. Obviamente, este mapeo no puede ser invertible.

#-
# Antes de definir el mapeo, o de hecho *los mapeos* ya que no es único, es útil extender el dominio y el rango de los conjuntos en $\mathbb{R}^*=\mathbb{R}\cup\{-\infty,\infty\}$ y de la misma manera $\mathbb{F}^*=\mathbb{F}\cup\{-\infty,\infty\}$. Esta extensión permite representar los números que son más grandes que el mayor de los números de punto flotante, $x_\textrm{max}$.

#-
# Pedimos que un mapeo de redondeo $\bigcirc$ satisfaga las siguientes dos propiedades:
#
# - (R1) $x\in\mathbb{F}^* \Rightarrow \bigcirc(x)=x,$
# - (R2) $x,y\in\mathbb{F}^*$ y $x\le y$ $\Rightarrow \bigcirc(x)\le \bigcirc(y).$
#
# Con estas propiedades se puede demostrar que el redondeo es de *calidad máxima*: el interior del intervalo que se puede definir con $x$ y $\bigcirc(x)$ no contiene puntos de $\mathbb{F}^*$.

#-
# ### Redondeo a cero

#-
# La manera más sencilla de redondear es el modo conocido como redondeo a cero. Este modo es equivalente al truncamiento, es decir, a omitir todos los "dígitos" de la mantisa que están más allá de la precisión. De esta manera definimos
#
# ```math
# \begin{equation*}
# \square_z(x) = \textrm{sign}(x) \max\left(y\in\mathbb{F}^*: y\le |x|\right).
# \end{equation*}
# ```
#
# En este caso, si escribimos $x=(-1)^\sigma(b_0.b_1b_2\dots)_\beta\,\beta^e$, entonces el redondeo a cero corresponde a $\square_z(x) = (-1)^\sigma(b_0.b_1b_2\dots b_{p-1})_\beta\,\beta^e$.
#
# El redondeo a cero es una función impar.

#-
# ### Redondeo dirigido

#-
# Podemos definir dos modos de redondeo dirigido:
# $$
# \begin{align*}
# x\in\mathbb{R}^* &\Rightarrow \bigcirc(x)\le x, &(a)\\
# x\in\mathbb{R}^* &\Rightarrow \bigcirc(x)\ge x. &(b)\\
# \end{align*}
# $$

#-
# El redondeo que satisface $(a)$ se llama *redondeo hacia menos infinito* (o redondeo hacia abajo), y el que satisface $(b)$ es el *redondeo hacia más infinito* (redondeo hacia arriba). Estos redondeos se definen de manera formal como:
# $$
# \begin{align*}
# \bigtriangledown(x) &= \max\left(y\in\mathbb{F}^*:y\le x\right),\\
# \bigtriangleup(x) &= \max\left(y\in\mathbb{F}^*:y\ge x\right).  \\
# \end{align*}
# $$
#
# En este caso, el intervalo $[\bigtriangledown(x), \bigtriangleup(x)]$ es de máxima calidad.
#
# Estos redondeos satisfacen la propiedad:
# $$
# \bigtriangledown(x) = -\bigtriangleup(-x),
# $$
# lo que permite obtener un redondeo en términos del otro.

#-
# ### Redondeo (al par) más cercano

#-
# Tanto el redondeo a cero como los redondeos dirigidos mapean el interior de un intervalo formado por dos puntos consecutivos de $\mathbb{F}^*$ a un punto de $\mathbb{F}^*$. Esto significa que el error que se comete a través de estos tipos de redondeo es del orden de la longitud del intervalo definido por los dos puntos consecutivos de $\mathbb{F}^*$, i.e., la longitud de $[\bigtriangledown(x),\bigtriangleup(x)]$. Una forma de redondeo que resulta en errores menores es el *redondeo al punto flotante más cercano*.

#-
# Todo punto $x\in\mathbb{R}^*$ puede ser acotado en $\mathbb{F}^*$ usando el intervalo $[\bigtriangledown(x),\bigtriangleup(x)]$, es decir
# $$
# \bigtriangledown(x) \le x \le \bigtriangleup(x).
# $$
#
# La idea entonces del redondeo al punto flotante más cercano es la siguiente: Para todo punto $|x| \le x_\textrm{max}$, definimos el punto medio del intervalo de puntos de $\mathbb{F}^*$ que los acota como $\mu=(\bigtriangledown(x) + \bigtriangleup(x))/2$; si $|x| > x_\textrm{max}$ entonces definimos $\mu=\textrm{sign}(x) |x_\textrm{max}|$. Entonces, el redondeo al punto flotante más cercano regresa $\bigtriangledown(x)$ si $x < \mu$ y $\bigtriangleup(x)$ si $x > \mu$. En el caso en que $x=\mu$, las distintas maneras de resolver el empate definen los distintos modos del redondeo al punto más cercano.

#-
# Una manera para no tener *sesgo* en el error, es decir, que el error esté centrado alrededor de cero es usando lo que se llama el *redondeo al par más cercano*, y que denotaremos como $\square$. Esta manera de redondear es la que se encuentra de manera más común.
#
# Escribimos la mantisa de los números de punto flotante que acotan $x$ como $(a_0.a_1a_2\dots a_{p-1})_\beta$ y $(b_0.b_1b_2\dots b_{p-1})_\beta$. Entonces, si $x\notin \mathbb{F}^*$, definimos este modo como
#
# $$
# \begin{align*}
# x>0 \Rightarrow \square(x) &=
# \begin{cases}
# \bigtriangledown(x), \textrm{si } x\in[\bigtriangledown(x),\mu), \textrm{ o si } x=\mu \textrm{ y } a_{p-1} \textrm{ es par},\\
# \bigtriangleup(x), \textrm{si } x\in(\mu,\bigtriangleup(x)], \textrm{ o si } x=\mu \textrm{ y } b_{p-1} \textrm{ es par},\\
# \end{cases}\\
# x<0 \Rightarrow \square(x) &= - \square(-x).
# \end{align*}
# $$
#
# Un punto importante que vale la pena recalcar es que si $|x|>x_\textrm{max}$, el redondeo al punto flotante par más cercano da como resultado $\square(x) = \text{sign}(x)\infty$, que no necesariamente es el punto flotante más cercano.

#-
# De manera similar uno puede definir el redondeo al punto flotante *impar* más cercano.
