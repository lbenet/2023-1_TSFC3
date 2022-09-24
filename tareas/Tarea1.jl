# # Tarea 1

#-
# > **Fecha de entrega** (aceptación del *Pull Request*): 14 de octubre
#

#-
# > **NOTA:** Esta tarea requiere que suban código que escribirán en el archivo `intervalos.jl`,
# > y que deberá estar en el *subdirectorio* `Intervalos/src/subdir_equipo/`. El subdirectorio
# > será de uso exclusivo para cada equipo o persona que trabaje individualmente.
# > El código debe estar adecuadamente documentado usando
# > [docstrings](https://docs.julialang.org/en/v1/manual/documentation/#Writing-Documentation),
# > o en su defecto, debidamente comentado.
# > Para la aprobación de la tarea se requiere además que pasen los tests.

#-
# El módulo `Intervalos` está definido en `Intervalos/src/Intervalos.jl`. Ese archivo cargará
# el archivo `intervalos.jl` que se deberá encuentar en el directorio `Intervalos/src/nombre_equipo/`,
# y que es donde estará el código que se les pide para la tarea.
#
# En esta tarea **no** hemos especificado qué funciones o estructuras debe *exportar* su módulo,
# pero ésto implícitamente se usa en los tests.

#

#-
# ### Ejercicio 1: Módulo `Intervalos`
#
# - Definan la estructura paramétrica `Intervalo{T}`, que debe funcionar usando un ínfimo y un
#     supremo al menos del tipo `Float64` y `BigFoat`, que definirá al parámetro `T`.
#     Deberán escribir una o más funciones (*constructores*) que permitan, entre otras,
#     usar `Intervalo(a)`, con `a::Float64` o `a::BigFloat`, para crear un intervalo delgado.
#     El constructor no debe involucrar ningún tipo de redondeo. Si los tipos del ínfimo y
#     del supremo no coinciden, `Intervalo` deberá promover los tipos correctamente.
#     Definan cómo debe comportarse `Intervalo` si se utiliza con parámetros incorrectos,
#     por ejemplo, el ínfimo es mayor que el supremo.
#
# - Definan la función `intervalo_vacio`, que depende del *tipo*, que devuelve al `Intervalo`
#     que corresponde al intervalo sin elementos (al conjunto vacío). Su implementación al
#     definir al intervalo vacío debe ser tal que su estructura permita definirlo, quizás
#     como un caso especial.
#

#-
# ### Ejercicio 2: Operaciones básicas
#
# - Extiendan las relaciones de conjuntos `==`, `issubset` (`⊆`), `isinterior` (`⪽`), `in` (`∈`),
#     `hull` (`⊔`), `intersect` (`∩`) para usarlas con dos intervalos. Noten que los
#     símbolos `⪽` y `⊔` no existen en Julia y deberá ser posible usarlos. La función
#     `union` (`∪`) deberá ser sinónima de `hull`. (Para usar símbolos en lugar de nombres de
#     funciones, pueden usar el nombre común (`hull`) y definir `const ⊔ = hull`.)
#
# - Extiendan las funciones aritméticas (`+`, `-`, `*`, `/`). Estas operaciones
#     deberán devolver el `Intervalo` apropiado, incluyendo el redondeo; para implementar
#     el redondeo, deberán usar `prevfloat` y `nextfloat`. Asegúrense que las operaciones aritméticas,
#     cuando tengan sentido (e.g., `1/a`), puedan involucrar un número entero, `Float64` o `BigFoat`,
#     entre otros (es decir, `<:Real`), y un intervalo, o incluso sólo un intervalo (por ejemplo,
#     `-a`, con `a::Intervalo`).
#
# - Extiendan las potencias *enteras* para intervalos. Noten que, por ejemplo, `a^2` no corresponde
#     a `a*a`; la potencia (con enteros) debe devolver el *rango* apropiado de la función, incluyendo
#     el redondeo.
#

#-
# ### Ejercicio 3: División extendida
#
# - Definan la función `division_extendida` tal que devuelva una *tupla de intervalos*,
#     siguiendo la definición que vimos en la clase. Es necesario que su implementación
#     incluya el redondeo de manera adecuada.
