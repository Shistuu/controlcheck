module GithubChecks
  Outcome = Struct.new(:passed, :details, keyword_init: true)
end
