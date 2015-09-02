import IAMF

include("model.jl")

m = makemodel(parameters={"slope" => [1.0]})

IAMF.run(m)

m.components[:linear].Variables
