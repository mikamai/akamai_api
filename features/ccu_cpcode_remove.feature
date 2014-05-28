Feature: akamai_api ccu cpcode remove
  In order to remove CPCodes
  As a CLI user

  @vcr
  Scenario: invalid credentials
    When I run `akamai_api ccu cpcode remove 12345 -u foo -p bar`
    Then the output should contain:
      """
      Your login credentials are invalid.
      """

  @vcr
  Scenario: invalid item
    When I run `akamai_api ccu cpcode remove 12345`
    Then the output should contain:
      """
      Error 403: 'unauthorized cpcode' (12345)
      """
    And the output should contain:
      """
      Described by: https://api.ccu.akamai.com/ccu/v2/errors/unauthorized-cpcode
      """

  @vcr
  Scenario: single item
    When I run `akamai_api ccu cpcode remove 12345`
    Then the output should contain:
      """
      Purge request successfully submitted:
      """
    And the output should contain:
      """
      * Result: 201 - Request accepted.
      """
    And the output should contain:
      """
      * Purge ID: 12345678-1234-1234-1234-123456789012 | Support ID: 12345678901234567890-123456789
      """
    And the output should contain:
      """
      * Estimated time: 420 secs.
      """
    And the output should contain:
      """
      * Progress URI: /ccu/v2/purges/12345678-1234-5678-1234-123456789012
      """
    And the output should contain:
      """
      * Time to wait before check: 420 secs.
      """

  @vcr
  Scenario: multiple items
    When I run `akamai_api ccu cpcode remove 12345 12346`
    Then the output should contain:
      """
      Purge request successfully submitted:
      """
    And the output should contain:
      """
      * Result: 201 - Request accepted.
      """
    And the output should contain:
      """
      * Purge ID: 12345678-1234-1234-1234-123456789012 | Support ID: 12345678901234567890-123456789
      """
    And the output should contain:
      """
      * Estimated time: 420 secs.
      """
    And the output should contain:
      """
      * Progress URI: /ccu/v2/purges/12345678-1234-5678-1234-123456789012
      """
    And the output should contain:
      """
      * Time to wait before check: 420 secs.
      """