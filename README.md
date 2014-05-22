# AkamaiApi
[![Gem Version](https://badge.fury.io/rb/akamai_api.svg)](http://badge.fury.io/rb/akamai_api) [![Build Status](https://travis-ci.org/mikamai/akamai_api.svg?branch=master)](https://travis-ci.org/mikamai/akamai_api)

__Now with CCU REST support!__

AkamaiApi is a ruby library and command line utility to interact with Akamai CCU (Content Control Utility) and ECCU (Enhanced Content Control Utility) services.

# Using the CLI

After gem installation you will have a CLI utility to execute operations on Akamai. Each method requires authentication. You can provide auth info using one of the following methods:

- Passing --username (-u) and --password (-p) arguments at each invocation
- Set ENV variables: `AKAMAI_USERNAME` and `AKAMAI_PASSWORD`
- Creating a config file in your HOME directory named `.akamai_api.yml` with the following format:

```yaml
    auth:
      - user
      - pass
    log: true # optional for enabling logging in ECCU requests. false by default
```

## Tasks

When using the CLI you can work with both CCU and ECCU.

```
    akamai_api ccu          # CCU Interface
    akamai_api eccu         # ECCU Interface
    akamai_api help [TASK]  # Describe available tasks or one specific task
```
Use *akamai_api help* to view the help of the CLI.

## CCU

In the CCU interface you can work with CP Codes and ARLs.

```
    akamai_api ccu cpcode                 # CP Code CCU actions
    akamai_api ccu help [COMMAND]         # Describe subcommands or one specific subcommand
    akamai_api ccu arl                    # ARL CCU actions
    akamai_api ccu status [progress_uri]  # Show the CCU queue status if no progress_uri is given, or show a CCU Purge request status if a progress uri is given
```

### CP Code

```
    akamai_api ccu cpcode help [COMMAND]                  # Describe subcommands or one specific subcommand
    akamai_api ccu cpcode invalidate CPCODE1 CPCODE2 ...  # Purge CP Code(s) marking their cache as expired
    akamai_api ccu cpcode remove CPCODE1 CPCODE2 ...      # Purge CP Code(s) removing them from the cache
```

When removing or invalidating a CP Code you can provide the following optional arguments:

- *--domain*, *-d*: Specify if you want to work with *production* or *staging*. This is a completely optional argument and usually you don't need to set it.

### ARL

```
  akamai_api ccu arl help [COMMAND]                                                   # Describe subcommands or one specific subcommand
  akamai_api ccu arl invalidate http://john.com/a.txt http://www.smith.com/b.txt ...  # Purge ARL(s) marking their cache as expired
  akamai_api ccu arl remove http://john.com/a.txt http://www.smith.com/b.txt ...      # Purge ARL(s) removing them from the cache
```

When removing or invalidating an ARL you can provide the following optional arguments:

- *--domain*, *-d*: Specify if you want to work with *production* or *staging*. This is a completely optional argument and usually you don't need to set it.

### Status

If you don't provide a `progress_uri` this command will print the CCU queue status. E.g.

```bash
$ akamai_api ccu status
------------
Status has been successfully received:
	* Result: 200 - The queue may take a minute to reflect new or removed requests.
	* Support ID: 12345678901234567890-123456789
	* Queue Length: 0
------------
```

When you provide a `progress_uri` or a `purge_id` this command will print the CCU request status. E.g.

```bash
$ akamai_api ccu status 12345678-1234-5678-1234-123456789012 # or you can pass /ccu/v2/purges/12345678-1234-5678-1234-123456789012
------------
Status has been successfully received:
	* Result: 200 - Done
	* Purge ID: 12345678-1234-5678-1234-123456789012 | Support ID: 12345678901234567890-123456789
	* Submitted by 'gawaine' on 2014-05-20 08:19:21 UTC
	* Completed on: 2014-05-20 08:22:20 UTC
------------
```

## ECCU

In the ECCU interface you can see the requestes already published and publish your own requests.

```
    akamai_api eccu help [COMMAND]                            # Describe subcommands or one specific subcommand
    akamai_api eccu last_request                              # Print the last request made to ECCU
    akamai_api eccu publish_xml path/to/request.xml john.com  # Publish a request made in XML for the specified Digital Property (usually the Host Header)
    akamai_api eccu requests                                  # Print the list of the last requests made to ECCU
```

### Viewing Requests

You can see the requests published on ECCU using *akamai_api eccu requests*
For each request you will see all its details (code, status, etc.) except the file content.
To view the file content add the --content (-c) option.

To see only the last request you can use *akamai_api eccu last_request*.

### Publishing Requests in XML

To publish requests made in XML (ECCU Request Format) you can use *akamai_api eccu publish_xml*.

```
Usage:
  akamai_api publish_xml path/to/request.xml john.com

Options:
  -pt, [--property-type=type]             # Type of enlisted properties
                                          # Default: hostheader
      [--no-exact-match]                  # Do not do an exact match on property names
  -e, [--emails=foo@foo.com bar@bar.com]  # Email(s) to use to send notification on status change
  -n, [--notes=NOTES]
                                          # Default: ECCU Request using AkamaiApi gem
```

The command takes two arguments:
- the file containing the request;
- the Digital Property to which you want to apply the request (usually it's the host);

# As a Library

Remember to init the AkamaiApi gem with your login credentials. You can set your credentials with the following statement:

```ruby
AkamaiApi.config.merge! :auth => ['user', 'pass']
```

- CpCode: model representing a CP Code. Use the ::all method to retrieve the list of available CpCode.
- Ccu   : CCU interface. Use the ::purge method to purge a list of resources.
- EccuRequest: model representing an ECCU request.

## Ccu

### ::status

When no argument is given, this command will return a [`AkamaiApi::Ccu::Status::Response`](lib/akamai_api/ccu/status/response.rb) object describing the status of the Akamai CCU queue. E.g.

```ruby
AkamaiApi::Ccu.status
# => #<AkamaiApi::Ccu::Status::Response:0x00000101167978 @raw={"supportId"=>"12345678901234567890-123456789", "httpStatus"=>200, "detail"=>"The queue may take a minute to reflect new or removed requests.", "queueLength"=>0}>
```

When you pass a `progress_uri` or a `purge_id`, this command will check the given Akamai CCU request. E.g.

```ruby
AkamaiApi::Ccu.status '/ccu/v2/purges/foobarbaz' # you can pass only 'foobarbaz' (the purge request id) as argument
# => #<AkamaiApi::Ccu::PurgeStatus::SuccessfulResponse:0x000001014da088
#  @raw=
#   {"originalEstimatedSeconds"=>480,
#    "progressUri"=>"/ccu/v2/purges/12345678-1234-5678-1234-123456789012",
#    "originalQueueLength"=>6,
#    "purgeId"=>"12345678-1234-5678-1234-123456789012",
#    "supportId"=>"12345678901234567890-123456789",
#    "httpStatus"=>200,
#    "completionTime"=>"2014-02-19T22:16:20Z",
#    "submittedBy"=>"test1",
#    "purgeStatus"=>"In-Progress",
#    "submissionTime"=>"2014-02-19T21:16:20Z",
#    "pingAfterSeconds"=>60}>
```

It will return a [`AkamaiApi::Ccu::PurgeStatus::SuccessfulResponse`](lib/akamai_api/ccu/purge_status/successful_response.rb) object when a purge request is found, or a [`Akamai::Ccu::PurgeStatus::NotFoundResponse`](lib/akamai_api/ccu/purge_status/not_found_response.rb) when no request can be found.

### ::purge

```ruby
module AkamaiApi::Ccu
  def purge action, type, items, args = {}
    ...
  end
end
```

- `action`: symbol or string. It should be *remove* or *invalidate*. See the CLI documentation for more details
- `type`: symbol or string. It should be *arl* or *cpcode*. Use arl to purge a list of urls, and cpcodes to purge a list of cp codes
- `items`: the list of the resources to clean
- `args`: additional options (domain)

It will return a [`AkamaiApi::Ccu::Purge::Response`](lib/akamai_api/ccu/purge/response.rb) object that you can use to retrieve the `progress_uri` (or the `purge_id`) of the request.

E.g.

```ruby
AkamaiApi::Ccu.purge :remove, :arl, ['http://www.foo.com/a.txt'], :domain => 'staging'
# => #<AkamaiApi::Ccu::Purge::Response:0x00000101bf2848
#  @raw=
#   {"describedBy"=>"foo",
#    "title"=>"bar",
#    "pingAfterSeconds"=>100,
#    "purgeId"=>"1234",
#    "supportId"=>"130",
#    "detail"=>"baz",
#    "httpStatus"=>201,
#    "estimatedSeconds"=>90,
#    "progressUri"=>"/ccu/v2/purges/1234"}>
```

### Purge Helpers

```ruby
ccu = AkamaiApi::Ccu

ccu.invalidate_cpcode cpcodes    # => wrapper to call .purge :invalidate, :cpcode
ccu.invalidate_arl arls          # => wrapper to call .purge :invalidate, :arl
ccu.invalidate :arl, arls        # => wrapper to call .purge :invalidate

ccu.remove_cpcodes cpcodes   # => wrapper to call .purge :remove, :cpcode
ccu.remove_arl arls          # => wrapper to call .purge :remove, :arl
ccu.remove :arl              # => wrapper to call .purge :remove
```

## EccuRequest

An EccuRequest is an object representing an ECCU Request. To see all the published requests use the `::all` method.
To retrieve only the last request, you can use the `::last` method.
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

Use the ::publish method to publish an ECCU Request:

```ruby
    AkamaiApi::EccuRequest.publish 'example.com', my_content, args
    AkamaiApi::EccuRequest.publish_file 'example.com', 'path/to/file.xml', args
```

You can specify the following optional arguments in args: file_name, notes, version, emails, property_type, property_exact_match

# Contributing

- Clone this repository
- Run 'bundle install'
- To run the specs, create the file spec/auth.rb with the following content:

   ```ruby
    # Fill the following with your akamai login before running your spec
    AkamaiApi.config.merge!({
      :auth => ['user', 'pass']
    })
  ```

- Run specs using `guard`. Alternatively you can execute the specs with `thor spec` and cucumber features with `cucumber`
