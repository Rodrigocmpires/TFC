function Generate_Data(Numero_de_meses,
                        Numero_de_contratos,
                        Numero_de_Cenarios_PLD,
                        Numero_de_Cenarios_Geracao,
                         regiao,
                         Numero_de_Regioes,
                         Regioes_Analisadas)

    Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses*Numero_de_Regioes,Numero_de_Cenarios_PLD))
    Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios_Geracao));
    Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos*Numero_de_Regioes,1));
    Duracao = convert(Array{Int64},zeros(Numero_de_contratos*Numero_de_Regioes,1));
    Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_meses,Numero_de_Cenarios_Geracao));
    p = convert(Matrix{Float64},zeros(Numero_de_contratos*Numero_de_Regioes,1))
    q = convert(Matrix{Float64},zeros(Numero_de_contratos*Numero_de_Regioes,1))
    Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos*Numero_de_Regioes,1))
    header_cenario_Geracao = Array{Union{Missing, String}}(missing, Numero_de_Cenarios_Geracao)
    header_cenario_PLD= Array{Union{Missing, String}}(missing, Numero_de_Cenarios_PLD)
    Regiao_Matrix_Mes = Array{Union{Missing, String}}(missing, Numero_de_meses,3)
    Regiao_Matrix_Contratos = Array{Union{Missing, String}}(missing, Numero_de_contratos,3)
    for j in 1:Numero_de_Cenarios_PLD
        for t in 1:Numero_de_meses*Numero_de_Regioes
            Preco_Spot[t,j] = 80 + rand()*40;
            header_cenario_PLD[j] = "Cenario $j";
        end
    end
    for j in 1:Numero_de_Cenarios_Geracao
        for t in 1:Numero_de_meses
            Custo_Geracao[t,j] = 0.001 + rand()/10000;
            header_cenario_Geracao[j] = "Cenario $j";
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
    Contratosdf = DataFrame( Regiao = Regiao_Contratos,
                            Data_Ini = Data_Ini[:],
                            Duracao = Duracao[:],
                            Preco_Contrato = p[:],
                            Carga_do_Contrato = q[:],
                            Porcentagem_do_contrato_no_Portifolio = Porcentagem_Portifolio[:])


    PrecoPLDdf = DataFrame([Regiao_Mes Preco_Spot])
    Geracao_Estimadadf = DataFrame(Geracao_Estimada)
    Custo_Estimadodf  = DataFrame(Custo_Geracao)

    CSV.write("Random_Data\\CSV\\Contratos.CSV", Contratosdf,delim = ';',);
    CSV.write("Random_Data\\CSV\\PLDEstimado.CSV", PrecoPLDdf,delim = ';',header = ["Regiao"; header_cenario_PLD[:]]);
    CSV.write("Random_Data\\CSV\\GeracaoEstimada.CSV", Geracao_Estimadadf,delim = ';',header = [header_cenario_Geracao[:]]);
    CSV.write("Random_Data\\CSV\\CustoPorGeracaoEstimado.CSV", Custo_Estimadodf,delim = ';',header = [header_cenario_Geracao[:]]);

    #Relendo o arquivo escrito para confirmar que de fato foi escrito e para adquirir os campos do Header
    Contratosdf = CSV.read("Random_Data\\CSV\\Contratos.CSV",delim = ';',header = true);
    PrecoPLDdf = CSV.read("Random_Data\\CSV\\PLDEstimado.CSV",delim = ';',header = true);
    ######## Variaveis vinculadas ao contrato (i)
    Dados_Contratos_regiao = filter(row -> row.Regiao ∈ [regiao], Contratosdf)
    Dados_Estimados_regiao = filter(row -> row.Regiao ∈ [regiao], PrecoPLDdf)
    Data_Ini_Regiao = Dados_Contratos_regiao[:,2]
    Duracao_Regiao = Dados_Contratos_regiao[:,3]
    p_Regiao = Dados_Contratos_regiao[:,4];
    q_Regiao = Dados_Contratos_regiao[:,5];
    Porcentagem_Portifolio_Regiao = Dados_Contratos_regiao[:,6];
    ######## Variaveis vinculadas o periodo (t)
    Preco_Spot_Regiao = convert( Matrix,Dados_Estimados_regiao[1:Numero_de_meses,2:Numero_de_Cenarios_PLD+1]);
    # Custo_Geracao = Dados_Estimados_regiao[1:Numero_de_meses,3]
    Regiao_PLD_Regiao = Dados_Estimados_regiao[1:Numero_de_meses,1];
    return Preco_Spot_Regiao,
            Custo_Geracao[:,1],
            Data_Ini_Regiao,
            Duracao_Regiao,
            Geracao_Estimada,
            p_Regiao,
            q_Regiao,
            Porcentagem_Portifolio_Regiao,
            header_cenario;
end

##################### Gera valores aleatorios para teste #######################
function Read_from_CSV(Numero_de_meses,
                        Numero_de_contratos,
                        Numero_de_Cenarios_PLD,
                        Numero_de_Cenarios_Geracao,
                        path_mode,
                        regiao)

    Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,1));
        Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,1));
        Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1));
        Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_Cenarios_Geracao,Numero_de_meses));
        p = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        q = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
        Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos,1));
    global Dados_Contratos, Dados_Estimados
    #Importa dados do CSV
    Dados_Contratos = CSV.read("$path_mode\\CSV\\Contratos_DB.csv",header = true, delim = ';');
    Dados_Estimados = CSV.read("$path_mode\\CSV\\Estimados_DB.csv",header = true, delim = ';');
    Dados_Geracao   = CSV.read("$path_mode\\CSV\\Geracao_DB.csv",header = true, delim = ';');

    ######## Variaveis vinculadas ao contrato (i)
    Dados_Contratos_regiao = filter(row -> row.Regiao ∈ [regiao], Dados_Contratos)
    Dados_Estimados_regiao = filter(row -> row.Regiao ∈ [regiao], Dados_Estimados)
    Data_Ini = Dados_Contratos_regiao[:,2]
    Duracao = Dados_Contratos_regiao[:,3]
    p = Dados_Contratos_regiao[:,4];
    q = Dados_Contratos_regiao[:,5];
    Porcentagem_Portifolio = Dados_Contratos_regiao[:,6];
    ######## Variaveis vinculadas o periodo (t)
    Preco_Spot = convert( Matrix, Dados_Estimados_regiao[1:Numero_de_meses,2:Numero_de_Cenarios_PLD+1]);
    Geracao_Estimada = convert( Matrix, Dados_Geracao[1:Numero_de_meses,1:Numero_de_Cenarios_Geracao]);
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

##################### Parametros exemplo de contrato e pld #######################
function Metodo_de_otimizacao(Numero_de_meses, Numero_de_contratos)
    Preco_Spot = convert(Matrix{Float64},zeros(Numero_de_meses,1));
    Custo_Geracao = convert(Matrix{Float64},zeros(Numero_de_meses,1));
    Data_Ini = convert(Array{Int64},zeros(Numero_de_contratos,1));
    Duracao = convert(Array{Int64},zeros(Numero_de_contratos,1));
    Geracao_Estimada = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
    p = convert(Matrix{Float64},zeros(Numero_de_contratos,1))
    q = convert(Matrix{Float64},zeros(Numero_de_contratos,1))
    Porcentagem_Portifolio = convert(Matrix{Float64},zeros(Numero_de_contratos,1))

end


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
                        regiao)

    Serie_temporal_Contratos= convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        h = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses))
        R_Comercializadora = convert(Matrix{Float64},zeros(Numero_de_contratos,Numero_de_meses));
        R_Gerador = convert(Matrix{Float64},zeros(Numero_de_Cenarios_Geracao,Numero_de_meses));
        R_Portifolio_Comercializadora = convert(Matrix{Float64},zeros(Numero_de_Cenarios_PLD,Numero_de_meses));
        header_cenario_PLD = Array{Union{Missing, String}}(missing, Numero_de_Cenarios_PLD)
        header_cenario_Geracao = Array{Union{Missing, String}}(missing, Numero_de_Cenarios_Geracao)
        R_Portifolio_Geradora_cenario_Geracao = convert(Matrix{Float64},zeros(Numero_de_Cenarios_Geracao,Numero_de_meses));
        R_Portifolio_Geradora_cenario_PLD = convert(Matrix{Float64},zeros(Numero_de_Cenarios_PLD,Numero_de_meses));
        Preco_Spot_Medio = (Preco_Spot*ones(Numero_de_Cenarios_PLD))'./size(1:Numero_de_Cenarios_PLD);

    for i in 1:Numero_de_contratos
        for t in 1:Numero_de_meses
            h[i,t] = durante_o_contrato(Data_Ini[i],Duracao[i],t);
        end
    end

    for j in 1:Numero_de_Cenarios_PLD

        for i in 1:Numero_de_contratos
            Serie_temporal_Contratos[i,:]= p[i].*h[i,:]
            R_Comercializadora[i,:] = ((p[i]*ones(Numero_de_meses) - Preco_Spot[:,j]).*q[i]).*h[i,:]
        end
        for n in 1:Numero_de_Cenarios_Geracao
            R_Gerador[n,:] = Geracao_Estimada[:,n].*(Preco_Spot[:,j] - Custo_Geracao[:] );
            R_Portifolio_Geradora_cenario_Geracao[n,:] = Geracao_Estimada[:,n].*(Preco_Spot_Medio[:] - Custo_Geracao[:] );
            header_cenario_Geracao[n] = "Cenario $n";
        end
        header_cenario_PLD[j] = "Cenario $j";
        R_Portifolio_Comercializadora[j,:] = Porcentagem_Portifolio'*R_Comercializadora
        #fixando os Cenarios de geracao na media por mes
        R_Portifolio_Geradora_cenario_PLD[j,:] = (R_Gerador'*ones(Numero_de_Cenarios_Geracao))'./size(1:Numero_de_Cenarios_Geracao);
    end
    R_Portifolio_Comercializadoradf = DataFrame(hcat(R_Portifolio_Comercializadora'))
    R_Portifolio_Geradora_cenario_PLDdf = DataFrame(hcat(R_Portifolio_Geradora_cenario_PLD'))
    R_Portifolio_Geradora_cenario_Geracaodf = DataFrame(hcat(R_Portifolio_Geradora_cenario_Geracao'))
    CSV.write("$path_mode\\CSV\\Receitas\\ReceitaComercializadora_$regiao.CSV", R_Portifolio_Comercializadoradf,delim = ';',header = header_cenario_PLD[:]);
    CSV.write("$path_mode\\CSV\\Receitas\\ReceitaGeracao_Cenario_PLD_$regiao.CSV", R_Portifolio_Geradora_cenario_PLDdf ,delim = ';',header = header_cenario_PLD[:]);
    CSV.write("$path_mode\\CSV\\Receitas\\ReceitaGeracao_Cenario_Geracao.CSV", R_Portifolio_Geradora_cenario_Geracaodf ,delim = ';',header = header_cenario_Geracao[:]);
    return R_Portifolio_Geradora_cenario_PLD,R_Portifolio_Geradora_cenario_Geracao,R_Portifolio_Comercializadora,R_Comercializadora,R_Gerador,Serie_temporal_Contratos,h;
end
