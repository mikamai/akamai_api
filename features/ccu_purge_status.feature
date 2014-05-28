Feature: akamai_api ccu purge status
  In order to get the status of an Akamai CCU request
  As a CLI user

  @vcr
  Scenario: invalid credentials
    When I run `akamai_api ccu status 12345678-1234-5678-1234-123456789012 -u foo -p bar`
    Then the output should contain:
      """
      Your login credentials are invalid.
      """

  @vcr
  Scenario: completed request
    When I run `akamai_api ccu status /ccu/v2/purges/12345678-1234-5678-1234-123456789012`
    Then the output should contain:
      """
      Purge request has been successfully completed:
      """
    And the output should contain:
      """
      * Result: 200 - Done
      """
    And the output should contain:
      """
      * Purge ID: 12345678-1234-5678-1234-123456789012 | Support ID: 12345678901234567890-123456789
      """
    And the output should contain:
      """
      * Submitted by: test1 on 2014-05-20 08:19:21 UTC
      """
    And the output should contain:
      """
      * Completed on: 2014-05-20 08:22:20 UTC
      """

  @vcr
  Scenario: enqueued request
    When I run `akamai_api ccu status ccu/v2/purges/12345678-1234-5678-1234-123456789012`
    Then the output should contain:
      """
      Purge request is currently enqueued:
      """
    And the output should contain:
      """
      Result: 200 - In-Progress
      """
    And the output should contain:
      """
      * Purge ID: 12345678-1234-5678-1234-123456789012 | Support ID: 12345678901234567890-123456789
      """
    And the output should contain:
      """
      * Submitted by: test1 on 2014-05-20 08:19:21 UTC
      """
    And the output should contain:
      """
      * Time to wait before next check: 60 secs.
      """
    And the output should not contain:
      """
      * Completed on
      """

  @vcr
  Scenario: not found request
    When I run `akamai_api ccu status foobarbaz`
    Then the output should contain:
      """
      No purge request found
      """
    And the output should contain:
      """
      Result: 200 - Please note that it can take up to a minute for the status of a recently submitted request to become visible.
      """
    And the output should contain:
      """
      * Support ID: 12345678901234567890-123456789
      """
    And the output should contain:
      """
      * Time to wait before next check: 60 secs.
      """