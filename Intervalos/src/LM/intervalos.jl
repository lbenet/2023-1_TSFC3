struct Intervalo{T<:Real} 
    #Definimos los espacios para el infimo y el supremo.
    infimo::T
    supremo::T
    
    function Intervalo(a, b)# where {T<:Real, S<:Real}
#        infimo, supremo = valida_intervalo(a, b)
        aa, bb, _ = promote(a, b, 1.0)
        bb < aa && error("El supremo tiene que ser menor al infimo")
        new{typeof(aa)}(aa, bb)
    end
end