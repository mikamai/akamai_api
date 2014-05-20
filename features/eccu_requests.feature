Feature: akamai_api eccu requests
  In order to get the list of the last requests made through ECCU
  As a CLI user

  @vcr
  Scenario: invalid credentials
    When I run `akamai_api eccu requests -u foo -p bar`
    Then the output should contain:
      """
      Your login credentials are invalid.
      """

  @vcr
  Scenario: valid credentials
    When I run `akamai_api eccu requests`
    Then the output should contain 4 times:
      """
      * Status
      """
    Then the output should contain:
      """
      * Code    : 112714868
      """
    And the output should contain 4 times:
      """
      * Status  : 4000 - File successfully deployed to Akamai network (Succeeded)
      """
    And the output should contain 3 times:
      """
      * Property: foo.com (hostheader)
      """
    And the output should contain 4 times:
      """
      with exact match
      """
    And the output should contain 4 times:
      """
      * Notes   : ECCU Request using EdgeControl
      """
    And the output should contain 4 times:
      """
      * Email   : guest@mikamai.com
      """