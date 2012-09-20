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

- View the list of CP Codes (e.g. akamai_api cp_codes) for CCU
- Purge a resource or a list of resources (Urls or CP Codes) via CCU
- See or publish a request via ECCU

## CCU

You can purge a list of urls using the --urls option or a list of cp codes using the --cpcodes option. You need only one of them (you cannot use both).
Additionally you can specify (default values in bold):
- domain: production|staging - This is optional and usually you will not need this option
- action: remove|**invalidate** - Invalidate will mark the resource as expired while Remove will completely remove the resource cache
- emails: [foo@foo.com bar@bar.com] - A list of emails used to send a notification after the purge has been completed

## ECCU

You can see the requests published on ECCU using *akamai_api eccu_requests*
For each request you will see all its details (code, status, etc.) except the file content.
To view the file content add the --verbose (-v) option.

You can also restrict the listing to the last request using the --last (-l) option.

# As a Library

Remember to init the AkamaiApi gem with your login credentials. You can set your credentials with the following statement:

```ruby
    AkamaiApi.config.merge! :auth => ['user', 'pass']
```

- CpCode: model representing a CP Code. Use the ::all method to retrieve the list of available CpCode.
- Ccu   : CCU interface. Use the ::purge method to purge a list of resources.
- EccuRequest: model representing an ECCU request.

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
    ccu.invalidate_url urls          # => wrapper to call .purge :invalidate, :arl
    ccu.invalidate :arl, urls        # => wrapper to call .purge :invalidate

    ccu.remove_cp_codes cp_codes # => wrapper to call .purge :remove, :cpcode
    ccu.remove_url urls          # => wrapper to call .purge :remove, :arl
    ccu.remove :arl              # => wrapper to call .purge :remove
```

## EccuRequest

An EccuRequest is an object representing an ECCU Request. To see all the published requests use the ::all method.
To retrieve only the last request, you can use the ::last method.
The following code should be self explaining about both class methods and instance methods:

```ruby
    all_requests_ids = EccuRequest.all_ids                     # => Returns all available requests ids
    first_request    = EccuRequest.find all_requests_ids.first # => Return the EccuRequest model with the specified code

    all_requests = EccuRequest.all  # => Returns all available requests
    last_request = EccuRequest.last # => Return the last available request

    last_request.update_notes! 'My new note' # => Invoke the ECCU service to change the notes field
    last_request.update_email! 'foo@foo.com' # => Invoke the ECCU service to change the email to be notified on status change
    last_request.destroy                     # => Invoke the ECCU service to delete the request
```

# Specs

Before running the specs create a file auth.rb in ./spec with the following

```ruby
    # Fill the following with your akamai login before running your spec
    AkamaiApi.config.merge!({
      :auth => ['user', 'pass']
    })
```
