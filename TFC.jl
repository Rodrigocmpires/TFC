
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
println("Excellent! Everything is good to go!")
println(@__DIR__)
using JuMP, GLPK, CSV, Plots,LinearAlgebra

#Importa dados do CSV
Dados_Contratos = CSV.read("Desktop\\TFC\\Contratos_DB.csv",header = true);
Dados_Estimados = CSV.read("Desktop\\TFC\\Estimados_DB.csv",header = true);


#Inicializa As Variaveis Principais

Numero_de_contratos = 2;
Numero_de_meses = 12;

#paramentros Contrato
Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1))
Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1))

#parametros temporais
Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,1))
Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,1))

#Parametros que dependem do tempo e do contrato
R_Comercializadora = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses))
R_Gerador = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses))
Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses))

#preco e carga prometida no contrato
p = convert(Matrix{Float64},zeros(Numero_de_contratos,1))
q = convert(Matrix{Float64},zeros(Numero_de_contratos,1))

#Parametros Auxiliares
h = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses))
Serie_temporal_Contratos= convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses))

################################# Parametros Teste ###################################
######################################################################################


for t in 1:Numero_de_meses
    Preco_Spot[t] = 80 + rand()*40
    Custo_Geracao[t] = 10 + rand()/100
end
for i in 1:Numero_de_contratos
    @show Numero_de_meses
    p[i]= 100 + rand()*10
    q[i]= 500 + rand()*50
    Data_Ini[i]= rand(1:Numero_de_meses-1)
    Duracao[i]= rand(1:Numero_de_meses - Data_Ini[i])
end
for i in 1:Numero_de_contratos
    for t in 1:Numero_de_meses
        Geracao_Estimada[i,t] = 500 + rand()*50
    end
end

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













#####Segrega os dados por atributo

######## Variaveis vinculadas ao contrato (i)
Data_Ini = Dados_Contratos[1:Numero_de_contratos,1]
Duracao = Dados_Contratos[1:Numero_de_contratos,2]
#Preco_Contrato = Dados_Contratos[1:Numero_de_contratos,3]

######## Variaveis vinculadas o periodo (t)
Preco_Spot = Dados_Estimados[1:Numero_de_meses,1]
Geracao_Estimada = Dados_Estimados[1:Numero_de_meses,2]
Custo_Geracao = Dados_Estimados[1:Numero_de_meses,3]


######## Funcoes modularizadas
function durante_o_contrato(Inicio, Duracao, t)
    final_contrato = (Inicio + Duracao)
    if  (Inicio<=t) && (final_contrato >= t)
        return 1;
    end
    return 0;
end


######## Define funcao preco dos contratos

for i in 1:Numero_de_contratos
    for t in 1:Numero_de_meses
        h[i,t] = durante_o_contrato(Data_Ini[i],Duracao[i],t)

        R_Comercializadora[i,t] = (p[i] - Preco_Spot[t])*q[i]*h[i,t];
        R_Gerador[i,t] = Geracao_Estimada[i]*(Preco_Spot[i] - Custo_Geracao[t] );

        Serie_temporal_Contratos[i,t]= p[i]*h[i,t]
    end

end

####### Define a receita Como a juncao das duas fontes de renda
R = R_Comercializadora + R_Gerador;
R_Gerador
R_Comercializadora

################################################################################
############################ Plot Dos Resultados ###############################
################################################################################



# Plot da curva de receitas Do contrato
for i in 1:Numero_de_contratos
    global Receitas
    if i==1
        Receitas = plot(1:Numero_de_meses,R_Comercializadora[1,:],
                    title="Receitas no tempo",
                    label= "Comercializadora no Contrato $i"
                )
                plot!(1:Numero_de_meses,R_Gerador[1,:],
                        title="Receitas no tempo",
                        label="Gerador no Contrato $i"
                )
    else
        plot!(1:Numero_de_meses,R_Comercializadora[i,:],
                title="Receitas no tempo",
                label= "Comercializadora no Contrato $i"
            )
        plot!(1:Numero_de_meses,R_Gerador[i,:],
                title="Receitas no tempo",
                label="Gerador no Contrato $i"
            )
    end
end
Receitas
savefig(Receitas,"C:\\Users\\rodri\\Desktop\\TFC\\Curvas_de_Receita.pdf")

# Plot de Curva de Precos dos Contratos
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
Grafico_Contrato
savefig(Grafico_Contrato,"C:\\Users\\rodri\\Desktop\\TFC\\Curvas_de_Contratos.pdf")

Data_Ini
Duracao
