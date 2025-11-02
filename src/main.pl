% --- Módulo Principal (Orquestração) ---
:- encoding(utf8).
:- set_prolog_flag(encoding, utf8).

% Carrega os modulos do sistema
% 1. Carrega as definições (fatos dinâmicos)
:- [kb].
% 2. Carrega o helper de explicação
:- [explain].
% 3. Carrega as regras (que usam kb e explain)
:- [rules].
% 4. Carrega a interface (que usa kb)
:- [ui].

% --- Ponto de Entrada Principal ---
iniciar :-
    menu.

% --- Controle do Menu ---
menu :-
    exibir_menu,
    read_line_to_string(user_input, Opcao),
    processar_opcao(Opcao).

exibir_menu :-
    writeln('\n===================================================='),
    writeln('   Sistema Especialista: Cálculo de Mensalidade Escolar'),
    writeln('===================================================='),
    writeln('1. Executar cálculo para aluno'),
    writeln('2. Sair'),
    writeln('----------------------------------------------------'),
    writeln('Desenvolvido por: Anderson Nilton de Souza'),
    writeln('Desenvolvido por: Gabriel Welington Renzi'),
    write('Escolha uma opção: ').

processar_opcao("1") :-
    executar_calculo,
    menu.

processar_opcao("2") :-
    sair.

processar_opcao(_) :-
    writeln('\n[ERRO] Opção inválida. Pressione Enter para tentar novamente.'),
    read_line_to_string(user_input, _),
    menu.

% --- Orquestração do Cálculo ---
executar_calculo :-
    writeln('\n--- Iniciando Novo Cálculo para Aluno ---'),
    
    % 1. Limpa fatos dinâmicos da consulta anterior
    limpar_dados_memoria,
    limpar_explicacoes,
    
    % 2. Coleta os dados (configurações da turma e dados do aluno)
    coletar_dados,
    
    % 3. Executa a regra principal de inferência
    (   
        calcular_mensalidade(ValorFinal) ->
        % Se o cálculo for bem-sucedido
        format('~n>>> Resultado Final: O valor da mensalidade é R$ ~2f.~n', [ValorFinal]),
        imprimir_explicacao
    ;   
        % Tratamento de falha (se a Mensalidade Base não for informada)
        writeln('\n[AVISO] Não foi possível calcular o valor final.'),
        writeln('A Mensalidade Base (R$) não foi informada ou é inválida.'),
        imprimir_explicacao
    ).

sair :-
    writeln('\nEncerrando o sistema. Aperte Ctrl+C e E para encerrar').