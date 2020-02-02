import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
println("Excellent! Everything is good to go!")
println(@__DIR__)
include("TFC.jl");
include("PlotGenerator.jl")
include("function.jl")
Pkg.pwd()


#mode = 1 para dados aleatorios
#mode = 2 para retirar dados do CSV
#mode = 3 para utilizar dados exemplo fixados na função
mode =2;
Numero_de_Cenarios_PLD = 6;
Numero_de_Cenarios_Geracao = 5;
Numero_de_contratos = 10;
Regioes_Analisadas = ["Sudeste","Nordeste","Norte"];
Numero_de_meses = 12;

Grafico_Contrato,
    Graf_Comercializador,
    Graf_Portifolio_Comercializadora,
    Graf_Portifolio_Geradora_Cenario_PLD,
    Graf_Portifolio_Geradora_Cenario_Geracao = main(mode,
                                    Numero_de_Cenarios_PLD,
                                    Numero_de_Cenarios_Geracao,
                                    Numero_de_contratos,
                                    Numero_de_meses,
                                    Regioes_Analisadas);


Graf_Comercializador
Grafico_Contrato
Graf_Portifolio_Geradora_Cenario_PLD
Graf_Portifolio_Geradora_Cenario_Geracao
Graf_Portifolio_Comercializadora

###########################################################################

# mode =2;
# Numero_de_Cenarios_PLD = 2000;
# Numero_de_Cenarios_Geracao = 2000;
# Numero_de_contratos = 10;
# Regioes_Analisadas = ["Sudeste","Nordeste","Norte"];
# regiao = Regioes_Analisadas[3]
# Numero_de_meses = 12;
# path_mode = "Default_Example";
#
# Preco_Spot_Norte,Custo_Geracao_Norte,Data_Ini_Norte,Duracao_Norte,Geracao_Estimada_Norte,p_Norte,q_Norte,
#             Porcentagem_Portifolio_Norte = Read_from_CSV(
#                                             Numero_de_meses,
#                                             Numero_de_contratos,
#                                             Numero_de_Cenarios_PLD,
#                                             Numero_de_Cenarios_Geracao,
#                                             regiao
#                                             )
#
#
# R_Portifolio_Geradora_cenario_PLD_Norte,
#     R_Portifolio_Geradora_cenario_Geracao_Norte,
#     R_Portifolio_Comercializadora_Norte,
#     R_Comercializadora_Norte,
#     R_Gerador_Norte,
#     Serie_temporal_Contratos_Norte,
#                 h_Norte = Define_Receitas(
#                         Numero_de_contratos,
#                         Numero_de_meses,
#                         Numero_de_Cenarios_PLD,
#                         Numero_de_Cenarios_Geracao,
#                         Data_Ini_Norte,
#                         Duracao_Norte,
#                         p_Norte,
#                         q_Norte,
#                         Preco_Spot_Norte,
#                         Custo_Geracao_Norte,
#                         Geracao_Estimada_Norte,
#                         Porcentagem_Portifolio_Norte,
#                         path_mode,
#                         regiao
#                         );
#
# Preco_Spot_Norte
# Custo_Geracao_Norte
# Data_Ini_Norte
# Duracao_Norte
# Geracao_Estimada_Norte
# p_Norte
# q_Norte
# Porcentagem_Portifolio_Norte
# R_Portifolio_Geradora_cenario_PLD_Norte
# R_Portifolio_Geradora_cenario_Geracao_Norte
# R_Portifolio_Comercializadora_Norte
# R_Comercializadora_Norte
# R_Gerador_Norte
# Serie_temporal_Contratos_Norte
# h_Norte
