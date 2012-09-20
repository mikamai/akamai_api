# AkamaiApi

# Using the CLI

After gem installation you will have a CLI utility to execute operations on Akamai. Each method requires authentication.
You can provide auth info using one of the following methods:

- Passing --username (-u) and --password (-p) arguments at each invocation
- Creating a config file in your HOME directory named .akamai_api.yml with the following format:

```yaml
    auth:
      - user
      - pass
```

Use *akamai_api help* to view the help of the CLI.
Using the CLI you can:

- View the list of CP Codes (e.g. akamai cp_codes)
- Purge a resource or a list of resources (Urls or CP Codes)

## Purge

You can purge a list of urls using the --urls option or a list of cp codes using the --cpcodes option. You need only one of them (you cannot use both).
Additionally you can specify (default values in bold):
- domain: production|staging - This is optional and usually you will not need this option
- action: remove|**invalidate** - Invalidate will mark the resource as expired while Remove will completely remove the resource cache
- emails: [foo@foo.com bar@bar.com] - A list of emails used to send a notification after the purge has been completed

# As a Library

Remember to init the AkamaiApi gem with your login credentials. You can set your credentials with the following statement:

```ruby
    AkamaiApi.config.merge! :auth => ['user', 'pass']
```

- CpCode: use the ::all method to retrieve the list of available CpCode.
- Ccu: use the ::purge method to purge a list of resources.

## Ccu

### ::purge

```ruby
    def purge action, type, items, args = {}
      ...
    end
```

- action: symbol or string. It should be *remove* or *invalidate*. See the CLI documentation for more details
- type: symbol or string. It should be *arl* or *cpcode*. Use arl to purge a list of urls, and cpcodes to purge a list of cp codes
- items: the list of the resources to clean
- args: additional options (email, domain)

e.g.

```ruby
    AkamaiApi::Ccu.purge :remove, :arl, ['http://www.foo.com/a.txt'], :email => ['foo@foo.com']
```

### Helpers

```ruby
    ccu = AkamaiApi::Ccu

    ccu.invalidate_cp_codes cp_codes # => wrapper to call .purge :invalidate, :cpcode
    ccu.invalidate_url urls # => wrapper to call .purge :invalidate, :arl
    ccu.invalidate :arl, urls # => wrapper to call .purge :invalidate

    ccu.remove_cp_codes cp_codes # => wrapper to call .purge :remove, :cpcode
    ccu.remove_url urls # => wrapper to call .purge :remove, :arl
    ccu.remove :arl # => wrapper to call .purge :remove
```

# Specs

Before running the specs create a file auth.rb in ./spec with the following

```ruby
    # Fill the following with your akamai login before running your spec
    AkamaiApi.config.merge!({
      :auth => ['user', 'pass']
    })
```
