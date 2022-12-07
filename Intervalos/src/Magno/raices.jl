"""se define la estructura raiz que recibe dos parametros llamados raiz y unicidad"""

struct Raiz
    raiz::Intervalo{T} where T <: Real
    unicidad::Bool
end


#funcion que devuelve el diametro de un intervalo de acuerdo a la definicion vista en clase

function diam(a::Intervalo)
    a.supremo-a.infimo
end

#funcion que devuelve el punto medio de un intervalo de acuerdo a la definicion vista en clase

function mid(a::Intervalo)
    (a.infimo+a.supremo)/2
end

#funcion que aplica el operador de newton extendido y devuelve uno o dos elementos dependiendo
#de la division extendida

function operador_Newton_ext(f::Function, dom::Intervalo)
    M = Intervalo(mid(dom)) #crea un intervalo delgado del punto medio del intervalo
    D = division_extendida(f(M),ForwardDiff.derivative(f, dom)) #division extendida
    
    if length(D) == 1 
        Y = D[1]
        N=M-Y #operador de newton
        I = N ∩ dom #interseccion con el intervalo inicial
        return I
    else #de forma analoga al caso anterior pero con dos resultados
        Y1, Y2 = D
        N1 = M - Y1
        N2 = M - Y2
        I1 = N1 ∩ dom
        I2 = N2 ∩ dom
        return I1, I2
    end
end

function ceros_newton(f::Function, dom::Intervalo, tol=1/1024)

    X = [] #se crea el vector donde se añadiran o no los candidatos
    b = false #se crea la variable booleana para el ciclo while

    if 0 ∈ f(dom) #verifica que la funcion evaluada en el dominio inicial contenga al menos una raiz
        X = [dom] #si cumple lo anterior pasa a ser un candidato
        b = true #por lo tanto ejecutara el ciclo while
    end

        while (b)            
                x0 = popfirst!(X) #se extrae el primer candidato y se elimina del vector
                X1 = operador_Newton_ext(f, x0) #operador de newto extendido

                for j in eachindex(X1)
                    if 0 ∈ f(X1[j])  #si el intervalo resultante tiene una raiz
                        append!(X, X1[j]) #se agrega a los candidatos
                    end
                end
            # se comprueba que los diametros de los candidatos sean menor a la tolerancia
            #si se cumple se detiene el ciclo while
            b = maximum(diam.(X)) > tol
        end

    raices=[] #se crea un vector donde se añadiran las raices del tipo Raiz

    if !isempty(X) #si no hay candidatos se salta el for y devuelve un vector vacio
        for i in eachindex(X)
            raiz=X[i] 
            unicidad=esmonotona(f, X[i])
            push!(raices, Raiz(raiz, unicidad))#se agregan elementos del tipo Raiz al vector raices
        end
    end
    return raices #devuelve las raices del tipo Raiz
end




