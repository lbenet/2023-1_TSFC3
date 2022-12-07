const IA = IntervalArithmetic
const II = IntervalArithmetic.Interval

for f in (:(sin), :(cos), :(tan), :(sec), :(exp), :(log), :(sqrt))

    @eval begin

        import Base: $f

        function $f(a::Intervalo)
            x = IA.$f(II(a.infimo, a.supremo))
            return Intervalo(x.lo, x.hi)
        end

    end

end

import Base: sincos, ^

function sincos(a::Intervalo)
    x, y = IA.sincos(II(a.infimo, a.supremo))
    return Intervalo(x.lo, x.hi), Intervalo(y.lo, y.hi)
end

for T in (:Integer, :Float64, :BigFloat)
    @eval begin 
        function ^(a::Intervalo{Float64}, b::$T) 
            x = II(a.infimo, a.supremo) ^ b
            return Intervalo(x.lo, x.hi)
        end
    end
end

function ^(a::Intervalo, b::Intervalo) 
    a_ = II(a.infimo, a.supremo)
    b_ = II(b.infimo, b.supremo)
    x = a_ ^ b_
    return Intervalo(x.lo, x.hi)
end