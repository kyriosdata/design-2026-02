#!/usr/bin/env sh
#
# Valida uma mensagem de commit conforme a especificacao Conventional Commits 1.0.0
# (https://www.conventionalcommits.org/pt-br/v1.0.0/).
#
# Uso:
#   valida-mensagem-commit.sh <arquivo>              le a mensagem do arquivo
#   printf '%s' "..." | valida-mensagem-commit.sh -  le a mensagem da entrada padrao
#
# Encerra com 0 quando a mensagem e valida e com 1 quando nao e, descrevendo em
# stderr cada regra violada. Este script e a unica fonte da verdade da convencao:
# o hook local (.githooks/commit-msg) e o workflow de integracao continua
# (.github/workflows/conventional-commits.yml) apenas o invocam.

set -u

TIPOS_PERMITIDOS='build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test'
LIMITE_CABECALHO=72

origem="${1:-}"
if [ -z "${origem}" ]; then
  printf 'uso: %s <arquivo|->\n' "$0" >&2
  exit 2
fi

if [ "${origem}" = '-' ]; then
  bruta=$(cat)
elif [ -r "${origem}" ]; then
  bruta=$(cat "${origem}")
else
  printf 'erro: nao foi possivel ler a mensagem em "%s".\n' "${origem}" >&2
  exit 2
fi

# Descarta comentarios e a regiao de diff acrescentada por "git commit --verbose".
mensagem=$(printf '%s\n' "${bruta}" | sed -e '/^#.*>8/,$d' -e '/^#/d')
cabecalho=$(printf '%s\n' "${mensagem}" | sed -n '1p')

# Mensagens geradas pelo proprio git tem formato imposto pela ferramenta, e nao
# pelo autor: sao aceitas como estao.
case "${cabecalho}" in
  'Merge '*|'Revert "'*|'fixup!'*|'squash!'*|'amend!'*) exit 0 ;;
esac

erros=0
reprova() {
  erros=$((erros + 1))
  printf '  - %s\n' "$1" >&2
}

if [ -z "${cabecalho}" ]; then
  reprova 'a mensagem esta vazia.'
else
  if ! printf '%s\n' "${cabecalho}" |
    grep -Eq "^(${TIPOS_PERMITIDOS})(\([a-z0-9][a-z0-9._/-]*\))?!?: .+$"; then
    reprova "o cabecalho deve ser \"<tipo>[(escopo)][!]: <descricao>\", com tipo entre ${TIPOS_PERMITIDOS} e um espaco apos os dois-pontos."
  fi

  tamanho=$(printf '%s' "${cabecalho}" | wc -m | tr -d '[:space:]')
  if [ "${tamanho}" -gt "${LIMITE_CABECALHO}" ]; then
    reprova "o cabecalho tem ${tamanho} caracteres e o limite e ${LIMITE_CABECALHO}."
  fi

  case "${cabecalho}" in
    *.) reprova 'a descricao nao deve terminar em ponto.' ;;
  esac
fi

# A especificacao exige uma linha em branco entre a descricao e o corpo.
if [ -n "$(printf '%s\n' "${mensagem}" | sed -n '2p')" ]; then
  reprova 'o corpo deve ser separado da descricao por uma linha em branco.'
fi

# "BREAKING CHANGE" e o unico token que a especificacao exige em maiusculas.
if printf '%s\n' "${mensagem}" | grep -Eqi '^breaking[ -]change' &&
  ! printf '%s\n' "${mensagem}" | grep -Eq '^BREAKING(-| )CHANGE: .+'; then
  reprova 'o rodape de quebra de compatibilidade deve ser "BREAKING CHANGE: <descricao>".'
fi

if [ "${erros}" -gt 0 ]; then
  printf '\nMensagem rejeitada (Conventional Commits 1.0.0):\n\n  %s\n\n' "${cabecalho}" >&2
  printf 'Exemplos validos:\n' >&2
  printf '  docs: acrescenta roteiro da pratica 3\n' >&2
  printf '  feat(entrega): valida o formato do arquivo submetido\n' >&2
  printf '  fix(ci)!: exige Java 21 no workflow de testes\n\n' >&2
  printf 'Convencao completa em CONTRIBUTING.md.\n' >&2
  exit 1
fi

exit 0
