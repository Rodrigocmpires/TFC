
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
println("Excellent! Everything is good to go!")
println(@__DIR__)
using JuMP, GLPK, CSV, Plots,LinearAlgebra,Dates



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

    for t in 1:Numero_de_meses
        Preco_Spot[t] = 80 + rand()*40;
        Custo_Geracao[t] = 10 + rand()/100;
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
    return Preco_Spot,
            Custo_Geracao,
            Data_Ini,
            Duracao,
            Geracao_Estimada,
            p,
            q,
            Porcentagem_Portifolio;
end


##################### Gera valores aleatorios para teste #######################
function Read_from_CSV(Numero_de_meses, Numero_de_contratos)
    Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,1));
        Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,1));
        Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        p = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        q = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos,1));

    #Importa dados do CSV
    Dados_Contratos = CSV.read("Desktop\\TFC\\CSV\\Contratos_DB.csv",header = true);
    Dados_Estimados = CSV.read("Desktop\\TFC\\CSV\\Estimados_DB.csv",header = true);

    ######## Variaveis vinculadas ao contrato (i)
    Data_Ini = Dados_Contratos[1:Numero_de_contratos,1]
    Duracao = Dados_Contratos[1:Numero_de_contratos,2]
    Preco_Contrato = Dados_Contratos[1:Numero_de_contratos,3]

    ######## Variaveis vinculadas o periodo (t)
    Preco_Spot = Dados_Estimados[1:Numero_de_meses,1]
    Geracao_Estimada = Dados_Estimados[1:Numero_de_meses,2]
    Custo_Geracao = Dados_Estimados[1:Numero_de_meses,3]
    Regiao_PLD = Dados_Estimados[1:Numero_de_meses,4]

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

    for i in 1:Numero_de_contratos
        for t in 1:Numero_de_meses
            h[i,t] = durante_o_contrato(Data_Ini[i],Duracao[i],t)

            R_Comercializadora[i,t] = (p[i] - Preco_Spot[t])*q[i]*h[i,t];
            R_Gerador[i,t] = Geracao_Estimada[i]*(Preco_Spot[i] - Custo_Geracao[t] );

            Serie_temporal_Contratos[i,t]= p[i]*h[i,t]
        end
    end
    @show R_Comercializadora
    R_Portifolio =Porcentagem_Portifolio'*R_Comercializadora
    @show R_Portifolio
    return R_Portifolio,R_Comercializadora,R_Gerador,Serie_temporal_Contratos,h;
end

# Plot de Curva de Precos dos Contratos
function Contract_Price_Curve_Plot(Numero_de_contratos,Serie_temporal_Contratos)
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
    savefig(Grafico_Contrato,"C:\\Users\\rodri\\Desktop\\TFC\\Curvas_de_Contratos.pdf")
end
# Plot da curva de receitas Do contrato
function Curvas_de_Receita(Numero_de_contratos,
                            Numero_de_meses,
                            R_Comercializadora,
                            R_Gerador
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
            "C:\\Users\\rodri\\Desktop\\TFC\\Curvas_de_Receita_Comercializadora.pdf"
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
            "C:\\Users\\rodri\\Desktop\\TFC\\Curvas_de_Receita_Gerador.pdf"
            )
    return Plot_Comercializadora,Plot_Gerador;
end
function Portifolio_Curve(
                        Numero_de_contratos,
                        Numero_de_meses,
                        R_Portifolio
                        )

    Plot_Portifolio = plot(1:Numero_de_meses,R_Portifolio[:],
            title="Receitas do Portifólio no tempo",
            label= "Curvas_de_Receita_Comercializadora"
        )
    Plot_Portifolio
    savefig(Plot_Portifolio,
            "C:\\Users\\rodri\\Desktop\\TFC\\Curvas_de_Receita_Portifolio.pdf"
            )
    return Plot_Portifolio;
end






function main(mode)
    #Inicializa As Variaveis Principais
    Numero_de_contratos = 2;
        Numero_de_meses = 12;#supondo mesmo numero de dados por regiao size(Dados_Estimados[:,1])/3
        #parametros Contrato
        Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        #parametros temporais
        Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,1));
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

    ################################# Utilizacao do mode ###################################
    ######################################################################################
    if (mode == 1)
        Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio = Generate_Data(
                                                        Numero_de_meses,
                                                        Numero_de_contratos
                                                        )
        elseif (mode == 2)
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio = Read_from_CSV(
                                                        Numero_de_meses,
                                                        Numero_de_contratos
                                                        )
        elseif (mode == 3)
            Preco_Spot,Custo_Geracao,Data_Ini,Duracao,Geracao_Estimada,p,q,
                        Porcentagem_Portifolio = Example_Parameters(
                                                        Numero_de_meses,
                                                        Numero_de_contratos
                                                        )
        else
            print("Invalid Syntax on Variable mode");
    end


    ######################################################################################
    ######################################################################################

    R_Portifolio,R_Comercializadora,R_Gerador,Serie_temporal_Contratos,h = Define_Receitas(
                            Numero_de_contratos,
                            Numero_de_meses,
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
                            Serie_temporal_Contratos
                            );

    Graf_Comercializador, Graf_Gerador = Curvas_de_Receita(
                        Numero_de_contratos,
                        Numero_de_meses,
                        R_Comercializadora,
                        R_Gerador
                        )

    Graf_Portifolio = Portifolio_Curve(
                        Numero_de_contratos,
                        Numero_de_meses,
                        R_Portifolio
                        )

    return Grafico_Contrato,Graf_Comercializador,Graf_Gerador, Graf_Portifolio;
end

#mode = 1 para dados aleatorios
#mode = 2 para retirar dados do CSV
#mode = 3 para utilizar dados exemplo fixados na função
mode = 1;

Grafico_Contrato,Graf_Comercializador,Graf_Gerador, Graf_Portifolio = main(mode)


Graf_Comercializador
Grafico_Contrato
Graf_Gerador
Graf_Portifolio






Curva_Parametros_Temporais = plot(1:Numero_de_meses,[Preco_Spot,Geracao_Estimada[1,:],Custo_Geracao],
    title="Parametros Temporais",
    label=["Preco Spot", "Geracao Estimada", "Custo de Geracao"])
savefig(Curva_Parametros_Temporais,"C:\\Users\\rodri\\Desktop\\TFC\\Curva_Parametros_Temporais.png")

Curva_Parametros_Contrato = plot(1:Numero_de_contratos,[[p],[q]],
    title="Parametros de contrato",
    label=["Preco do Contrato", "Carga contratado"])
savefig(Curva_Parametros_Contrato,"C:\\Users\\rodri\\Desktop\\TFC\\Curva_Parametros_Contrato.png")
######################################################################################
######################################################################################

Dados_Contratos = CSV.read("Desktop\\TFC\\CSV\\Contratos_DB.csv",header = true);
Dados_Estimados = CSV.read("Desktop\\TFC\\CSV\\Estimados_DB.csv",header = true);

######## Variaveis vinculadas ao contrato (i)
Data_Ini = Dados_Contratos[1:Numero_de_contratos,1]
Duracao = Dados_Contratos[1:Numero_de_contratos,2]

Dados_Estimados

mes = Dados_Estimados[:,5]
mes + Dates.Month(12)
Dados_Estimados[1:2,1]
