% --- Módulo de Interface ---
% Responsável por coletar dados do usuário e popular a memória de trabalho
% (contexto/2 e observado/2).

% Orquestra a coleta de todos os dados
coletar_dados :-
    writeln('\n--- 1. Configurações da Turma ---'),
    coletar_config_turma,
    writeln('\n--- 2. Dados do Aluno/Pagamento ---'),
    coletar_dados_aluno.

% --- Bloco 1: Configurações da Turma ---
coletar_config_turma :-
    perguntar_numero(contexto(base), 'Mensalidade Base (R$):', 0, 999999),
    perguntar_numero(contexto(multa_perc), 'Multa por Atraso (%):', 0, 100),
    perguntar_numero(contexto(teto_desc_perc), 'Teto de Desconto (%):', 0, 100).

% --- Bloco 2: Dados do Aluno ---
coletar_dados_aluno :-
    perguntar_sim_nao(pagou_atrasado, 'O pagamento foi/será feito com atraso?'),
    perguntar_numero(observado(bolsa_perc), 'Bolsa (%):', 0, 100),
    perguntar_numero(observado(familia_perc), 'Desconto Família (%):', 0, 100).


% --- Predicados Helpers (Validação de Entrada) ---

% Helper para perguntas de Sim/Não 
perguntar_sim_nao(Atributo, Pergunta) :-
    format('~w (s/n)?~n', [Pergunta]),
    read_line_to_string(user_input, Resposta),
    string_lower(Resposta, RLower),
    (   
        (RLower == "s" ; RLower == "sim") -> assertz(observado(Atributo, s))
    ;   
        (RLower == "n" ; RLower == "nao") -> assertz(observado(Atributo, n))
    ;   
        writeln('[ERRO] Resposta inválida. Use "s" ou "n".'),
        perguntar_sim_nao(Atributo, Pergunta) % Recursão
    ).

% Helper para perguntas numéricas com validação
% formato: perguntar_numero(Predicado(Atributo), Pergunta, Min, Max)
perguntar_numero(Predicado, Pergunta, Min, Max) :-
    format('~w (entre ~w e ~w)~n', [Pergunta, Min, Max]),
    read_line_to_string(user_input, String),
    (   
        number_string(Numero, String), Numero >= Min, Numero =< Max ->
        (
            % --- INÍCIO DA CORREÇÃO ---
            % O predicado é passado como 'contexto(base)'.
            % Precisamos decompor e recompor com o novo valor numérico.
            Predicado =.. [Functor, Atributo], % Decompõe: Functor=contexto, Atributo=base
            
            % Constrói o novo termo ANTES de assertar
            Termo =.. [Functor, Atributo, Numero], % Recompõe: Termo = contexto(base, 1000)
            
            % A sintaxe 'assertz(..[...])' estava errada.
            assertz(Termo)
            % --- FIM DA CORREÇÃO ---
        )
    ;   
        format('[ERRO] Valor inválido. Insira um número entre ~w e ~w.~n', [Min, Max]),
        perguntar_numero(Predicado, Pergunta, Min, Max) % Recursão
    ).