% --- Módulo de Regras (Rules) ---
% Contém a lógica de inferência para calcular a mensalidade
% baseado nas regras do formulário web.

% --- REGRA 01: Meta Principal (Cálculo Final) ---
% O valor final é (Base + Multa) - DescontoFinal.
calcular_mensalidade(ValorFinal) :-
    regra_valor_base(Base),         % R02
    regra_multa_valor(Base, Multa), % R03
    regra_desconto_final(Base, DescontoFinal), % R06
    
    ValorFinal is (Base + Multa) - DescontoFinal,
    
    adicionar_explicacao('REGRA 01 (Final): (Base + Multa) - Desconto = (R$~2f + R$~2f) - R$~2f = R$~2f', [Base, Multa, DescontoFinal, ValorFinal]).

% --- REGRA 02: Obter Valor Base ---
% Apenas recupera o valor base inserido pelo usuário.
regra_valor_base(Base) :-
    contexto(base, Base),
    adicionar_explicacao('REGRA 02 (Base): Valor base definido: R$~2f.', [Base]).
% Tratamento de incerteza: Se contexto(base,_) falhar, R02 falha,
% e a R01 (principal) falha, ativando a mensagem de erro no main.pl.

% --- REGRA 03: Cálculo da Multa (Agregação) ---
% Determina qual regra de multa (R04 ou R05) usar.
regra_multa_valor(Base, Multa) :-
    (   regra_multa_aplicada(Base, Multa)  % Tenta aplicar R04
    ;   regra_multa_nao_aplicada(Multa) % Se falhar, aplica R05
    ).

% --- REGRA 04: Multa Aplicada (Atraso) ---
% Se o usuário indicou atraso (s)
regra_multa_aplicada(Base, Multa) :-
    observado(pagou_atrasado, s),
    contexto(multa_perc, Perc),
    Multa is Base * (Perc / 100),
    adicionar_explicacao('REGRA 04 (Multa): Pagamento atrasado. Multa de ~2f% (R$~2f) aplicada.', [Perc, Multa]).

% --- REGRA 05: Multa Não Aplicada ---
% Se o usuário indicou que não há atraso (n)
regra_multa_nao_aplicada(0.0) :-
    observado(pagou_atrasado, n),
    adicionar_explicacao('REGRA 05 (Multa): Pagamento em dia. Multa: R$ 0.00.', []).

% --- REGRA 06: Cálculo do Desconto Final (com Teto) ---
% Compara o desconto bruto (R07) com o teto (R10) e decide o valor final.
regra_desconto_final(Base, DescontoFinal) :-
    regra_desconto_bruto(Base, DescontoBruto), % R07
    regra_valor_teto(Base, TetoValor),         % R10
    (   
        % REGRA 08: Teto Aplicado
        DescontoBruto > TetoValor ->
        DescontoFinal = TetoValor,
        adicionar_explicacao('REGRA 08 (Teto): Teto de desconto aplicado. Desconto bruto (R$~2f) era maior que o teto (R$~2f).', [DescontoBruto, TetoValor])
    ;   
        % REGRA 09: Teto Não Aplicado
        DescontoBruto =< TetoValor,
        DescontoFinal = DescontoBruto,
        adicionar_explicacao('REGRA 09 (Teto): Desconto bruto (R$~2f) está dentro do teto (R$~2f).', [DescontoBruto, TetoValor])
    ).

% --- REGRA 07: Cálculo do Desconto Bruto (Agregação) ---
% Soma todos os descontos (Bolsa + Família)
regra_desconto_bruto(Base, DescontoBruto) :-
    regra_desconto_bolsa(Base, BolsaValor),     % R11
    regra_desconto_familia(Base, FamiliaValor), % R12
    DescontoBruto is BolsaValor + FamiliaValor,
    adicionar_explicacao('REGRA 07 (Bruto): Desconto Bruto = R$~2f (Bolsa) + R$~2f (Família) = R$~2f.', [BolsaValor, FamiliaValor, DescontoBruto]).

% --- REGRA 10: Cálculo do Valor do Teto ---
% Converte o Teto (%) em valor (R$)
regra_valor_teto(Base, TetoValor) :-
    contexto(teto_desc_perc, Perc),
    TetoValor is Base * (Perc / 100),
    adicionar_explicacao('REGRA 10 (Teto): Valor máximo de desconto (teto de ~2f%) é R$~2f.', [Perc, TetoValor]).

% --- REGRA 11: Cálculo do Desconto (Bolsa) ---
% Converte a Bolsa (%) em valor (R$)
regra_desconto_bolsa(Base, BolsaValor) :-
    observado(bolsa_perc, Perc),
    BolsaValor is Base * (Perc / 100),
    adicionar_explicacao('REGRA 11 (Desconto): Bolsa de ~2f% aplicada: R$~2f.', [Perc, BolsaValor]).

% --- REGRA 12: Cálculo do Desconto (Família) ---
% Converte o Desconto Família (%) em valor (R$)
regra_desconto_familia(Base, FamiliaValor) :-
    observado(familia_perc, Perc),
    FamiliaValor is Base * (Perc / 100),
    adicionar_explicacao('REGRA 12 (Desconto): Desconto Família de ~2f% aplicado: R$~2f.', [Perc, FamiliaValor]).