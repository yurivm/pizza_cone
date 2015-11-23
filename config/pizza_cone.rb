# use files from fixtures for tests
PizzaCone.configure do |config|
  config.set_instance_hostname_block do |instance|
    "#{instance.hostname} #{stack.name}-#{instance.hostname}"
  end
end
