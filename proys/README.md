# Proyectos de fin de semestre

Al final del semestre deberán escoger un proyecto que desarrollarán
durante las últimas semanas del curso, y que presentarán, a manera de
seminario corto (10-15 minutos) **el 5 de diciembre**. En el seminario
presentarán el problema que escogieron, los avances que lograron
(puede ser requerido el código), y algunos resultados.

Lo primero que deben hacer es escoger un proyecto, y si lo trabajarán en
equipo o de manera individual; esto se hará comentando en un issue que se
abrirá para esto. Los proyectos desarrollados serán distintos entre sí.
Los proyectos deben ser enviados (subidos al repositorio del curso)
**antes del 2 de diciembre**; **no habrán extensiones**. Los proyectos
se subirán en un directorio (independiente) por proyecto, y deberán contener
todo el material necesario: código (documentado!) y presentación.

A continuación se presentan algunas ideas de proyectos de fin de semestre
con algunas referencias. Se pueden considerar otras ideas para el proyecto,
pero vale la pena comentarlas primero con nosotros.

1. Cuadraturas: Implementar el cálculo de la integral definida $\int_a^b f(x) \textrm{d}x$  para funciones en una dimensión cuyo cálculo sea *riguroso*. En particular, extiendan los métodos del trapecio y de Simpson para hacer este cálculo, y un método *de paso adaptativo*. Se puede utilizar la paquetería `IntervalArithmetic.jl` para ejemplificar los algoritmos con funciones más complicadas. Refs: [1,2].

1. Usando `TaylorSeries.jl` y el teorema de Taylor para funciones en una dimensión, implementar una forma de aproximar la función $f(x)$ en un intervalo $D$ rigurosamente, usando la serie de Taylor y su residuo. Esto es, que el valor exacto de $f(x_0)$, con $x_0\in D$, esté contenido en la evaluación de la aproximación polinomial, incluido un intervalo de error. Se puede usar la paquetería `IntervalArithmetic.jl` para considerar funciones más complicadas. Ref: [1].

1. Regiones de estabilidad asociadas a órbitas periódicas del mapeo
logístico $x_{n+1} = \mu x_n(1-x_n)$. La idea es mostrar las regiones de estabilidad para las órbitas periódicas en términos del parámetro $\mu$. Ref: [3].

1. Implementar el método de Krawczyk para buscar ceros de funciones. Explicar las posibles ventajas que puede tener sobre el método de Newton. Ref: [1].

1. Implementar el algoritmo de suma y producto punto *precisos* descritos en [4]. Ejemplificar cómo estos algoritmos pueden explotarse para el redondeo de funciones.

1. Implementar el concepto de `Caja`, que es el producto cartesiano de $n$ `Intervalo`s, extendiendo el concepto a $n$ dimensiones. La idea es extender todo lo necesario para, por ejemplo, poder usar esta estructura en la búsqueda de ceros de sistemas de ecuaciones para $n=2$. Ref: [1,2].

1. Comparar la extensión intervalar de funciones (extensión natural, formas centrales, formas centrales híbridas) entre sí. Ref: [5].

1. Ejemplificar el uso del análisis de intervalos (quizás usando
`IntervalArithmetic.jl`) para la estimación de parámetros o cotas de estos,
via optimización. Ref: [5,6].


Bibliografía:

[1] W. Tucker, Validated Numerics: A Short Introduction to Rigorous Computations, Princeton University Press, 2001.

[2] R. Moore, R. Baker Kearfott, Michael J. Cloud, Introduction to Interval Analysis, SIAM, 2009.

[3] W. Tucker and D. Wilczak, A rigorous lower bound for the
stability regions of the quadratic map, Physica D 238, pp 1923-1936. DOI: 10.1016/j.physd.2009.06.020.

[4] Takeshi Ogita, Siegfried M. Rump, and Shin'ichi Oishi, Accurate Sum and Dot Product, SIAM J. Sci. Comput. 26, 1955–1988 (2005). DOI: 10.1137/030601818.

[5] L. Jaulin et al, Applied Interval Analysis, Springer, 2001.

[6] W. Tucker and V. Moulton, Parameter Reconstruction for Biochemical
Networks Using Interval Analysis, Reliable Computing Vol 12, 389-402
(2006). DOI: 10.1007/s11155-006-9009-2.