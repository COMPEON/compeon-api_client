workflow "CI" {
  on = "push"
  resolves = ["CI - All"]
}

action "CI - All" {
  uses = "actions/bin/filter@d820d56839906464fb7a57d1b4e1741cf5183efa"
  needs = [
    "CI - Test"
  ]
}

action "CI - Test" {
  uses = "docker://lambci/lambda:build-ruby2.5"
  runs = "bash"
  args = ["-c", "bundle && bundle exec rake test"]
}
