
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
println("Excellent! Everything is good to go!")
println(@__DIR__)
using JuMP, GLPK, CSV, Plots,LinearAlgebra,Dates,DataFrames,Parameters;
include("Function.jl")
include("PlotGenerator.jl")
##################### Gera valores aleatorios para teste #######################



function main(mode,Numero_de_Cenarios)
    #Inicializa As Variaveis Principais
    Numero_de_contratos = 10;
        Numero_de_meses = 11;#supondo mesmo numero de dados por regiao size(Dados_Estimados[:,1])/3
        #parametros Contrato
        Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        #parametros temporais
        Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,1));
        #Parametros que dependem do tempo e do contrato
        R_Comercializadora = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        R_Gerador = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        R_Portifolio = convert(Matrix{Float64},zeros(1,Numero_de_meses));
        Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        #preco e carga prometida no contrato
        p = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        q = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        #Parametros Auxiliares
        h = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        Serie_temporal_Contratos= convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        #Headers para a escrita do csv
        header_Geracao = Array{Union{Missing, String}}(missing, Numero_de_meses);

    ################################# Utilizacao do mode ###################################
    ######################################################################################
    for regiao in ["Sudeste","Nordeste","Norte"]
        if (mode == 1)
            #Numero_de_Cenarios = 1;
            Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios));
            path_mode = "Random_Data";
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                            Porcentagem_Portifolio,header_Geracao = Generate_Data(
                                                            Numero_de_meses,
                                                            Numero_de_contratos,
                                                            Numero_de_Cenarios,
                                                            regiao
                                                            );


        elseif (mode == 2)
            Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios));
            path_mode = "Data_From_CSV";
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio = Read_from_CSV(
                                                        Numero_de_meses,
                                                        Numero_de_contratos,
                                                        Numero_de_Cenarios,
                                                        regiao
                                                        )

        elseif (mode == 3)
            Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios));
            path_mode = "Default_Example";
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio = Example_Parameters(
                                                        Numero_de_meses,
                                                        Numero_de_contratos,
                                                        Numero_de_Cenarios,
                                                        regiao
                                                        )
        else
            throw("Invalid Syntax on Variable mode");
        end

######################################################################################
######################################################################################

        R_Portifolio_Geradora,
        R_Portifolio_Comercializadora,
        R_Comercializadora,
        R_Gerador,
        Serie_temporal_Contratos,
                        h = Define_Receitas(
                                Numero_de_contratos,
                                Numero_de_meses,
                                Numero_de_Cenarios,
                                Data_Ini,
                                Duracao,
                                p,
                                q,
                                Preco_Spot,
                                Custo_Geracao,
                                Geracao_Estimada,
                                Porcentagem_Portifolio
                                );

        Grafico_Contrato,
        Graf_Comercializador,
        Graf_Gerador,
        Graf_Portifolio_Comercializadora,
        Graf_Portifolio_Geradora =  PlotGenerator(Numero_de_contratos,
                                                       Serie_temporal_Contratos,
                                                       Numero_de_meses,
                                                       R_Comercializadora,
                                                       R_Gerador,
                                                       Numero_de_Cenarios,
                                                       R_Portifolio_Comercializadora,
                                                       R_Portifolio_Geradora,
                                                       path_mode,
                                                       regiao)

    end

    return Grafico_Contrato,Graf_Comercializador,Graf_Gerador, Graf_Portifolio_Comercializadora,Graf_Portifolio_Geradora;
end







############################################# Add Header ###############################################3
# header_Geracao = Array{Union{Missing, String}}(missing, 2000)
# for t in 1:2000
#     header_Geracao[t] = "Cenario $t";
# end
# Dados_Geracao   = CSV.read("TFC\\Data_From_CSV\\CSV\\Geracao_DB.csv",header = false, delim = ';');
# CSV.write("TFC\\Data_From_CSV\\CSV\\Geracao_DB.csv", Dados_Geracao,header = header_Geracao,delim = ';');
#########################################################################################################

# Numero_de_Cenarios=3
# Numero_de_Regioes = 3
# Numero_de_meses = 12
# Numero_de_contratos = 10
