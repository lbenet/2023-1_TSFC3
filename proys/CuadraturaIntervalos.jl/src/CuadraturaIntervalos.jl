module CuadraturaIntervalos

using RoundingEmulator, TaylorSeries, IntervalArithmetic, ForwardDiff
import RoundingEmulator: add_down, add_up, sub_down, sub_up, mul_down, mul_up,
                         div_down, div_up

export Intervalo, Uniforme, Adaptativa, CI
export .., ⊂, ⪽, hull, ⊔, rad, mid, mig, mag
export advertencias, redondeo, intervalo_vacio, division_extendida, punto_medio, diam
export bisecta, cuadratura_simple, cuadratura_uniforme, cuadratura_adaptativa,
       cuadratura_infinita

include("intervalos.jl")
include("functions.jl")
include("cuadratura.jl")

end