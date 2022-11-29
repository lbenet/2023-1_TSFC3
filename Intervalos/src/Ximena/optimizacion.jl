export minimiza, maximiza, biseccion, mediaImg, midpoint

### Ejercicio 4: Optimización
#Escibir una función `minimiza(f, D)` que encuentre el
# mínimo global de la función $f(x)$ en el dominio $D\subset\mathbb{R}$. Esto es, queremos
# obtener el valor $y^*$ que es el mínimo global de la función en $D$, y el lugar en que
# esto ocurre, es decir, $x^*$. Supondremos que $f(x)$ es continua en $D$, y que $D$ es
# un intervalo (conjunto compacto).

#=
Básicamente lo que se hace es ir separando en subintervalos al bisectar hasta alcanzar un diametro menor a la 
tolerancia, mientras se va comparando con todos los minimos supremos (maximos infimos para maximiza)
Asi se van desechando todos los intervalos que no tienen posibles minimos globales, y se bisectan los que si
afinando la aproximacion
=#


"""
Primero definiremos el punto medio de un intervalo, el cual es un escalar, difiere de mid (que es un intervalo) 
por dicha razón
"""
midpoint(a::Intervalo) = (a.infimo + a.supremo)/2

"""
La función biseccion toma vdom y va partiendo en dos cada entrada, regresando un vector con los nuevos subintervalos
"""
function biseccion(vdom)
    for _ in eachindex(vdom)
        oldDom = popfirst!(vdom) #vamos tomando cada entrada y la partimos en dos
        newDoms = Intervalo(oldDom.infimo, midpoint(oldDom)), Intervalo(midpoint(oldDom), oldDom.supremo)
        append!(vdom, newDoms)
    end
    return vdom #devuelve el vector de subintervalos 
end

"""
mediaImg muestra la función f evaluada en el punto medio de cada intervalo, para esto, iteramos f sobre los elementos
de vdom, evaluando en el punto medio (midpoint) de cada uno, e iremos guardando los puntos en un vector llamado
mediaPto
"""
function mediaImg(f,vdom)
    p = length(vdom) #cuantos subintervalos hay en vdom
    mediaPto = zeros(p) #creamos el vector de ceros, los iremos reemplazando conforme iteramos
    for i in 1:p #recorremos todos los subintervalos
        mediaPto[i] = f(midpoint(vdom[i])) #reemplazamos la entrada i de mediaPto por la funcion evaluada
        #en el punto medio del subintervalo i 
    end
    return mediaPto #dame la lista de los puntos de f evaluados a la mitad de cada subintervalo
end

"""
La funcion minimiza separa en subintervalos muy pequeños (con diámetro menor a una tolerancia dada) el dominio dado,
posteriormente evalua los rangos máximos y mínimos que tiene la función en ese subintervalo, para luego compararlos
en busca del menor de los rangos.
Nótese que en una función aleatoria, existe la posibilidad de que existan mínimos locales en ciertos intervalos, con
un rango mayor que supremos locales en otros intervalos, por lo que, la función compara tomando en cuenta el menor
supremo que encuentra, para eliminar todos estos casos y enfocarse en los posibles candidatos a minimo global.
"""
function minimiza(f, dom::Intervalo, tol=1/1024)
    vdom = [dom] #vector con el dominio
    while true
        newDom = biseccion(vdom)
        #Para mantener un registro, guardare supremos e infimos en listas que inicializare como listas de ceros
        p = length(newDom)
        supr = zeros(p)
        infm = zeros(p)
        #Ahora buscare los infimos y supremos del rango de f en cada subintervalo de newDom
        for i in 1:p
            supr[i] = f(newDom[i]).supremo
            infm[i] = f(newDom[i]).infimo 
        end
        #Ahora buscamos el menor de los supremos para desechar todos los infimos mayor que este, y considerar
        #unicamente los infimos que cumplan con ser menores a este
        minSup = minimum(supr)
        
        Vcand = Vector{Intervalo}() #como los candidatos son intervalos, creamos un vector vacio tipo intervalo,
        #para guardar a los posibles candidatos
        for j in 1:p
            infm[j] < minSup && push!(Vcand, newDom[j]) #si es menor que el sup mas chico, puede que sea un minimo
            #global, guardamos el intervalo en Vcand (valor candidato), si no se cumple, ignoramos el intervalo
        end
        #Ahora, esto se repetira hasta que el diametro de los subintervalos sean menores a 0, vamos haciendo más 
        #fina la "malla" al estrechar los intervalos con la bisección, y únicamente considerando los que son menores
        #al supremo minimo de cada nueva iteración, asi mejorando la aproximación, una vez alcancemos la tolerancia
        #se rompe el bucle y se toma la lista de candidatos resultante, por lo que, revisemos la tolerancia.
        #recordemos que por ser bisección todos los intervalos tienen el mismo diámtro, por lo que, podemos tomar 
        #cualquiera para evaluar la tolerancia; tomemos el primero

        if diam(Vcand[1]) < tol 
            minis = mediaImg(f, Vcand)
            return Vcand, minis
        end
    end
end

"""
Para la funcion maximiza repetiremos el proceso anterior, pero en lugar de tomar el minimo de los supremos, tomaremos
el maximo de los infimos, pues un supremo global debe ser mayor a este, asi depuraremos continuamente conforme se 
va afinando la iteración al estrechar los intervalos, hasta obtener intervalos con diámetro menor a la tolerancia
"""
function maximiza(f, dom::Intervalo, tol=1/1024)
    vdom = [dom] #vector con el dominio
    while true
        newDom = biseccion(vdom)
        #Para mantener un registro, guardare supremos e infimos en listas que inicializare como listas de ceros
        p = length(newDom)
        supr = zeros(p)
        infm = zeros(p)
        #Ahora buscare los infimos y supremos del rango de f en cada subintervalo de newDom
        for k in 1:p
            supr[k] = f(newDom[k]).supremo
            infm[k] = f(newDom[k]).infimo 
        end
        #Ahora buscamos el mayor de los infimos para desechar los intervalos con supremos menor que este
        maxInf = maximum(infm)
        
        Vcand = Vector{Intervalo}() #lista vacia de candidatos

        for l in 1:p
            maxInf < supr[l] && push!(Vcand, newDom[l]) #si es mayor que el máximo infimo, es posible maximo global
        end
        #Revisamos la tolerancia
        if diam(Vcand[1]) < tol 
            maxis = mediaImg(f, Vcand)
            return Vcand, maxis
        end
    end
end