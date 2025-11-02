# Sistema Especialista em Prolog: Cálculo de Mensalidade Escolar

Este projeto é um sistema especialista desenvolvido em **SWI-Prolog**, como parte dos requisitos da disciplina de Linguagens de Programação e Paradigmas. O objetivo principal é demonstrar a aplicação de conceitos de **Programação Lógica** (fatos, regras e motor de inferência) para resolver um problema de negócio. O sistema replica a lógica de um formulário de cálculo de mensalidade, coletando dados do usuário via console e inferindo o valor final com base em um conjunto de regras de negócio (multa, descontos, teto).

`**Desenvolvido por:**
* `@[andersonniltondesouza-unidavi]`
* `@[GabrielRenzi]`

---

## 📂 Arquitetura do Projeto

A aplicação é modularizada para separar as responsabilidades, seguindo a arquitetura de sistemas especialistas:

```
/ 
├── src/
│   ├── main.pl          # Ponto de entrada, menu principal e orquestração do fluxo
│   ├── kb.pl            # Base de Conhecimento (definição dos fatos dinâmicos)
│   ├── ui.pl            # Interface com Usuário (perguntas, validação e 'assert' dos fatos)
│   ├── rules.pl         # Regras de negócio, lógica de inferência e cálculos
│   └── explain.pl       # Sistema de explicação (rastreia e exibe as regras acionadas)
└── README.md            # Esta documentação
```

---

## 🛠️ Como Executar a Aplicação

A aplicação requer o **SWI-Prolog** para ser executada.

1. **Instale o SWI-Prolog:**

   * Faça o download e instale o compilador/interpretador a partir do [site oficial do SWI-Prolog](https://www.swi-prolog.org/download/stable).

2. **Clone o repositório:**

   ```bash
   git clone [https://github.com/andersonniltondesouza-unidavi/mensalidade_escolar_prolog]
   ```

3. **Acesse o diretório `src`:**

   ```bash
   cd [DIRETÓRIO ONDE FOI BAIXADO O PROJETO]/src
   ```

4. **Execute o sistema:**

   * Inicie o programa diretamente pelo terminal. O comando `-s main.pl` carrega o arquivo principal e `-g iniciar` define o predicado (meta) que deve ser executado na inicialização (o nosso menu).

   ```bash
   swipl -s main.pl -g iniciar
   ```

5. O menu interativo será exibido no console.

---

## 🧠 Funcionamento e Conceitos de Programação Lógica

Este projeto separa a lógica de inferência (pura) da coleta de dados e exibição (impuras). Toda a lógica de cálculo está em `rules.pl` como regras declarativas.

### 1. Base de Conhecimento Dinâmica (Fatos)

Diferente da PF (onde o estado é passado), em Prolog o "estado" da consulta é mantido na **Base de Conhecimento**. Em `kb.pl`, definimos predicados dinâmicos que funcionam como a "memória de trabalho" da aplicação:

* `contexto(Atributo, Valor)`: Armazena as "Configurações da Turma" (Base, Multa, Teto).
* `observado(Atributo, Valor)`: Armazena os "Dados do Aluno" (Atraso, Bolsa, Família).

### 2. Coleta e "Assert" de Dados (`ui.pl`)

Este módulo é **impuro**, pois interage com o usuário (I/O). Ele faz as perguntas e usa `assertz/1` para popular a Base de Conhecimento.

```prolog
% Pergunta ao usuário e depois "afirma" o fato na memória:
assertz(contexto(base, 1000)).
assertz(observado(pagou_atrasado, n)).
```

Ao final da coleta, a Base de Conhecimento está pronta para a inferência.

---

### 3. Motor de Inferência e Regras (`rules.pl`)

Esta é a parte "pura" e declarativa. Em vez de map ou reduce, definimos regras (predicados) que descrevem o que é o resultado. O Prolog usa seu motor de inferência (baseado em unificação e backtracking) para "descobrir" o valor.

A regra principal `calcular_mensalidade(ValorFinal)` define a meta.

O Prolog tenta satisfazer essa meta buscando outras regras. Por exemplo, para encontrar o desconto, ele busca `regra_desconto_final(Base, DescontoFinal)`.

Esta, por sua vez, busca `regra_desconto_bruto(Base, Bruto)` e `regra_valor_teto(Base, Teto)`.

O Prolog percorre essa árvore de regras e fatos até unificar (atribuir) um valor a `ValorFinal`.

```prolog
% REGRA 08: Teto Aplicado (Lógica Declarativa)
% "O DescontoFinal É o TetoValor SE..."
regra_desconto_final(Base, TetoValor) :-
    regra_desconto_bruto(Base, DescontoBruto), % 1. Calcule o bruto
    regra_valor_teto(Base, TetoValor),         % 2. Calcule o teto
    DescontoBruto > TetoValor.                 % 3. SE o bruto for maior.
```

O sistema possui 12 regras de negócio que cobrem todos os cenários (multa, teto, descontos individuais, etc.).

---

### 4. Sistema de Explicação (`explain.pl`)

Para atender ao requisito de explicar o "porquê", criamos um sistema de trilha.

Conforme as regras em `rules.pl` são satisfeitas, elas chamam o predicado `adicionar_explicacao/2`, que "afirma" (`assertz`) um fato de explicação (`explicacao_passo(Mensagem)`) em outra parte da memória.

No final, o `main.pl` simplesmente consulta e imprime todos esses fatos, fornecendo uma trilha de auditoria clara das regras que foram acionadas.

---

## 🧾 Exemplo de Entrada e Saída (Teste E2E)

### Cenário de Teste

**Objetivo:** Validar a regra de negócio mais complexa (Teto de Desconto).

**Configurações:** Base R$ 1000, Multa 5%, Teto Desconto 30%.

**Dados do Aluno:** Pagamento sem atraso (n), Bolsa 20%, Família 15%.

---

### Cálculo Manual Esperado:

| Item             | Descrição                               | Valor           |
| ---------------- | --------------------------------------- | --------------- |
| Desconto Bruto   | 20% + 15%                               | 35% (R$ 350)    |
| Teto de Desconto | 30% de R$ 1000                          | R$ 300          |
| Decisão          | Desconto Bruto (R$ 350) > Teto (R$ 300) | ✅ Teto aplicado |
| Multa            | Pagamento em dia                        | R$ 0            |
| Valor Final      | (R$ 1000 + R$ 0) - R$ 300               | **R$ 700,00**   |

---

### Saída no Console

```
====================================================
   Sistema Especialista: Cálculo de Mensalidade Escolar
====================================================
1. Executar cálculo para aluno
2. Sair
----------------------------------------------------
Desenvolvido por: Anderson Nilton de Souza
Desenvolvido por: Gabriel Wellington Renzi
Escolha uma opção: 1

--- Iniciando Novo Cálculo para Aluno ---

--- 1. Configurações da Turma ---
Mensalidade Base (R$): (entre 0 e 999999)
1000
Multa por Atraso (%): (entre 0 e 100)
5
Teto de Desconto (%): (entre 0 e 100)
30

--- 2. Dados do Aluno/Pagamento ---
O pagamento foi/será feito com atraso? (s/n)?
n
Bolsa (%): (entre 0 e 100)
20
Desconto Família (%): (entre 0 e 100)
15

>>> Resultado Final: O valor da mensalidade é R$ 700.00.

--- Trilha de Decisão (Explicação) ---
* REGRA 02 (Base): Valor base definido: R$ 1000.00.
* REGRA 05 (Multa): Pagamento em dia. Multa: R$ 0.00.
* REGRA 11 (Desconto): Bolsa de 20.00% aplicada: R$ 200.00.
* REGRA 12 (Desconto): Desconto Família de 15.00% aplicada: R$ 150.00.
* REGRA 07 (Bruto): Desconto Bruto = R$ 200.00 (Bolsa) + R$ 150.00 (Família) = R$ 350.00.
* REGRA 10 (Teto): Valor máximo de desconto (teto de 30.00%) é R$ 300.00.
* REGRA 08 (Teto): Teto de desconto aplicado. Desconto bruto (R$ 350.00) era maior que o teto (R$ 300.00).
* REGRA 01 (Final): (Base + Multa) - Desconto = (R$ 1000.00 + R$ 0.00) - R$ 300.00
```
