# Design de Software

## Contribuindo

O merge em `main` é feito por *squash*: o título do PR vira a mensagem do commit.
Por isso, o título de cada PR deve seguir [Conventional Commits](https://www.conventionalcommits.org/pt-br/),
no formato `<tipo>[(escopo)][!]: <descrição>`, com tipo em `build`, `chore`, `ci`, `docs`,
`feat`, `fix`, `perf`, `refactor`, `revert`, `style` ou `test`.
Exemplo: `docs: adiciona diagrama de sequência de autorização de acesso`.

O check `conventional-commits` valida o título automaticamente em cada PR; basta editar o título para o check rodar de novo.
