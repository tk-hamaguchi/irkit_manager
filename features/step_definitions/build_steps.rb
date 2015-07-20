When(/^`(.+)`を実行する$/) do |cmd|
  @last_command = cmd
  if @longtime
    run_simple cmd, false, 300
  else
    run_simple cmd
  end
end


Then(/^標準出力に下記の文字列が含まれている:$/) do |result|
  expect(stdout_from(@last_command)).to include result
end

Then(/^標準出力に出力された内容が\/(.+)\/にマッチする$/) do |regex|
  expect(stdout_from(@last_command)).to match(/#{regex}/)
end

Then(/^ビルドされたGemファイルが"([^"]*)"配下に存在している$/) do |dir|
  expect(File.exist?(File.join(dir, "irkit_manager-#{IrkitManager::VERSION}.gem"))).to be_truthy
end

