function Generate_Data(Numero_de_meses, Numero_de_contratos,Numero_de_Cenarios, regiao,Numero_de_Regioes,Regioes_Analisadas)
    Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses*Numero_de_Regioes,Numero_de_Cenarios))
    Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses*Numero_de_Regioes,Numero_de_Cenarios));
    Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos*Numero_de_Regioes,1));
    Duracao = convert(Array{Int64},zeros(Numero_de_contratos*Numero_de_Regioes,1));
    Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_meses*Numero_de_Regioes,Numero_de_Cenarios));
    p = convert(Matrix{Float64},zeros(Numero_de_contratos*Numero_de_Regioes,1))
    q = convert(Matrix{Float64},zeros(Numero_de_contratos*Numero_de_Regioes,1))
    Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos*Numero_de_Regioes,1))
    header_cenario = Array{Union{Missing, String}}(missing, Numero_de_Cenarios)
    Regiao_Matrix_Mes = Array{Union{Missing, String}}(missing, Numero_de_meses,3)
    Regiao_Matrix_Contratos = Array{Union{Missing, String}}(missing, Numero_de_contratos,3)
    for j in 1:Numero_de_Cenarios
        for t in 1:Numero_de_meses*Numero_de_Regioes
            Preco_Spot[t,j] = 80 + rand()*40;
            Custo_Geracao[t,j] = 0.1 + rand()/100;
            header_cenario[j] = "Cenario $j";
            Geracao_Estimada[t,j] = 500 + rand()*50;
        end
    end
    for t in 1:Numero_de_meses
        Regiao_Matrix_Mes[t,:] = Regioes_Analisadas;
    end
    for t in 1:Numero_de_contratos
        Regiao_Matrix_Contratos[t,:] = Regioes_Analisadas;
    end
    Regiao_Mes = [Regiao_Matrix_Mes[:,1]' Regiao_Matrix_Mes[:,2]' Regiao_Matrix_Mes[:,3]']'
    Regiao_Contratos = [Regiao_Matrix_Contratos[:,1]' Regiao_Matrix_Contratos[:,2]' Regiao_Matrix_Contratos[:,3]']'
    for i in 1:Numero_de_contratos*Numero_de_Regioes
        p[i]= 100 + rand()*10;
        q[i]= 500 + rand()*50;
        Data_Ini[i]= rand(1:Numero_de_meses-1);
        Duracao[i]= rand(1:Numero_de_meses - Data_Ini[i]);
        Porcentagem_Portifolio[i] = rand();
    end
    for i in 1:Numero_de_Regioes
        ini = 1+ (i-1)*Numero_de_contratos;
        fim =  i*Numero_de_contratos;
        Porcentagem_Portifolio[ini:fim] = Porcentagem_Portifolio[ini:fim]./
            (Porcentagem_Portifolio[ini:fim]'*ones(Numero_de_contratos));

    end
    π

    Contratosdf = DataFrame( Regiao = Regiao_Contratos,
                            Data_Ini = Data_Ini[:],
                            Duracao = Duracao[:],
                            Preco_Contrato = p[:],
                            Carga_do_Contrato = q[:],
                            Porcentagem_do_contrato_no_Portifolio = Porcentagem_Portifolio[:])


    PrecoPLDdf = DataFrame([Regiao_Mes Preco_Spot])
    Geracao_Estimadadf = DataFrame([Regiao_Mes Geracao_Estimada])
    Custo_Estimadodf  = DataFrame([Regiao_Mes Custo_Geracao])

    CSV.write("Random_Data\\CSV\\Contratos.CSV", Contratosdf,delim = ';',);
    CSV.write("Random_Data\\CSV\\PLDEstimado.CSV", PrecoPLDdf,delim = ';',header = ["Regiao"; header_cenario[:]]);
    CSV.write("Random_Data\\CSV\\GeracaoEstimada.CSV", Geracao_Estimadadf,delim = ';',header = ["Regiao"; header_cenario[:]]);
    CSV.write("Random_Data\\CSV\\CustoPorGeracaoEstimado.CSV", Custo_Estimadodf,delim = ';',header = ["Regiao"; header_cenario[:]]);

    #Relendo o arquivo escrito para confirmar que de fato foi escrito e para adquirir os campos do Header
    Contratosdf = CSV.read("Random_Data\\CSV\\Contratos.CSV",delim = ';',header = true);
    PrecoPLDdf = CSV.read("Random_Data\\CSV\\PLDEstimado.CSV",delim = ';',header = true);
    Geracao_Estimadadf = CSV.read("Random_Data\\CSV\\GeracaoEstimada.CSV",delim = ';',header = true);
    Custo_Estimadodf = CSV.read("Random_Data\\CSV\\CustoPorGeracaoEstimado.CSV",delim = ';',header = true);
    ######## Variaveis vinculadas ao contrato (i)
    Dados_Contratos_regiao = filter(row -> row.Regiao ∈ [regiao], Contratosdf)
    Dados_Estimados_regiao = filter(row -> row.Regiao ∈ [regiao], PrecoPLDdf)
    Dados_Geracao = filter(row -> row.Regiao ∈ [regiao], Geracao_Estimadadf)
    Dados_Custo_Geracao_Regiao = filter(row -> row.Regiao ∈ [regiao], Custo_Estimadodf)
    Data_Ini_Regiao = Dados_Contratos_regiao[:,2]
    Duracao_Regiao = Dados_Contratos_regiao[:,3]
    p_Regiao = Dados_Contratos_regiao[:,4];
    q_Regiao = Dados_Contratos_regiao[:,5];
    Porcentagem_Portifolio_Regiao = Dados_Contratos_regiao[:,6];
    ######## Variaveis vinculadas o periodo (t)
    Preco_Spot_Regiao = Dados_Estimados_regiao[1:Numero_de_meses,2:Numero_de_Cenarios+1];
    Geracao_Estimada_Regiao = Dados_Geracao[1:Numero_de_meses,2];
    # Custo_Geracao = Dados_Estimados_regiao[1:Numero_de_meses,3]
    Regiao_PLD_Regiao = Dados_Estimados_regiao[1:Numero_de_meses,1];
    Custo_Geracao_Regiao =  Dados_Custo_Geracao_Regiao[1:Numero_de_meses,2];
    return Preco_Spot_Regiao,
            Custo_Geracao_Regiao,
            Data_Ini_Regiao,
            Duracao_Regiao,
            Geracao_Estimada_Regiao,
            p_Regiao,
            q_Regiao,
            Porcentagem_Portifolio_Regiao,
            header_cenario;
end

##################### Gera valores aleatorios para teste #######################
function Read_from_CSV(Numero_de_meses, Numero_de_contratos,Numero_de_Cenarios,regiao)
    Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,1));
        Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,1));
        Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        p = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        q = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
    global Dados_Contratos, Dados_Estimados
    #Importa dados do CSV
    Dados_Contratos = CSV.read("Data_From_CSV\\CSV\\Contratos_DB.csv",header = true, delim = ';');
    Dados_Estimados = CSV.read("Data_From_CSV\\CSV\\Estimados_DB.csv",header = true, delim = ';');
    Dados_Geracao   = CSV.read("Data_From_CSV\\CSV\\Geracao_DB.csv",header = true, delim = ';');

    # struct Struct_regiao
    #     Norte::AbstractDataFrame
    #     Sudeste::AbstractDataFrame
    #     Nordeste::AbstractDataFrame
    # end
    # Dados_Contratos_regiao = Struct_regiao(teste_norte,teste_sudeste,teste_nordeste);
    ######## Variaveis vinculadas ao contrato (i)
    Dados_Contratos_regiao = filter(row -> row.Regiao ∈ [regiao], Dados_Contratos)
    Dados_Estimados_regiao = filter(row -> row.Regiao ∈ [regiao], Dados_Estimados)
    Data_Ini = Dados_Contratos_regiao[:,2]
    Duracao = Dados_Contratos_regiao[:,3]
    p = Dados_Contratos_regiao[:,4];
    q = Dados_Contratos_regiao[:,5];
    Porcentagem_Portifolio = Dados_Contratos_regiao[:,6];
    ######## Variaveis vinculadas o periodo (t)
    Preco_Spot = Dados_Estimados_regiao[1:Numero_de_meses,2:Numero_de_Cenarios+1];
    Geracao_Estimada = Dados_Geracao[1:Numero_de_meses,1];
    # Custo_Geracao = Dados_Estimados_regiao[1:Numero_de_meses,3]
    Regiao_PLD = Dados_Estimados_regiao[1:Numero_de_meses,1];

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
                        Porcentagem_Portifolio,
                        path_mode,
                        regiao)

    Serie_temporal_Contratos= convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        h = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses))
        R_Comercializadora = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        R_Gerador = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        R_Portifolio_Geradora = convert(Matrix{Float64},zeros(Numero_de_Cenarios,Numero_de_meses));
        R_Portifolio_Comercializadora = convert(Matrix{Float64},zeros(Numero_de_Cenarios,Numero_de_meses));
        header_cenario = Array{Union{Missing, String}}(missing, Numero_de_Cenarios)

    for j in 1:Numero_de_Cenarios
        for i in 1:Numero_de_contratos
            for t in 1:Numero_de_meses
                h[i,t] = durante_o_contrato(Data_Ini[i],Duracao[i],t);
                R_Comercializadora[i,t] = (p[i] - Preco_Spot[t,j])*q[i]*h[i,t];
                R_Gerador[i,t] = Geracao_Estimada[i]*(Preco_Spot[i,j] - Custo_Geracao[t] );

                Serie_temporal_Contratos[i,t]= p[i]*h[i,t]
            end
        end
        header_cenario[j] = "Cenario $j";
        R_Portifolio_Comercializadora[j,:] = Porcentagem_Portifolio'*R_Comercializadora
        R_Portifolio_Geradora[j,:] = Porcentagem_Portifolio'*R_Gerador
    end
    R_Portifolio_Comercializadoradf = DataFrame(hcat(R_Portifolio_Comercializadora'))
    R_Portifolio_Geradoradf = DataFrame(hcat(R_Portifolio_Geradora'))
    CSV.write("$path_mode\\CSV\\Receitas\\ReceitaComercializadora_$regiao.CSV", R_Portifolio_Comercializadoradf,delim = ';',header = header_cenario[:]);
    CSV.write("$path_mode\\CSV\\Receitas\\ReceitaGeracao_$regiao.CSV", R_Portifolio_Geradoradf,delim = ';',header = header_cenario[:]);
    return R_Portifolio_Geradora,R_Portifolio_Comercializadora,R_Comercializadora,R_Gerador,Serie_temporal_Contratos,h;
end
