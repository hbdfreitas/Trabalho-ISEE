clc;
clear;

%Inicialização dos dados

%Características operativas UHE;

Volmax=100;     %Volume máximo
Volmin=40;      %Volume mínimo
Tumax=60;       %Turbinamento máximo
Prod=0.9;       %Produtibilidade

%Características operativas UTE;

L1max=22;       %Limite de cargabilidade máxima
L1min=0;        %Limite de cargabilidade mínima
custo1=55;      %Custo de operação
L2max=27;       %Limite de cargabilidade máxima
L2min=0;        %Limite de cargabilidade mínima
custo2=75;      %Custo de operação

%Corte de Carga;

custoc=800;     %Custo do corte de carga

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

Nivel=[Volmax:-10:Volmin];

estagio=[]; 
armazenamentoinicial=[]; 
armazenamentofinal=[]; 
decisaohidreletrica=[]; 
decisaoute1=[]; 
decisaoute2=[];
decisaocortedecarga=[];
custo_imediato=[];
custo_futuro=[];
custo_total=[];
                
custo_futuro=0;
Tabela=[];
f=0;

for n=size(E,1):-1:12  
    %Para cada estágio:
    load=Carga(n);
    %Atualiza a carga do estágio
    for i=1:length(Nivel)
        %Para cada nível de reservatório inicial:
        armi=Nivel(i);
        %Atualiza o nível inicial; Precisa mudar pra levar em conta o nível
        %da iteração anterior
        for j=1:length(Nivel)
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
                        %Estágio, nivel inicial, nivel final e afluencia
                        %nao factivel
                        decisao_h=-1;
                        %A decisao hidreletrica é nula
                    else
                        decisao_h=en_util;
                        %A decisao hidreletrica é turbinar todo o possivel
                    end
                    load_t1=load-max(decisao_h,0);
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
                
                custoi=decisao_t1*custo1+decisao_t2*custo2+decisao_corte*custoc;
                custof=0;
                custot=custoi+custof;
                
                
                estagio(length(estagio)+1)=n;
                armazenamentoinicial(length(armazenamentoinicial)+1)=armi; 
                armazenamentofinal(length(armazenamentoinicial)+1)=armf; 
                decisaohidreletrica(length(decisaohidreletrica)+1)=decisao_h; 
                decisaoute1(length(decisaoute1)+1)=decisao_t1; 
                decisaoute2(length(decisaoute2)+1)=decisao_t2;
                decisaocortedecarga(length(decisaocortedecarga)+1)=decisao_corte;
                custo_imediato(length(custo_imediato)+1)=custoi;
                custo_futuro(length(custo_futuro)+1)=custof;
                custo_total(length(custo_total)+1)=custoc;
                    
                decisao_h=0;
                decisao_t1=0;
                decisao_t2=0;
                decisao_corte=0;
                %Reinicializa as variáveis de decisão
            end
            custoaf=custo_imediato(length(custo_imediato)-2:length(custo_imediato));
            custo_esperado=[sum(custoaf)/length(custoaf) sum(custoaf)/length(custoaf) sum(custoaf)/length(custoaf)];
        end
    end
end
