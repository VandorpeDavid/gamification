# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Fetch organisation repositories
repos = $github.repos.list :all, org: Rails.application.config.organisation

repos.select {|r| RepoFilters.track? r}.each do |hash|
  repo = Repository.find_or_create_by name: hash['name'] do |r|
    r.github_url = hash['html_url']
    r.clone_url = hash['clone_url']
    r.clone
  end
  repo.pull
  repo.register_commits
  repo.fetch_issues
end
