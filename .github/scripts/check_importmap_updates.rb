require "open3"

output, errors, status = Open3.capture3("bin/importmap", "outdated")
print output
warn errors unless errors.empty?

exit if status.success? && output.lines.any? { |line| line.strip == "No outdated packages found" }
abort "Importmap update check failed" unless status.exitstatus == 1

# Importmap returns 1 for both updates and registry errors. Only report version rows.
updates = output.lines.grep(/\A\| /).map { |line| line.split("|")[1..3].map(&:strip) }
abort "Importmap did not report updates" unless updates.shift == %w[Package Current Latest] && updates.any?

version = /\A\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.+-]+)?\z/
unless updates.all? { |name, current, latest| name && !name.empty? && version.match?(current) && version.match?(latest) }
  abort "Importmap encountered a registry error or returned an unexpected version"
end

repository = ENV.fetch("GITHUB_REPOSITORY")
issues, result = Open3.capture2(
  "gh", "api", "--paginate", "repos/#{repository}/issues?state=all&per_page=100",
  "--jq", '.[] | select(has("pull_request") | not) | .title'
)
abort "Could not check for existing Importmap issues" unless result.success?
existing_titles = issues.lines(chomp: true).to_set

updates.each do |name, current, latest|
  title = "Update Importmap package #{name} to #{latest}"
  next if existing_titles.include?(title)

  body = <<~MARKDOWN
    `bin/importmap outdated` found an update for `#{name}` from `#{current}` to `#{latest}`.

    Review the package changes before updating `config/importmap.rb` and `vendor/javascript`.
  MARKDOWN
  system("gh", "issue", "create", "--repo", repository, "--title", title, "--body", body, exception: true)
  existing_titles.add(title)
end
