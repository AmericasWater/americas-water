import IAMF

include("model.jl")

m = makemodel(parameters={"slope" => [1.0]})

runmodel(m)

m.components[:linear].Variables
