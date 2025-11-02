% --- Base de Conhecimento---
% Define os predicados dinâmicos que armazenarão as
% entradas do usuário (Configurações da Turma e Dados do Aluno).

% --- Fatos Dinâmicos ---

% 1. Configurações da Turma (contexto)
% Serão 'assertados' pelo ui.pl
% formato: contexto(Atributo, Valor).
:- dynamic contexto/2.
% Ex: contexto(base, 1000).
% Ex: contexto(multa_perc, 5).
% Ex: contexto(teto_desc_perc, 30).

% 2. Dados do Aluno (observações)
% Serão 'assertados' pelo ui.pl
% formato: observado(Atributo, Valor).
:- dynamic observado/2.
% Ex: observado(pagou_atrasado, s).
% Ex: observado(bolsa_perc, 10).
% Ex: observado(familia_perc, 0).


% Predicado para limpar a memória de trabalho para um novo cálculo
limpar_dados_memoria :-
    retractall(contexto(_,_)),
    retractall(observado(_,_)).