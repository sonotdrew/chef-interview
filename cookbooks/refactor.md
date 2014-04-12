#So, let's talk about refactoring.

There are two ways that we can go about this. We can keep rolling with the chef-solo style of chefing, which I think is great for one-off apps or local dev setups. With a chef-server, you keep all your node data stored in a central location; persistent attributes and searching of that data are very nice to have when building out a complex infrastructure. I'll talk about both ways you could refactor/expand this repo.

##Chef-solo

In both the app_alpha and app_beta cookbooks, we're doing the same thing in each cookbook twice. I would first abstract all the `packages` (redis, mongo, node, ruby, etc) to their own cookbooks. We can then `include_recipe` in each of the alpha and beta cookbooks, so that Chef will know to only run these cookbooks once during compile time, cutting down chef-run time. This also allows for greater tuning of each of these services, IE - change the port redis runs on.

Right now, you have the `user` resource creating the liftopian user, defined in each of the apps' cookbooks after the deploy, which is kinda silly because Chef runs in the order of cookbooks defined in the run_list, and reads each cookbook from top to bottom. The ordering of cookbooks and recipes plays a big part in how Chef works. I would create a `users` cookbook to set up any system users that are needed and place that cookbook above the apps' cookbooks in the run_list. Lastly, I would add a `user liftopian` to the deploy resource to set that user as the owner 'cause I'm sure we didn't want the root user running our app.

If you run chef in daemon mode, I would recommend changing the deploy resource to use the `deploy_revision` provider. This will check the SHA of the latest release and not re-deploy unless that SHA has changed, preventing unnecessary deploys and restarts. If you run Chef only when needed, the deploy resource is fine the way it is.


##Chef-server

I would still separate each of the packages (redis, mongo, etc) to their own cookbooks. I'd also do the same for a users cookbook for the liftopian user.

I like using roles to help define what a machine should do. Roles allow you to define run_list and define attribute overrides. Attribute overrides allow you to create generic cookbooks and have the overrides be the "knobs and levers" that help tune/define how you want that service to behave.

When it comes to the app cookbooks, I would rewrite the deploy cookbook to be a general use cookbook for deploying any application whose attributes you pass though a role.

For example we could create a role app_alpha_and_beta:

```ruby
name "app_alpha_and_beta"
description "builds and deploys the alpha and beta app"
run_list [
	"recipe[ruby1.9.3]",
	"recipe[nodejs]",
	"recipe[mongodb]",
	"recipe[redis-server]",
	"recipe[deploy]"
]

default_attributes(
	"deploy" => {
		"service" => [
			"alpha" => {
				"repo" => "https://github.com/liftopia/myInterview.git",
				"migration_command" => "bundle exec rake db:migrate",
				"restart_command" => "bundle exec rackup -D"
			},
			"beta" => {
				"repo" => "https://github.com/liftopia/myInterview.git",
				"migration_command" => "bundle exec rake db:migrate",
				"restart_command" => "bundle exec rackup -p 9293 -D"
			}
		]
	}
)
```

This way, we can use the role to define how we want everything to be set up and, if we need to change anything, we're changing a role and not a cookbook that could affect other nodes using the same cookbook.

Another thing I would do is store the data from database.yml into an encrypted data bag, as there are passwords stored in there and we don't want those checked in to a public repo.

On the topic of data_bags, attributes, variables, and where the hell to store data in chef: I believe that sane default attributes should be used in cookbooks. Any changes to those attributes should come from a role override. If you need application or clustered service data (list of zookeeper nodes, mongo replica servers, etc), I think those are best used in databags because they're easily searchable.

Other features that are not part of this refactor you would want to have would be process monitoring (monit, superviser, bluepill, god) and server monitoring cause it's not in production if it's not monitored!
