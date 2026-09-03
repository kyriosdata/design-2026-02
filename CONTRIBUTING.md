# Como contribuir

Este repositório adota a especificação
[Conventional Commits 1.0.0](https://www.conventionalcommits.org/pt-br/v1.0.0/)
para **todas** as mensagens de commit e para o **título de cada pull request**.

## Formato

```
<tipo>[(escopo opcional)][!]: <descrição>

[corpo opcional]

[rodapés opcionais]
```

- **tipo** — obrigatório, minúsculo, um dos listados abaixo.
- **escopo** — opcional, entre parênteses, indica a área afetada
  (ex.: `pratica`, `ci`, `readme`).
- **`!`** — opcional, antes dos dois-pontos, sinaliza quebra de
  compatibilidade.
- **descrição** — obrigatória, após `: ` (dois-pontos e um espaço), no
  imperativo, sem ponto final. O cabeçalho inteiro deve ter no máximo 72
  caracteres.
- **corpo** — opcional, separado da descrição por **uma linha em branco**.
- **rodapés** — opcionais, no formato `Token: valor` (ex.: `Refs: #12`). A
  quebra de compatibilidade usa `BREAKING CHANGE: <descrição>`, sempre em
  maiúsculas.

### Tipos aceitos

| Tipo | Quando usar |
|------|-------------|
| `feat` | acrescenta funcionalidade |
| `fix` | corrige defeito |
| `docs` | altera apenas documentação |
| `test` | acrescenta ou ajusta testes |
| `refactor` | altera o código sem mudar comportamento observável |
| `perf` | melhora desempenho |
| `style` | formatação, sem efeito sobre o comportamento |
| `build` | sistema de construção ou dependências |
| `ci` | configuração de integração contínua |
| `chore` | tarefas de manutenção sem efeito sobre o produto |
| `revert` | reverte um commit anterior |

### Exemplos

```
docs: acrescenta roteiro da prática 3
feat(entrega): valida o formato do arquivo submetido
fix(ci)!: exige Java 21 no workflow de testes
```

```
refactor(pratica): extrai o exemplo de acoplamento para arquivo próprio

O exemplo ocupava metade do roteiro e dificultava a leitura do enunciado.

Refs: #12
```

## Configuração local (uma vez por clone)

```bash
git config core.hooksPath .githooks     # valida a mensagem antes de criar o commit
git config commit.template .gitmessage  # abre o editor com o formato preenchido
```

O hook [`.githooks/commit-msg`](.githooks/commit-msg) rejeita mensagens fora da
convenção e explica o motivo. Ele apenas antecipa o resultado: a verificação
autoritativa é a da integração contínua.

Se um commit já criado estiver fora do padrão, corrija antes de abrir o pull
request:

```bash
git commit --amend        # último commit
git rebase -i origin/main # commits anteriores (use "reword")
```

## Verificação automática

O workflow
[`conventional-commits`](.github/workflows/conventional-commits.yml) roda em todo
pull request para `main` e reprova quando:

- o **título do pull request** está fora da convenção; ou
- **algum commit** do pull request está fora da convenção.

Hook e workflow compartilham a mesma implementação,
[`.github/scripts/valida-mensagem-commit.sh`](.github/scripts/valida-mensagem-commit.sh),
de modo que o resultado local e o da integração contínua coincidem.

## Fluxo de trabalho

`main` é protegida: não aceita push direto e exige pull request com a
verificação acima aprovada. O merge é sempre por **squash**, e o título do pull
request se torna a mensagem do commit registrado em `main` — por isso ele
também é validado.

1. crie um branch a partir de `main`;
2. faça commits seguindo a convenção;
3. abra o pull request com título no mesmo formato;
4. aguarde a verificação e faça o merge por squash.
