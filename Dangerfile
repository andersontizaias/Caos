# frozen_string_literal: true

# ── Conventional Commits ──────────────────────────────────────────────────────

CONVENTIONAL_PATTERN = /\A(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?!?: .+/i

unless github.pr_title.match?(CONVENTIONAL_PATTERN)
  fail "O título da PR deve seguir o padrão Conventional Commits.\n" \
       "**Formato:** `<tipo>(<escopo opcional>): <descrição>`\n" \
       "**Tipos válidos:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`, `revert`\n\n" \
       "**Exemplos:**\n" \
       "  - `feat: adiciona suporte a grid horizontal`\n" \
       "  - `fix(parser): corrige falha com YAML inválido`\n" \
       "  - `chore: atualiza XcodeGen para 2.43.0`"
end

if github.pr_title.include?("!:") || github.pr_body.to_s.include?("BREAKING CHANGE")
  warn "Esta PR contém uma **breaking change**. A versão major será incrementada no próximo release."
end

# ── PR Hygiene ────────────────────────────────────────────────────────────────

warn "Adicione uma descrição à PR para facilitar a revisão." if github.pr_body.to_s.length < 10

if git.lines_of_code > 500
  warn "Esta PR tem **#{git.lines_of_code} linhas** modificadas. " \
       "Considere dividir em PRs menores para facilitar a revisão."
end

# ── Tests ─────────────────────────────────────────────────────────────────────

has_source_changes = !git.modified_files.grep(%r{Sources/}).empty?
has_test_changes   = !git.modified_files.grep(%r{Tests/}).empty?

if has_source_changes && !has_test_changes
  warn "Código de produção foi modificado sem testes correspondentes. " \
       "Considere adicionar ou atualizar testes."
end

# ── Coverage ──────────────────────────────────────────────────────────────────

require "json"

coverage_file = "coverage.json"
if File.exist?(coverage_file)
  data       = JSON.parse(File.read(coverage_file))
  percentage = ((data["lineCoverage"] || 0) * 100).round(1)
  icon       = percentage >= 90 ? "✅" : "⚠️"
  message "#{icon} Cobertura de testes: **#{percentage}%** (threshold: 90%)"
  warn "Cobertura abaixo de 90% (#{percentage}%). Adicione testes para aumentar a cobertura." if percentage < 90
else
  warn "Relatório de cobertura não encontrado. Verifique se o job `coverage` rodou corretamente."
end

# ── TODOs adicionados ─────────────────────────────────────────────────────────

swift_files = (git.modified_files + git.added_files).select { |file| file.end_with?(".swift") }
added_todos = swift_files.sum(0) do |file|
  diff = git.diff_for_file(file)
  next 0 unless diff

  diff.patch.lines.count { |line| line.start_with?("+") && line.match?(/\bTODO\b|\bFIXME\b|\bHACK\b/) }
end

warn "#{added_todos} TODO/FIXME/HACK adicionado(s). Abra issues para rastrear o trabalho pendente." if added_todos.positive?

# ── SwiftLint (comentários inline nos arquivos modificados) ───────────────────

swiftlint.lint_files inline_mode: true
