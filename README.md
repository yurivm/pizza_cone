# Pizza cone
_almost as awesome_

![cono-pizza](https://cloud.githubusercontent.com/assets/529840/12293008/fa843942-b9f0-11e5-95f6-3a4ea4ba79f7.png)

## What's this?

Create and maintain Host records for your [AWS OpsWorks](https://aws.amazon.com/opsworks/) instances in your ssh configuration file,
so you can comfortably do:

```
ssh mycoolinstance
```
and stop clicking around in the UI trying to find that instance IP again..and again an hour later.

## Installation

* clone this repo to a folder on your machine
* (_optionally_) put your favourite Ruby version into the *.ruby_version* file. I used 2.2.1 but 2.0 and above will work.
* install bundler and gems with:
```
gem install bundler
bundle install
```

## Configuration

### AWS CLI access: The easy way

Set up the [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html). Pizza cone will pick up your settings.

If you're getting *Aws::IAM::Errors::AccessDenied* from pizza cone, that means you don't have rights to run IAM requests. In that case, either obtain those rights or add your Opsworks SSH Username to the .env file:

```
AWS_SSH_USERNAME="yourawssshusername"
```

### AWS CLI access: The hard way

If the easy way didn't work, here is the detailed setup:

Copy .env.sample to .env and edit it:

```
AWS_ACCESS_KEY_ID = YOUR_AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY = YOUR_AWS_SECRET_ACCESS_KEY
AWS_SSH_USERNAME="yourawssshusername"
```

Note: if you have AWS CLI set, your credentials are probably in ~/.aws/credentials. If not, check [the Amazon CLI setup guide](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html)

If you haven't used the AWS CLI before, you can retrieve your credentials from https://console.aws.amazon.com/iam/home?region=eu-central-1#users

### Adding brokers

It's possible to configure pizzacone to supply the ProxyCommand for hosts that only allow access from a host inside the network, e.g. when they are in the VPC.

Consider the following setup:
- the broker host to access testing stacks is called mybroker-testing.example.com
- the broker host to access production stacks is called mybroker-production.example.com
- the VPC stacks are called mars-production, jupiter-production and venus-testing

Things you need to do:
- Add a Host section to your ~/.ssh/config for the broker host:
```
Host mybroker-testing.example.com
  HostName 1.2.3.4
  User myuser
  ForwardAgent yes

Host mybroker-production.example.com
  HostName 2.3.4.5
  User myuser
  ForwardAgent yes
```
Note that ForwardAgent is usually necessary.

- Configure pizza cone to be able to tell which broker host is used for which stack name (regexp matching is used):
```
  config.proxy_map = {
    /.*?-production\z/ => "mybroker-testing.example.com",  # stacks ending with -production
    /.*?-testing\z/ => "mybroker-production.example.com"  # stacks ending with -testing
  }
```

If an instance's stack name matches a regexp, pizzacone will generate a ProxyCommand for that instance to go through the matching broker host.

## Run
```
cd /path/to/pizza_cone
bundle exec ruby bin/update.rb
```

If successful, your ~/.ssh/config file will be updated with Host sections like:

```
Host instance_name instance_name-stack_name
Hostname 1.2.3.4
User your_aws_ssh_user
```

By default Each OpsWorks instance gets two patterns:
- its own host name (e.g. wildcat )
- stackname-instancename (e.g. wildcat-production). Yes I am looking at you, generic app1 names across different stacks.

If that you use [ohmyzsh](https://github.com/robbyrussell/oh-my-zsh), you will get ssh host autocompletion for free!

### Crontab

A [whenever](https://github.com/javan/whenever) config is supplied under config/schedule.rb .Update it and generate your own crontab if you need to.
