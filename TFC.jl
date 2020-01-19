
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
println("Excellent! Everything is good to go!")
println(@__DIR__)
using JuMP, GLPK, CSV, Plots,LinearAlgebra,Dates,DataFrames,Parameters;

##################### Gera valores aleatorios para teste #######################
function Generate_Data(Numero_de_meses, Numero_de_contratos)
    Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,1));
    Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,1));
    Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1));
    Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1));
    Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
    p = convert(Matrix{Float64},zeros(Numero_de_contratos,1))
    q = convert(Matrix{Float64},zeros(Numero_de_contratos,1))
    Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos,1))
    header_Geracao = Array{Union{Missing, String}}(missing, Numero_de_meses)
    for t in 1:Numero_de_meses
        Preco_Spot[t] = 80 + rand()*40;
        Custo_Geracao[t] = 0.1 + rand()/100;
        header_Geracao[t] = "Mes $t";
    end
    for i in 1:Numero_de_contratos
        p[i]= 100 + rand()*10;
        q[i]= 500 + rand()*50;
        Data_Ini[i]= rand(1:Numero_de_meses-1);
        Duracao[i]= rand(1:Numero_de_meses - Data_Ini[i]);
        Porcentagem_Portifolio[i] = rand();
    end
    Porcentagem_Portifolio = Porcentagem_Portifolio./(Porcentagem_Portifolio'*ones(Numero_de_contratos))
    for i in 1:Numero_de_contratos
        for t in 1:Numero_de_meses
            Geracao_Estimada[i,t] = 500 + rand()*50;
        end
    end

    Contratosdf = DataFrame([Data_Ini'
            Duracao'
            p'
            q'
            Porcentagem_Portifolio']')
    Mesesdf = DataFrame([Preco_Spot'
            Custo_Geracao']')
    Geracao_Estimadadf = DataFrame(Geracao_Estimada)

    CSV.write("TFC\\Plot_Random_Data\\Contratos.CSV", Contratosdf,header = ["Data_Ini",
            "Duracao",
            "p",
            "q",
            "Porcentagem_Portifolio"],delim = ';');
    CSV.write("TFC\\Plot_Random_Data\\Meses.CSV", Mesesdf,header = ["Preco_Spot",
            "Custo_Geracao"],delim = ';');
    CSV.write("TFC\\Plot_Random_Data\\GeracaoEstimada.CSV", Geracao_Estimadadf, header = header_Geracao ,delim = ';');

    return Preco_Spot,
            Custo_Geracao,
            Data_Ini,
            Duracao,
            Geracao_Estimada,
            p,
            q,
            Porcentagem_Portifolio,
            header_Geracao;
end


##################### Gera valores aleatorios para teste #######################
function Read_from_CSV(Numero_de_meses, Numero_de_contratos,Numero_de_Cenarios)
    Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,1));
        Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,1));
        Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        p = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        q = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos,1));

    #Importa dados do CSV
    Dados_Contratos = CSV.read("TFC\\CSV\\Contratos_DB.csv",header = true, delim = ';');
    Dados_Estimados = CSV.read("TFC\\CSV\\Estimados_DB.csv",header = true, delim = ';');
    # struct Struct_regiao
    #     Norte::AbstractDataFrame
    #     Sudeste::AbstractDataFrame
    #     Nordeste::AbstractDataFrame
    # end
    # Dados_Contratos_regiao = Struct_regiao(teste_norte,teste_sudeste,teste_nordeste);
    for regiao in ["Sudeste","Nordeste","Norte"]
        ######## Variaveis vinculadas ao contrato (i)
        Dados_Contratos_regiao = filter(row -> row.Regiao ∈ [regiao], Dados_Contratos)
        Dados_Estimados_regiao = filter(row -> row.Regiao ∈ [regiao], Dados_Estimados)
        Data_Ini = Dados_Contratos_regiao[:,2]
        Duracao = Dados_Contratos_regiao[:,3]
        P = Dados_Contratos_regiao[:,4]
        q = Dados_Contratos_regiao[:,5]
        Porcentagem_Portifolio = Dados_Contratos_regiao[:,6]
        ######## Variaveis vinculadas o periodo (t)
        Preco_Spot = Dados_Estimados_regiao[1:Numero_de_meses,2:Numero_de_Cenarios+1]
        Geracao_Estimada = Dados_Estimados_regiao[1:Numero_de_meses,10]
        # Custo_Geracao = Dados_Estimados_regiao[1:Numero_de_meses,3]
        Regiao_PLD = Dados_Estimados_regiao[1:Numero_de_meses,1]
        @show Data_Ini,Duracao
    end


    return Preco_Spot,
            Custo_Geracao,
            Data_Ini,
            Duracao,
            Geracao_Estimada,
            p,
            q,
            Porcentagem_Portifolio;
end
#inacabada
##################### Parametros exemplo de contrato e pld #######################
function Example_Parameters(Numero_de_meses, Numero_de_contratos)
    Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,1));
    Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,1));
    Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1));
    Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1));
    Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
    p = convert(Matrix{Float64},zeros(Numero_de_contratos,1))
    q = convert(Matrix{Float64},zeros(Numero_de_contratos,1))
    Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos,1))

    for t in 1:Numero_de_meses
        Preco_Spot[t] = 80
        Custo_Geracao[t] = 10
    end
    for i in 1:Numero_de_contratos
        p[i]= 100;
        q[i]= 500;
        Data_Ini[i]= 1;
        Duracao[i]= rand(1:Numero_de_meses - Data_Ini[i]);
        Porcentagem_Portifolio[i] = rand();
    end
    Porcentagem_Portifolio = Porcentagem_Portifolio./(Porcentagem_Portifolio'*ones(Numero_de_contratos))
    for i in 1:Numero_de_contratos
        for t in 1:Numero_de_meses
            Geracao_Estimada[i,t] = 500 + rand()*50;
        end
    end
    return Preco_Spot,
            Custo_Geracao,
            Data_Ini,
            Duracao,
            Geracao_Estimada,
            p,
            q,
            Porcentagem_Portifolio;
end
#inacabada


######## Retorna 1 se o contrato estiver em vigor e 0 caso contrario ##########
function durante_o_contrato(Inicio, Duracao, t)
    final_contrato = (Inicio + Duracao)
    if  (Inicio<=t) && (final_contrato >= t)
        return 1;
    end
    return 0;
end
################### Define funcao preco dos contratos #########################
function Define_Receitas(Numero_de_contratos,
                        Numero_de_meses,
                        Numero_de_Cenarios,
                        Data_Ini,
                        Duracao,
                        p,
                        q,
                        Preco_Spot,
                        Custo_Geracao,
                        Geracao_Estimada,
                        Porcentagem_Portifolio)

    Serie_temporal_Contratos= convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        h = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses))
        R_Comercializadora = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        R_Gerador = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        R_Portifolio = convert(Matrix{Float64},zeros(Numero_de_Cenarios,Numero_de_meses));
    for j in 1:Numero_de_Cenarios
        for i in 1:Numero_de_contratos
            for t in 1:Numero_de_meses
                @show Preco_Spot[t,j],p[i],q[i]
                h[i,t] = durante_o_contrato(Data_Ini[i],Duracao[i],t);
                R_Comercializadora[i,t] = (p[i] - Preco_Spot[t,j])*q[i]*h[i,t];
                R_Gerador[i,t] = Geracao_Estimada[i]*(Preco_Spot[i,j] - Custo_Geracao[t] );

                Serie_temporal_Contratos[i,t]= p[i]*h[i,t]
            end
        end
        @show R_Comercializadora
        R_Portifolio[j,:] =Porcentagem_Portifolio'*R_Comercializadora
        @show R_Portifolio
    end
    return R_Portifolio,R_Comercializadora,R_Gerador,Serie_temporal_Contratos,h;
end

# Plot de Curva de Precos dos Contratos
function Contract_Price_Curve_Plot( Numero_de_contratos,
                                    Serie_temporal_Contratos,
                                    path_mode
                                    )

    for i in 1:Numero_de_contratos
        global Grafico_Contrato
        if i==1
            Grafico_Contrato = plot(Serie_temporal_Contratos[i,:],
                        title="Preco dos Contratos no tempo",
                        label="Preco Contrato $i"
                    )
        else
            plot!(Serie_temporal_Contratos[i,:],
                    title="Preco dos Contratos no tempo",
                    label="Preco Contrato $i"
                )
        end
    end
    return Grafico_Contrato
    savefig(Grafico_Contrato,"TFC\\$path_mode\\Curvas_de_Contratos.pdf")
end
# Plot da curva de receitas Do contrato
function Curvas_de_Receita(Numero_de_contratos,
                            Numero_de_meses,
                            R_Comercializadora,
                            R_Gerador,
                            path_mode
                            )

    for i in 1:Numero_de_contratos
        global Plot_Comercializadora
        if i==1
            Plot_Comercializadora = plot(1:Numero_de_meses,R_Comercializadora[1,:],
                        title="Receitas no tempo",
                        label= "Comercializadora no Contrato $i"
                    )
        else
            plot!(1:Numero_de_meses,R_Comercializadora[i,:],
                    title="Receitas no tempo",
                    label= "Comercializadora no Contrato $i"
                )
        end
    end
    Plot_Comercializadora
    savefig(Plot_Comercializadora,
            "TFC\\$path_mode\\Curvas_de_Receita_Comercializadora.pdf"
            )

    for i in 1:Numero_de_contratos
        global Plot_Gerador
        if i==1
            Plot_Gerador = plot(1:Numero_de_meses,R_Gerador[1,:],
                            title="Receitas no tempo",
                            label="Gerador no Contrato $i"
                    )
        else
            plot!(1:Numero_de_meses,R_Gerador[i,:],
                    title="Receitas no tempo",
                    label="Gerador no Contrato $i"
                )
        end
    end
    Plot_Gerador
    savefig(Plot_Gerador,
            "TFC\\$path_mode\\Curvas_de_Receita_Gerador.pdf"
            )
    return Plot_Comercializadora,Plot_Gerador;
end
function Portifolio_Curve(
                        Numero_de_contratos,
                        Numero_de_meses,
                        Numero_de_Cenarios,
                        R_Portifolio,
                        path_mode
                        )

    for i in 1:Numero_de_Cenarios
        global Plot_Portifolio
        if i ==1
            Plot_Portifolio = plot(1:Numero_de_meses,R_Portifolio[i,:],
                    title="Receitas do Portifólio no tempo",
                    label= "Curvas_de_Receita_Comercializadora $i"
                )
        else
            plot!(1:Numero_de_meses,R_Portifolio[i,:],
                    title="Receitas do Portifólio no tempo",
                    label= "Curvas_de_Receita_Comercializadora $i"
                )
        end
        @show Plot_Portifolio
        savefig(Plot_Portifolio,
                "TFC\\$path_mode\\Curvas_de_Receita_Portifolio_Cenario_$Numero_de_Cenarios.pdf"
                )
    end

    return Plot_Portifolio;
end






function main(mode)
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
    if (mode == 1)
        Numero_de_Cenarios = 1;
        Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios));
        path_mode = "Plot_Random_Data";
        Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio,header_Geracao = Generate_Data(
                                                        Numero_de_meses,
                                                        Numero_de_contratos
                                                        )
        elseif (mode == 2)
            Numero_de_Cenarios = 3;
            Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios));
            path_mode = "Plot_From_Excel";
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio = Read_from_CSV(
                                                        Numero_de_meses,
                                                        Numero_de_contratos,
                                                        Numero_de_Cenarios
                                                        )

        elseif (mode == 3)
            Numero_de_Cenarios = 3;
            Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios));
            path_mode = "Plot_Default_Example";
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio = Example_Parameters(
                                                        Numero_de_meses,
                                                        Numero_de_contratos
                                                        )
        else
            throw("Invalid Syntax on Variable mode");
    end


    ######################################################################################
    ######################################################################################

    R_Portifolio,R_Comercializadora,R_Gerador,Serie_temporal_Contratos,h = Define_Receitas(
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

    Grafico_Contrato = Contract_Price_Curve_Plot(
                            Numero_de_contratos,
                            Serie_temporal_Contratos,
                            path_mode
                            );

    Graf_Comercializador, Graf_Gerador = Curvas_de_Receita(
                        Numero_de_contratos,
                        Numero_de_meses,
                        R_Comercializadora,
                        R_Gerador,
                        path_mode
                        )

    Graf_Portifolio = Portifolio_Curve(
                        Numero_de_contratos,
                        Numero_de_meses,
                        Numero_de_Cenarios,
                        R_Portifolio,
                        path_mode
                        )

    return Grafico_Contrato,Graf_Comercializador,Graf_Gerador, Graf_Portifolio;
end

#mode = 1 para dados aleatorios
#mode = 2 para retirar dados do CSV
#mode = 3 para utilizar dados exemplo fixados na função
mode = 1;

Grafico_Contrato,Graf_Comercializador,Graf_Gerador, Graf_Portifolio = main(mode);


Graf_Comercializador
Grafico_Contrato
Graf_Gerador
Graf_Portifolio







#Importa dados do CSV
Dados_Contratos = CSV.read("TFC\\CSV\\Contratos_DB.csv",header = true, delim = ';');
Dados_Estimados = CSV.read("TFC\\CSV\\Estimados_DB.csv",header = true, delim = ';');
@show Dados_Contratos
@show size(Dados_Estimados,2)
######## Variaveis vinculadas ao contrato (i)

######## Variaveis vinculadas o periodo (t)
Preco_Spot = Dados_Estimados[1:Numero_de_meses,1]
Geracao_Estimada = Dados_Estimados[1:Numero_de_meses,2]
Custo_Geracao = Dados_Estimados[1:Numero_de_meses,3]
Regiao_PLD = Dados_Estimados[1:Numero_de_meses,4]

Dados_Estimados[:,2001]
mutable struct Dados_Contratos_regia3
    Norte::AbstractDataFrame
    Sudeste::AbstractDataFrame
    Nordeste::AbstractDataFrame
end
teste_norte = filter(row -> row.Regiao ∈ ["Norte"], Dados_Estimados)
teste_sudeste = filter(row -> row.Regiao ∈ ["Sudeste"], Dados_Estimados)
teste_nordeste = filter(row -> row.Regiao ∈ ["Nordeste"], Dados_Estimados)
Dados_Contratos_regiao3 = Dados_Contratos_regia3(teste_norte,teste_sudeste,teste_nordeste);
Dados_Contratos_regiao3.Norte
dados_regiao
teste_norte = 1

Dados_Contratos_regiao1 = filter(row -> row.Regiao ∈ ["Norte"], Dados_Contratos)
Dados_Estimados_regiao = filter(row -> row.Regiao ∈ ["Norte"],Dados_Estimados )
Data_Ini = Dados_Contratos_regiao[:,2]
Duracao = Dados_Contratos_regiao[:,3]
P = Dados_Contratos_regiao[:,4]
q = Dados_Contratos_regiao[:,5]
Porcentagem_Portifolio = Dados_Contratos_regiao[:,6]
######## Variaveis vinculadas o periodo (t)
Preco_Spot = Dados_Estimados_regiao[1:Numero_de_meses,1:Numero_de_Cenarios]
