
using JuMP, GLPK, CSV, Plots,LinearAlgebra,Dates,DataFrames,Parameters;
include("Function.jl")
include("PlotGenerator.jl")
##################### Gera valores aleatorios para teste #######################



function main(mode,Numero_de_Cenarios_PLD,Numero_de_Cenarios_Geracao,Numero_de_contratos,Numero_de_meses,Regioes_Analisadas)
    #Inicializa As Variaveis Principais

        #supondo mesmo numero de dados por regiao size(Dados_Estimados[:,1])/3
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
        Numero_de_Regioes = size(Regioes_Analisadas,1);
    ################################# Utilizacao do mode ###################################
    ######################################################################################
    for regiao in Regioes_Analisadas
        if (mode == 1)
            #Numero_de_Cenarios = 1;
            Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios));
            path_mode = "Random_Data";
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                            Porcentagem_Portifolio,header_Geracao = Generate_Data(
                                                            Numero_de_meses,
                                                            Numero_de_contratos,
                                                            Numero_de_Cenarios_PLD,
                                                            Numero_de_Cenarios_Geracao,
                                                            regiao,
                                                            Numero_de_Regioes,
                                                            Regioes_Analisadas
                                                            );


        elseif (mode == 2)
            Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios));
            path_mode = "Data_From_CSV";
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio = Read_from_CSV(
                                                        Numero_de_meses,
                                                        Numero_de_contratos,
                                                        Numero_de_Cenarios_PLD,
                                                        Numero_de_Cenarios_Geracao,
                                                        regiao
                                                        )

        elseif (mode == 3)
            Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios));
            path_mode = "Default_Example";
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio = Example_Parameters(
                                                        Numero_de_meses,
                                                        Numero_de_contratos,
                                                        Numero_de_Cenarios_PLD,
                                                        Numero_de_Cenarios_Geracao,
                                                        regiao
                                                        )
        else
            throw("Invalid Syntax on Variable mode");
        end

######################################################################################
######################################################################################

        global Grafico_Contrato,
                Graf_Comercializador,
                    Graf_Gerador,
                        Graf_Portifolio_Comercializadora,
                            Graf_Portifolio_Geradora_Cenario_PLD,
                                Graf_Portifolio_Geradora_Cenario_Geracao;


        R_Portifolio_Geradora_cenario_PLD,
        R_Portifolio_Geradora_cenario_Geracao,
        R_Portifolio_Comercializadora,
        R_Comercializadora,
        R_Gerador,
        Serie_temporal_Contratos,
                        h = Define_Receitas(
                                Numero_de_contratos,
                                Numero_de_meses,
                                Numero_de_Cenarios_PLD,
                                Numero_de_Cenarios_Geracao,
                                Data_Ini,
                                Duracao,
                                p,
                                q,
                                Preco_Spot,
                                Custo_Geracao,
                                Geracao_Estimada,
                                Porcentagem_Portifolio,
                                path_mode,
                                regiao
                                );

        Grafico_Contrato,
            Graf_Comercializador,
            Graf_Gerador,
            Graf_Portifolio_Comercializadora,
            Graf_Portifolio_Geradora_Cenario_PLD,
            Graf_Portifolio_Geradora_Cenario_Geracao =  PlotGenerator(Numero_de_contratos,
                                                       Serie_temporal_Contratos,
                                                       Numero_de_meses,
                                                       R_Comercializadora,
                                                       R_Gerador,
                                                       Numero_de_Cenarios_PLD,
                                                       Numero_de_Cenarios_Geracao,
                                                       R_Portifolio_Comercializadora,
                                                       R_Portifolio_Geradora_cenario_PLD,
                                                       R_Portifolio_Geradora_cenario_Geracao,
                                                       path_mode,
                                                       regiao)

    end

    return Grafico_Contrato,Graf_Comercializador,Graf_Gerador, Graf_Portifolio_Comercializadora,Graf_Portifolio_Geradora_Cenario_PLD,Graf_Portifolio_Geradora_Cenario_Geracao;
end







############################################# Add Header ###############################################3
# header_Geracao = Array{Union{Missing, String}}(missing, 2000)
# for t in 1:2000
#     header_Geracao[t] = "Cenario $t";
# end
# Dados_Geracao   = CSV.read("TFC\\Data_From_CSV\\CSV\\Geracao_DB.csv",header = false, delim = ';');
# CSV.write("TFC\\Data_From_CSV\\CSV\\Geracao_DB.csv", Dados_Geracao,header = header_Geracao,delim = ';');
#########################################################################################################











# mode =1;
# Numero_de_Cenarios_PLD = 6;
# Numero_de_Cenarios_Geracao = 5;
# Numero_de_contratos = 10;
# Regioes_Analisadas = ["Sudeste","Nordeste","Norte"];
# Numero_de_meses = 12;
#
# Numero_de_Cenarios=3
# Numero_de_Regioes = 3
# regiao = Regioes_Analisadas[2]
#
#
# Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses*Numero_de_Regioes,Numero_de_Cenarios_PLD))
# Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios_Geracao))
# Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos*Numero_de_Regioes,1));
# Duracao = convert(Array{Int64},zeros(Numero_de_contratos*Numero_de_Regioes,1));
# Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios_Geracao));
# p = convert(Matrix{Float64},zeros(Numero_de_contratos*Numero_de_Regioes,1))
# q = convert(Matrix{Float64},zeros(Numero_de_contratos*Numero_de_Regioes,1))
# Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos*Numero_de_Regioes,1))
# header_cenario_Geracao = Array{Union{Missing, String}}(missing, Numero_de_Cenarios_Geracao)
# header_cenario_PLD= Array{Union{Missing, String}}(missing, Numero_de_Cenarios_PLD)
# Regiao_Matrix_Mes = Array{Union{Missing, String}}(missing, Numero_de_meses,3)
# Regiao_Matrix_Contratos = Array{Union{Missing, String}}(missing, Numero_de_contratos,3)
# for j in 1:Numero_de_Cenarios_PLD
#     for t in 1:Numero_de_meses*Numero_de_Regioes
#         Preco_Spot[t,j] = 80 + rand()*40;
#         header_cenario_PLD[j] = "Cenario $j";
#     end
# end
# for j in 1:Numero_de_Cenarios_Geracao
#     for t in 1:Numero_de_meses
#         Custo_Geracao[t,j] = 0.001 + rand()/10000;
#         header_cenario_Geracao[j] = "Cenario $j";
#         Geracao_Estimada[t,j] = 500 + rand()*50;
#     end
# end
# for t in 1:Numero_de_meses
#     Regiao_Matrix_Mes[t,:] = Regioes_Analisadas;
# end
# for t in 1:Numero_de_contratos
#     Regiao_Matrix_Contratos[t,:] = Regioes_Analisadas;
# end
# Regiao_Mes = [Regiao_Matrix_Mes[:,1]' Regiao_Matrix_Mes[:,2]' Regiao_Matrix_Mes[:,3]']'
# Regiao_Contratos = [Regiao_Matrix_Contratos[:,1]' Regiao_Matrix_Contratos[:,2]' Regiao_Matrix_Contratos[:,3]']'
# for i in 1:Numero_de_contratos*Numero_de_Regioes
#     p[i]= 100 + rand()*10;
#     q[i]= 500 + rand()*50;
#     Data_Ini[i]= rand(1:Numero_de_meses-1);
#     Duracao[i]= rand(1:Numero_de_meses - Data_Ini[i]);
#     Porcentagem_Portifolio[i] = rand();
# end
# for i in 1:Numero_de_Regioes
#     ini = 1+ (i-1)*Numero_de_contratos;
#     fim =  i*Numero_de_contratos;
#     Porcentagem_Portifolio[ini:fim] = Porcentagem_Portifolio[ini:fim]./
#         (Porcentagem_Portifolio[ini:fim]'*ones(Numero_de_contratos));
#
# end
# Contratosdf = DataFrame( Regiao = Regiao_Contratos,
#                         Data_Ini = Data_Ini[:],
#                         Duracao = Duracao[:],
#                         Preco_Contrato = p[:],
#                         Carga_do_Contrato = q[:],
#                         Porcentagem_do_contrato_no_Portifolio = Porcentagem_Portifolio[:])
#
#
# PrecoPLDdf = DataFrame([Regiao_Mes Preco_Spot])
# Geracao_Estimadadf = DataFrame(Geracao_Estimada)
# Custo_Estimadodf  = DataFrame(Custo_Geracao)
#
# CSV.write("Random_Data\\CSV\\Contratos.CSV", Contratosdf,delim = ';',);
# CSV.write("Random_Data\\CSV\\PLDEstimado.CSV", PrecoPLDdf,delim = ';',header = ["Regiao"; header_cenario_PLD[:]]);
# CSV.write("Random_Data\\CSV\\GeracaoEstimada.CSV", Geracao_Estimadadf,delim = ';',header = [header_cenario_Geracao[:]]);
# CSV.write("Random_Data\\CSV\\CustoPorGeracaoEstimado.CSV", Custo_Estimadodf,delim = ';',header = [header_cenario_Geracao[:]]);
#
# #Relendo o arquivo escrito para confirmar que de fato foi escrito e para adquirir os campos do Header
# Contratosdf = CSV.read("Random_Data\\CSV\\Contratos.CSV",delim = ';',header = true);
# PrecoPLDdf = CSV.read("Random_Data\\CSV\\PLDEstimado.CSV",delim = ';',header = true);
# ######## Variaveis vinculadas ao contrato (i)
# Dados_Contratos_regiao = filter(row -> row.Regiao ∈ [regiao], Contratosdf)
# Dados_Estimados_regiao = filter(row -> row.Regiao ∈ [regiao], PrecoPLDdf)
# Data_Ini_Regiao = Dados_Contratos_regiao[:,2]
# Duracao_Regiao = Dados_Contratos_regiao[:,3]
# p_Regiao = Dados_Contratos_regiao[:,4]
# q_Regiao = Dados_Contratos_regiao[:,5]
# Porcentagem_Portifolio_Regiao = Dados_Contratos_regiao[:,6]
# ######## Variaveis vinculadas o periodo (t)
# Preco_Spot_Regiao = convert( Matrix,Dados_Estimados_regiao[1:Numero_de_meses,2:Numero_de_Cenarios_PLD+1])
# # Custo_Geracao = Dados_Estimados_regiao[1:Numero_de_meses,3]
# Regiao_PLD_Regiao = Dados_Estimados_regiao[1:Numero_de_meses,1]
# #
# for j in 1:Numero_de_Cenarios_PLD
#     for i in 1:Numero_de_contratos
#         for t in 1:Numero_de_meses
#             h[i,t] = durante_o_contrato(Data_Ini[i],Duracao[i],t);
#         end
#         Serie_temporal_Contratos[i,:]= p[i].*h[i,:]
#         R_Comercializadora[i,:] = ((p[i]*ones(Numero_de_meses) - Preco_Spot_Regiao[:,j]).*q[i]).*h[i,:]
#     end
#     for n in 1:Numero_de_Cenarios_Geracao
#         @show n
#         R_Gerador[n,:] = Geracao_Estimada[:,n].*(Preco_Spot_Regiao[:,j] - Custo_Geracao[:] );
#         R_Portifolio_Geradora_cenario_Geracao[n,:] = Geracao_Estimada[:,n].*(Preco_Spot_Medio[:] - Custo_Geracao[:] );
#         header_cenario_Geracao[n] = "Cenario $j";
#     end
#     header_cenario_PLD[j] = "Cenario $j";
#     R_Portifolio_Comercializadora[j,:] = Porcentagem_Portifolio'*R_Comercializadora
#     #fixando os Cenarios de geracao na media por mes
#     R_Portifolio_Geradora_cenario_PLD[j,:] = (R_Gerador'*ones(Numero_de_Cenarios_Geracao))'./size(1:Numero_de_Cenarios_Geracao);
# end
#
# Geracao_Estimada[:,1].*(Preco_Spot_Regiao[:,1] - Custo_Geracao[:] )
#
# (Preco_Spot_Regiao[:,1] - Custo_Geracao[:,1] )
# Custo_Geracao
#
# Preco_Spot[:,2]
#
# Dados_Estimados_regiao
