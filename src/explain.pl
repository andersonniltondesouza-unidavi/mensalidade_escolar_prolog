% --- Módulo de Explicação (Explain) ---
% Responsável por rastrear e imprimir as regras acionadas.

% Fato dinâmico para armazenar cada passo da explicação.
:- dynamic explicacao_passo/1.

% Limpa a trilha de explicação (para uma nova consulta).
limpar_explicacoes :-
    retractall(explicacao_passo(_)).

% Adiciona uma nova string formatada à trilha de explicação.
adicionar_explicacao(Formato, Args) :-
    format(string(Mensagem), Formato, Args),
    assertz(explicacao_passo(Mensagem)).

% Imprime o relatório final da explicação.
imprimir_explicacao :-
    writeln('\n--- Trilha de Decisão (Explicação) ---'),
    findall(Passo, explicacao_passo(Passo), Passos),
    (   Passos = [] ->
        writeln('Nenhuma regra foi acionada.')
    ;   
        print_passos(Passos)
    ).

% Predicado recursivo para imprimir a lista de passos
print_passos([]).
print_passos([H|T]) :-
    format('* ~w~n', [H]),
    print_passos(T).