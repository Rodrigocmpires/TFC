import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
println("Excellent! Everything is good to go!")
println(@__DIR__)
include("TFC.jl");
include("PlotGenerator.jl")
Pkg.pwd()


#mode = 1 para dados aleatorios
#mode = 2 para retirar dados do CSV
#mode = 3 para utilizar dados exemplo fixados na função
mode =1;
Numero_de_Cenarios_PLD = 3;
Regioes_Analisadas = ["Sudeste","Nordeste","Norte"];


Grafico_Contrato,
    Graf_Comercializador,
    Graf_Gerador,
    Graf_Portifolio_Comercializadora,
    Graf_Portifolio_Geradora = main(mode,Numero_de_Cenarios_PLD,Regioes_Analisadas);


Graf_Comercializador
Grafico_Contrato
Graf_Gerador
Graf_Portifolio_Geradora
Graf_Portifolio_Comercializadora
