# Design de Software

Proposta de arquitetura de alto nível para uma plataforma estadual de
interoperabilidade em saúde, apoiada por protótipos e simuladores selecionados.
A equipe tem oito integrantes e toma as decisões de projeto em conjunto.

O trabalho, o escopo e as decisões estão em [pratica.md](pratica.md).
As orientações para agentes de desenvolvimento estão em [AGENTS.md](AGENTS.md).

## Contribuindo

Consulte a convenção completa e a configuração local em
[CONTRIBUTING.md](CONTRIBUTING.md).

O merge em `main` é feito por *squash*: o título do PR vira a mensagem do commit.
Por isso, o título de cada PR deve seguir [Conventional Commits](https://www.conventionalcommits.org/pt-br/),
no formato `<tipo>[(escopo)][!]: <descrição>`, com tipo em `build`, `chore`, `ci`, `docs`,
`feat`, `fix`, `perf`, `refactor`, `revert`, `style` ou `test`.
Exemplo: `docs: adiciona diagrama de sequência de autorização de acesso`.

O check `conventional-commits` valida o título automaticamente em cada PR; basta editar o título para o check rodar de novo.
