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

%Cálculo recursivo