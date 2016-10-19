clc;
clear;

%Características operativas UHE;

Volmax=100;     %Volume máximo
Volmin=40;      %Volume mínimo
Tumax=60;       %Turbinamento máximo
Prod=0.9;       %Produtibilidade

%Características operativas UTE;

L1max=22;       %Limite de cargabilidade máxima
L1min=0;        %Limite de cargabilidade mínima
Custo1=55;      %Custo de operação
L2max=27;       %Limite de cargabilidade máxima
L2min=0;        %Limite de cargabilidade mínima
Custo2=75;      %Custo de operação

%Corte de Carga;

CustoC=800;     %Custo do corte de carga

%Taxa associada ao custo futuro

T=1.1;

%Carga por estágio;

Carga=[60  40  30  20  40  50  60  70  40  30  20  30];

%Afluência por estágio;

E1= [40  35  30];
E2= [55  50  45];
E3= [70  65  60];
E4= [50  44  40];
E5= [30  26  20];
E6= [25  23  20];
E7= [15  12  10];
E8= [25  22  20];
E9= [30  25  20];
E10=[40  35  30];
E11=[50  47  40];
E12=[60  54  50];

E=[E1; E2; E3; E4; E5; E6; E7; E8; E9; E10; E11; E12;];

%Vetor nível de reservatório

Nivel=[Volmin:10:Volmax];


%Cálculo recursivo - Estágio final
%n - contagem do estágio
%i - contagem do nível de armazenamento no início do período
%j - contagem do nível de armazenamento no fim do período
%k - contagem da afluência

DecisaoPorAfluencia=[];
%Armazena os dados de decisao por afluencia
f=0;
%Armazena a factibilidade de cada caso
for n=size(E,1):-1:1  
    %Para cada estágio:
    load=Carga(n);
    %Atualiza a carga do estágio
    for i=length(Nivel):-1:1
        %Para cada nível de reservatório inicial:
        armi=Nivel(i);
        %Atualiza o nível inicial; Precisa mudar pra levar em conta o nível
        %da iteração anterior
        for j=length(Nivel):-1:1
            %Para cada nível de reservatório final:
            armf=Nivel(j);
            %Atualiza o nível final
            for k=1:size(E,2)
                %Para cada afluência:
                afl=E(n,k);
                %Atualiza a afluência
                en_util=min((armi-armf+afl),Tumax)*.9;
                %Calcula quanta energia pode ser gerada com a água,
                %considerando o turbinamento máximo
                %disponível
                if en_util<load
                    %Caso a energia da UHE não seja suficiente
                    if en_util<0
                        %Caso não seja possível atingir o nível de
                        %reservatório
                        f=f+1;
                        NaoFactivel(f,:)=[n i j k];                       
                        decisao_h=0;
                        %A decisao hidreletrica é nula
                    else
                        decisao_h=en_util;
                        %A decisao hidreletrica é turbinar todo o possivel
                    end
                    load_t1=load-decisao_h;
                    %Calcula o quanto falta pras térmicas gerarem
                    if L1max<load_t1
                        %Caso a térmica mais barata não seja suficiente
                        decisao_t1=L1max;
                        %A decisão pra térmica mais barata é gerar seu máximo
                        load_t2=load_t1-L1max;
                        %Calcula quanto falta pra térmica mais cara gerar
                        if L2max<load_t2
                            %Caso a térmica mais cara não seja suficiente
                            decisao_t2=L2max;
                            %A decisão pra térmica mais cara é gerar seu
                            %máximo
                            load_corte=load_t2-L2max;
                            %Calcula quanto vai restar pro corte de carga
                            decisao_corte=load_corte;
                            %O corte de carga gera o que falta
                        else
                            %Caso a térmica mais cara seja o suficiente
                            decisao_corte=0;
                            %Não é necessário corte de carga
                            decisao_t2=load_t2;
                            %A térmica mais cara gera o restante
                        end
                    else
                        %Caso a térmica mais barata seja o suficiente
                        decisao_corte=0;
                        %Não é necessário corte de carga
                        decisao_t2=0;
                        %Não é necessária a térmica mais cara
                        decisao_t1=load_t1;
                        %A térmica mais barata gera o restante
                    end
                else
                    %Caso a hidrelétrica seja o suficiente
                    decisao_corte=0;
                    decisao_t2=0;
                    decisao_t1=0;
                    %Não é necessário corte de carga nem UTEs
                    decisao_h=load;
                    %A hidrelétrica gera toda a energia necessária
                end
                DecisaoPorAfluencia(size(DecisaoPorAfluencia,1)+1,:)=[decisao_h decisao_t1 decisao_t2 decisao_corte];
                %Retorna a decisao tomada em cada caso
                %Caso a decisao da UHE seja zero, verificar matriz Factivel
                %Se Factivel tambem retornar zero, o caso é nao fáctivel
                decisao_h=0;
                decisao_t1=0;
                decisao_t2=0;
                decisao_corte=0;
                %Reinicializa as variáveis de decisão
            end            
        end
    end
end
DecisaoPorAfluencia
NaoFactivel