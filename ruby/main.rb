require "oj"
require "pry"
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

@reviewer_path = "../reviewers.json"
@reviewers = load_reviewers
selected = select_reviewer

puts selected["name"]
dump_reviewers
