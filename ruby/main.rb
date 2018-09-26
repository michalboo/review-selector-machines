require "oj"
require "httparty"
require "time"

def load_reviewers
 return Oj.load(File.read(@reviewer_path))
end

def dump_reviewers
  File.open(@reviewer_path, 'w') { |file| file.write(Oj.dump(@reviewers, indent: 2))}
end

def reset_list
  @reviewers.each { |reviewer| reviewer["reviewing"] = true }
  return @reviewers
end

def select_reviewer
  @available_reviewers = @reviewers.select { |reviewer| reviewer["reviewing"] == true }
  if @available_reviewers.empty?
    @available_reviewers = reset_list
  end
  selection = @available_reviewers.sample
  selection["reviewing"] = false
  selection["last_selection"] = Time.now.utc.iso8601
  return selection
end

def notify_slack(webhook_url, name)
  result = HTTParty.post(webhook_url,
    body: Oj.dump({
      "text" => "Ruby says: #{name}",
      "channel" => "#echo-chamber"
    }),
    headers: { "Content-Type" => "application/json" }
  )
end

@reviewer_path = "../reviewers.json"
@config = Oj.load(File.read("../config.json"))

@reviewers = load_reviewers
selected = select_reviewer

notify_slack(@config["SLACK_WEBHOOK_URL"], selected["name"])
dump_reviewers
