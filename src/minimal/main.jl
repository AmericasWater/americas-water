push!(LOAD_PATH, "/Users/jrising/projects/iam/")

import Mimi

include("model.jl")

m = makemodel(parameters={"slope" => [1.0]})

Mimi.run(m)

m.components[:linear].Variables
