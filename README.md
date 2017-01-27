# rack-access-capture

English | [日本語](README.ja.md)

To capture the request and response in the rack middleware, you can be output to any destination

Has the following features:

* It does not automatically run the capture of the request and response
* Very customizable
    * middleware has the defult output destination, but can be set independently of the output destination.
    * You can customize the content you want to capture.

## Table of Contents ##

---

* [Usage](#usage)
* [Output format](#output-format)
* [Configuration](#configuration)
* [Customize](#customize)
* [Contributing](#contributing)
* [License](#license)

## Usage ##

---

Immediately after installation , you do not automatically have not able to run the capture.  
Including the setting to the top of the rack middlewares, it will work .

### Installation ###

install it via rubygems:

```ruby
gem install rack-access-capture
```

or put it in your Gemfile:

```ruby
# Gemfile

gem 'rack-access-capture'
```

Then insert ``Rack::Access::Capture::Manager`` and the setting of middlware on the head of rack middlewares.

#### In the case of Rails ####

Additional settings by source code:

```ruby
config.middleware.use Rack::Access::Capture::Manager do |config|
  config.collector = { adapter: :fluentd, config: { host: 'localhost', port: 24224, tag: 'mytag', exclude_user_agents: ["exclude_user_agent_1", "exclude_user_agent_2"] } }
  config.watcher = { adapter: 'MyWatcher' }
  config.filter = { params: ['params1', 'params2'] }
end
```

or Additional settings by YAML:

```ruby
config.middleware.use Rack::Access::Capture::Manager, YAML.load_file("#{Rails.root}/config/rack.yml")
```

```yaml
collector:
  adapter: fluentd
  config:
    host: localhost
    port: 24224
    tag: my_tag
    exclude_user_agents:
      - "exclude_user_agent_1"
      - "exclude_user_agent_2"
watcher:
  adapter: MyWatcher
filter:
  params:
    - password
    - email
    - name
    - body
```

## Output format ##

Default output format:

```
{"status":200,"path":"/","method":"GET","params":"{}","device":"pc","os":"Mac OSX","browser":"Chrome","browser_ver":"50.0.2661.102","user_agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36","remote_ip":"::1","time":1466588840,"accessed_at":1466588840,"app_exec_time":3.8547658920288086}
```

* ``status``: Response Status Code
* ``path``: Request Path
* ``method``: Request Method
* ``params``: Request Parameter
* ``device``: Originating device(via User Agent)
* ``os``: Operating systems(via User Agent)
* ``browser``: Browser name(via User Agent)
* ``browser_ver``: Browser version(via User Agent)
* ``user_agent``: User Agent
* ``remote_ip``: Originating IP address
* ``time``: Capture execution time
* ``accessed_at``: Access time
* ``app_exec_time``: The rack application execution time in seconds. milli seconds are written after the decimal point.

## Configuration ##

Currently the options you can change are as follows:

### output settings ###

Set of output destination to the ``collector``.

* adapter: This specifies the implementation class of the output destination.(default: ``console``)
    * The captured content is output to standard output.(Set the ``console``.)
    * The captured content is output to fluentd.(Set the ``fluentd``.)
    * Implementation class name of the customized output destination.
* config: Specifies the adapter settings.
    * ``console``: No settings.
    * ``fluentd``: Set the setting value of [fluent-logger-ruby](https://github.com/fluent/fluent-logger-ruby).

#### **console** configuration ####

``format``: If you specify a ``ltsv`` output in LTSV format. If you specify a ``json`` output in Json format. The default is ``json`` output.

Use LTSV format.

```yaml
collector:
  adapter: console
  config:
    format: ltsv
```

### capture settings ###

Set of customized capture function to the ``watcher``.

* adapter: This specifies the implementation class name.(The default is undefined.)

### filter settings ###

Set of a mask of request parameters to the ``watcher``.  
The default is to the following two.

* password
* authenticity_token

## Customize ##

the output destination and the capture you can change are as follows:

### output destination ###

By specifying the name of the class of its own adapter implementation to the collector,  
you will be able to use in the implementation of their own output destination.

```ruby
require 'rack-access-capture'

class YourCustomizedCollectorAdapter < Rack::Access::Capture::Collector::AbstractAdapter

  def initialize(*options)
    @config = options["adapter_config"]
  end

  def collect?(env)
    env["REQUEST_METHOD"] != "GET"
  end

  def collect(log)
    puts log
  end
end

```

### capture function ###

By specifying the name of the class of its own adapter implementation to the watcher,  
you will be able to use in the implementation of their own capture function.

```ruby
require 'rack-access-capture'

module Rack
  class YourCustomizedWatcher < Rack::Access::Capture::Watcher::BaseAdapter

    def request_capture(env)
      { forwardedfor: env['HTTP_X_FORWARDED_FOR'] }
    end

    def response_capture(env, http_status_code, header)
      { rails_action: env[:rails_action] }
    end
  end
end
```

### YAML ###

If you want to use your own settings, lists the file as follows:

```yaml
collector:
  adapter: YourCustomizedCollectorAdapter
  config:
    adapter_config: custom_collector_config
watcher:
  adapter: YourCustomizedWatcher
filter:
  params:
    - password
    - email
    - name
    - body
```

## Contributing ##

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License ##

See [LICENSE.txt](LICENSE.txt) for details.
