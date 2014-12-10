# == Schema Information
#
# Table name: repositories
#
#  id         :integer          not null, primary key
#  user       :string(255)      not null
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Repository < ActiveRecord::Base
  has_many :issues
  has_many :commits
  has_many :bounties, through: :issues
  has_many :coders, -> { uniq }, through: :commits
  validates :user, presence: true
  validates :name, presence: true

  require 'rugged'

  def clone
    # get url from github
    repo = $github.repos.get(user: user, repo: name)
    token = Rails.application.secrets.github_token
    url = repo.clone_url.sub 'github.com', "#{token}@github.com"
    `cd #{Rails.root}/repos && git clone #{url}`
  end

  def pull
    `cd #{path} && git pull`
  end

  def register_commits
    r_repo = rugged_repo
    walker = Rugged::Walker.new(r_repo)
    r_repo.branches.each { |b| walker.push b.target_id }
    walker.push(r_repo.last_commit)
    walker.each do |commit|
      Commit.register_rugged self, commit, reward_bounty_points: false
    end
  end

  def fetch_issues
    $github.issues.list(user: user, repo: name, filter: 'all').each do |hash|
      Issue.find_or_create_from_hash hash, self
    end
  end

  require 'rugged'
  def rugged_repo
    Rugged::Repository.new(path)
  end

  private
  def path
    "#{Rails.root}/repos/#{name}"
  end
end
