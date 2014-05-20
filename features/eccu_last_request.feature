Feature: akamai_api eccu last_request
  In order to get the last request made through ECCU
  As a CLI user

  @vcr
  Scenario: invalid credentials
    When I run `akamai_api eccu last_request -u foo -p bar`
    Then the output should contain:
      """
      Your login credentials are invalid.
      """

  @vcr
  Scenario: valid credentials
    When I run `akamai_api eccu last_request`
    Then the output should contain:
      """
      * Code    : 115942214\n
      """
    And the output should contain:
      """
      * Status  : 4000 - File successfully deployed to Akamai network (Succeeded)
      """
    And the output should contain:
      """
      2014-05-19T16:27:34.512Z
      """
    And the output should contain:
      """
      * Property: foo.com (hostheader)
      """
    And the output should contain:
      """
      with exact match
      """
    And the output should contain:
      """
      * Notes   : ECCU Request using EdgeControl
      """
    And the output should contain:
      """
      * Email   : guest@mikamai.com
      """
    And the output should contain:
      """
      * Uploaded by test1 on 2014-05-19T15:30:13.512Z
      """