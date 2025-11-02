# Sistema Especialista em Prolog: Cálculo de Mensalidade Escolar

Este projeto é um sistema especialista desenvolvido em **SWI-Prolog**, como parte dos requisitos da disciplina de Linguagens de Programação e Paradigmas. O objetivo principal é demonstrar a aplicação de conceitos de **Programação Lógica** (fatos, regras e motor de inferência) para resolver um problema de negócio. O sistema replica a lógica de um formulário de cálculo de mensalidade, coletando dados do usuário via console e inferindo o valor final com base em um conjunto de regras de negócio (multa, descontos, teto).

**Desenvolvido por:**
* Anderson Nilton de Souza [@andersonniltondesouza-unidavi](https://github.com/andersonniltondesouza-unidavi)
* Gabriel Wellington Renzi [@GabrielRenzi](https://github.com/GabrielRenzi)

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

   ```
   git clone [https://github.com/andersonniltondesouza-unidavi/mensalidade_escolar_prolog]
   ```

3. **Acesse o diretório `src`:**

   ```
   cd [DIRETÓRIO ONDE FOI BAIXADO O PROJETO]/src
   ```

4. **Execute o sistema:**

   * Inicie o programa diretamente pelo terminal. O comando `-s main.pl` carrega o arquivo principal e `-g iniciar` define o predicado (meta) que deve ser executado na inicialização (o nosso menu).

   ```
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

```
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

