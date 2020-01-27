include("TFC.jl");
Pkg.pwd()


#mode = 1 para dados aleatorios
#mode = 2 para retirar dados do CSV
#mode = 3 para utilizar dados exemplo fixados na função
mode = 1;

Grafico_Contrato,Graf_Comercializador,Graf_Gerador, Graf_Portifolio_Comercializadora,Graf_Portifolio_Geradora = main(mode);


Graf_Comercializador
Grafico_Contrato
Graf_Gerador
Graf_Portifolio
