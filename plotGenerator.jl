using Plots
function PlotGenerator(    Numero_de_contratos,
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

    CaminhoRegiao = "_$regiao"

   Grafico_Contrato = Contract_Price_Curve_Plot(
                           Numero_de_contratos,
                           Serie_temporal_Contratos,
                           path_mode,
                           CaminhoRegiao
                           );

   Graf_Comercializador = Curvas_de_Receita(
                       Numero_de_contratos,
                       Numero_de_meses,
                       Numero_de_Cenarios_Geracao,
                       R_Comercializadora,
                       R_Gerador,
                       path_mode,
                       CaminhoRegiao
                       );
   Graf_Portifolio_Comercializadora = Portifolio_Curve(
                       Numero_de_contratos,
                       Numero_de_meses,
                       Numero_de_Cenarios_PLD,
                       R_Portifolio_Comercializadora,
                       path_mode,
                       "Comercializadora",
                       "Comercializadora",
                       CaminhoRegiao
                       );
   Graf_Portifolio_Geradora_Cenario_Geracao = Portifolio_Curve(
                       Numero_de_contratos,
                       Numero_de_meses,
                       Numero_de_Cenarios_Geracao,
                       R_Portifolio_Geradora_cenario_Geracao,
                       path_mode,
                       "Geradora Cenario Geracao",
                       "Geradora_Cenario_Geracao",
                       CaminhoRegiao
                       );
   Graf_Portifolio_Geradora_Cenario_PLD = Portifolio_Curve(
                       Numero_de_contratos,
                       Numero_de_meses,
                       Numero_de_Cenarios_PLD,
                       R_Portifolio_Geradora_cenario_PLD,
                       path_mode,
                       "Geradora Cenario PLD",
                       "Geradora_Cenario_PLD",
                       CaminhoRegiao
                       );
    global Grafico_Contrato,Graf_Comercializador, Graf_Portifolio_Comercializadora,Graf_Portifolio_Geradora_Cenario_PLD,Graf_Portifolio_Geradora_Cenario_Geracao
   return Grafico_Contrato,Graf_Comercializador, Graf_Portifolio_Comercializadora,Graf_Portifolio_Geradora_Cenario_PLD,Graf_Portifolio_Geradora_Cenario_Geracao;
end

# Plot de Curva de Precos dos Contratos
function Contract_Price_Curve_Plot( Numero_de_contratos,
                                    Serie_temporal_Contratos,
                                    path_mode,
                                    CaminhoRegiao
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
    savefig(Grafico_Contrato,"$path_mode\\Plot\\Curvas_de_Contratos_$(path_mode)$CaminhoRegiao.pdf")
    return Grafico_Contrato
end
# Plot da curva de receitas Do contrato
function Curvas_de_Receita(Numero_de_contratos,
                            Numero_de_meses,
                            Numero_de_Cenarios_Geracao,
                            R_Comercializadora,
                            R_Gerador,
                            path_mode,
                            CaminhoRegiao
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
    savefig(Plot_Comercializadora,
            "$path_mode\\Plot\\Curvas_de_Receita_Comercializadora_$(path_mode)$CaminhoRegiao.pdf"
            )
    return Plot_Comercializadora;
end
function Portifolio_Curve(
                        Numero_de_contratos,
                        Numero_de_meses,
                        Numero_de_Cenarios,
                        R_Portifolio,
                        path_mode,
                        PortifolioTitle,
                        Portifolioname,
                        CaminhoRegiao
                        )

    for i in 1:Numero_de_Cenarios
        global Plot_Portifolio
        if i ==1
            Plot_Portifolio = plot(1:Numero_de_meses,R_Portifolio[i,:],
                    title = "Receitas do Portifólio da $PortifolioTitle no tempo",
                    label = "Cenário $i"
                    # label= "Curvas de Receita Comercializadora no Cenario $i"
                )
        else
            plot!(1:Numero_de_meses,R_Portifolio[i,:],
                    title = "Receitas do Portifólio da $PortifolioTitle no tempo",
                    label = "Cenário $i"
                    # label= "Curvas de Receita Comercializadora no Cenario $i"
                )
        end
    end
    savefig(Plot_Portifolio,
            "$path_mode\\Plot\\Curvas_de_Receita_Portifolio_$(Portifolioname)_$(path_mode)$CaminhoRegiao.pdf"
            )

    return Plot_Portifolio;
end
