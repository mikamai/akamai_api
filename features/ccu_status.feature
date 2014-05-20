Feature: akamai_api ccu status
  In order to get the Akamai CCU queue status
  As a CLI user

  @vcr
  Scenario: invalid credentials
    When I run `akamai_api ccu status -u foo -p bar`
    Then the output should contain:
      """
      Your login credentials are invalid.
      """

  @vcr
  Scenario: valid credentials
    When I run `akamai_api ccu status`
    Then the output should contain:
      """
      Akamai CCU Queue Status
      """
    And the output should contain:
      """
      * Result: 200 - The queue may take a minute to reflect new or removed requests.
      """
    And the output should contain:
      """
      * Support ID: 12345678901234567890-123456789
      """
    And the output should contain:
      """
      * Queue Length: 0
      """