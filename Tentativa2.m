clc;
clear;

%Inicializa��o dos dados

%Caracter�sticas operativas UHE;

Volmax=100;     %Volume m�ximo
Volmin=40;      %Volume m�nimo
Tumax=60;       %Turbinamento m�ximo
Prod=0.9;       %Produtibilidade

%Caracter�sticas operativas UTE;

L1max=22;       %Limite de cargabilidade m�xima
L1min=0;        %Limite de cargabilidade m�nima
custo1=55;      %Custo de opera��o
L2max=27;       %Limite de cargabilidade m�xima
L2min=0;        %Limite de cargabilidade m�nima
custo2=75;      %Custo de opera��o

%Corte de Carga;

custoc=800;     %Custo do corte de carga

%Taxa associada ao custo futuro

T=1.1;

%Carga por est�gio;

Carga=[60  40  30  20  40  50  60  70  40  30  20  30];

%Aflu�ncia por est�gio;

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

%Vetor n�vel de reservat�rio

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
custo_esperado=[];
custo_otimo=[];
afluencia=[];

Tabela=[];
posicaocustootimo=[];
vetor_custo_otimo=[];
vetor_custo_menor=[];
vetor_custo_esperado=[];
f=0;
teste=[];

for n=size(E,1):-1:1  
    %Para cada est�gio:
    load=Carga(n);
    %Atualiza a carga do est�gio
    for i=1:length(Nivel)
        %Para cada n�vel de reservat�rio inicial:
        armi=Nivel(i);
        %Atualiza o n�vel inicial; Precisa mudar pra levar em conta o n�vel
        %da itera��o anterior
        for j=1:length(Nivel)
            %Para cada n�vel de reservat�rio final:
            armf=Nivel(j);
            %Atualiza o n�vel final
            if size(vetor_custo_menor,1)~=0    
                custof=vetor_custo_menor(j,1)/1.1;
            else
                custof=0;
            end
            %Atualiza o n�vel final
            for k=1:size(E,2)
                %Para cada aflu�ncia:
                afl=E(n,k);
                %Atualiza a aflu�ncia
                en_util=min((armi-armf+afl),Tumax)*.9;
                %Calcula quanta energia pode ser gerada com a �gua,
                %considerando o turbinamento m�ximo
                %dispon�vel
                if en_util<load
                    %Caso a energia da UHE n�o seja suficiente
                    if en_util<0
                        %Caso n�o seja poss�vel atingir o n�vel de
                        %reservat�rio
                        f=f+1;
                        NaoFactivel(f,:)=[n i j k];
                        %Est�gio, nivel inicial, nivel final e afluencia
                        %nao factivel
                        decisao_h=-1;
                        %A decisao hidreletrica � nula
                    else
                        decisao_h=en_util;
                        %A decisao hidreletrica � turbinar todo o possivel
                    end
                    load_t1=load-max(decisao_h,0);
                    %Calcula o quanto falta pras t�rmicas gerarem
                    if L1max<load_t1
                        %Caso a t�rmica mais barata n�o seja suficiente
                        decisao_t1=L1max;
                        %A decis�o pra t�rmica mais barata � gerar seu m�ximo
                        load_t2=load_t1-L1max;
                        %Calcula quanto falta pra t�rmica mais cara gerar
                        if L2max<load_t2
                            %Caso a t�rmica mais cara n�o seja suficiente
                            decisao_t2=L2max;
                            %A decis�o pra t�rmica mais cara � gerar seu
                            %m�ximo
                            load_corte=load_t2-L2max;
                            %Calcula quanto vai restar pro corte de carga
                            decisao_corte=load_corte;
                            %O corte de carga gera o que falta
                        else
                            %Caso a t�rmica mais cara seja o suficiente
                            decisao_corte=0;
                            %N�o � necess�rio corte de carga
                            decisao_t2=load_t2;
                            %A t�rmica mais cara gera o restante
                        end
                    else
                        %Caso a t�rmica mais barata seja o suficiente
                        decisao_corte=0;
                        %N�o � necess�rio corte de carga
                        decisao_t2=0;
                        %N�o � necess�ria a t�rmica mais cara
                        decisao_t1=load_t1;
                        %A t�rmica mais barata gera o restante
                    end
                else
                    %Caso a hidrel�trica seja o suficiente
                    decisao_corte=0;
                    decisao_t2=0;
                    decisao_t1=0;
                    %N�o � necess�rio corte de carga nem UTEs
                    decisao_h=load;
                    %A hidrel�trica gera toda a energia necess�ria
                end
                
                custoi=decisao_t1*custo1+decisao_t2*custo2+decisao_corte*custoc;
                custot=custoi+custof;
                
                estagio(length(estagio)+1)=n;
                armazenamentoinicial(length(armazenamentoinicial)+1)=armi; 
                armazenamentofinal(length(armazenamentofinal)+1)=armf;
                afluencia(length(afluencia)+1)=afl;
                decisaohidreletrica(length(decisaohidreletrica)+1)=decisao_h; 
                decisaoute1(length(decisaoute1)+1)=decisao_t1; 
                decisaoute2(length(decisaoute2)+1)=decisao_t2;
                decisaocortedecarga(length(decisaocortedecarga)+1)=decisao_corte;
                custo_imediato(length(custo_imediato)+1)=custoi;
                custo_futuro(length(custo_futuro)+1)=custof;
                custo_total(length(custo_total)+1)=custot;
                if k==size(E,2)
                    custoaf=custo_total(length(custo_total)-size(E,2)+1:length(custo_total));
                    custoes=sum(custoaf)/length(custoaf);
                    custo_esperado(length(custo_esperado)-1)=custoes;
                    custo_esperado(length(custo_esperado))=custoes;
                    custo_esperado(length(custo_esperado)+1)=custoes;
                    vetor_custo_esperado(length(vetor_custo_esperado)+1)=custoes;
                else
                    custo_esperado(length(custo_esperado)+1)=-1;
                end
                custo_otimo(length(custo_otimo)+1)=-1;
                
                decisao_h=0;
                decisao_t1=0;
                decisao_t2=0;
                decisao_corte=0;
                %Reinicializa as vari�veis de decis�o
            end
        end
        A=vetor_custo_esperado(length(vetor_custo_esperado)-length(Nivel)+1:length(vetor_custo_esperado));
        teste(length(teste)+1:length(teste)+7)=[A];
        B=min(A);
        C=A==B;
        %custo_otimo(length(custo_otimo))=B;
        custo_otimo(length(custo_otimo)-k*length(Nivel)+1)=B;
        vetor_custo_otimo(size(vetor_custo_otimo,1)+1,1)=B;
        vetor_custo_otimo(size(vetor_custo_otimo,1),2)=armi;
        vetor_custo_otimo(size(vetor_custo_otimo,1),3)=n;
        posicaocustootimo(size(posicaocustootimo,1)+1,:)=C;
    end
    vetor_custo_menor=vetor_custo_otimo((size(vetor_custo_otimo,1)+1-length(Nivel):size(vetor_custo_otimo,1)),:);
end

Tabela=[
    estagio
    armazenamentoinicial
    armazenamentofinal
    afluencia
    decisaohidreletrica
    decisaoute1
    decisaoute2
    decisaocortedecarga
    custo_imediato
    custo_futuro
    custo_total
    custo_esperado
    custo_otimo
    ];

Arvore=[vetor_custo_otimo posicaocustootimo];



filename = 'dados.xlsx';
xlswrite(filename,Tabela)
 
 
filename = 'dadosarvore.xlsx';
xlswrite(filename,Arvore)