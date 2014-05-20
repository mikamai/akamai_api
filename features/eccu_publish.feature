Feature: akamai_api eccu publish
  In order to publish a purge request via ECCU
  As a CLI user

  @vcr
  Scenario: invalid credentials
    Given a file named "publish.xml" with:
      """
      <?xml version="1.0"?>
      <eccu>
        <match:recursive-dirs value="foo" >
          <match:recursive-dirs value="bar" >
            <match:recursive-dirs value="baz.jpg" >
              <revalidate>now</revalidate>
            </match:recursive-dirs>
          </match:recursive-dirs>
        </match:recursive-dirs>
      </eccu>
      """
    When I run `akamai_api eccu publish_xml ./publish.xml foo.com -u foo -p bar`
    Then the output should contain:
      """
      Your login credentials are invalid.
      """

  @vcr
  Scenario: invalid domain
    Given a file named "publish.xml" with:
      """
      <?xml version="1.0"?>
      <eccu>
        <match:recursive-dirs value="foo" >
          <match:recursive-dirs value="bar" >
            <match:recursive-dirs value="baz.jpg" >
              <revalidate>now</revalidate>
            </match:recursive-dirs>
          </match:recursive-dirs>
        </match:recursive-dirs>
      </eccu>
      """
    When I run `akamai_api eccu publish_xml ./publish.xml john.smith.com`
    Then the output should contain:
      """
      ECCU validation failed: You are not authorized to specify this digital property
      """

  @vcr
  Scenario: successful
    Given a file named "publish.xml" with:
      """
      <?xml version="1.0"?>
      <eccu>
        <match:recursive-dirs value="foo" >
          <match:recursive-dirs value="bar" >
            <match:recursive-dirs value="baz.jpg" >
              <revalidate>now</revalidate>
            </match:recursive-dirs>
          </match:recursive-dirs>
        </match:recursive-dirs>
      </eccu>
      """
    When I run `akamai_api eccu publish_xml ./publish.xml foo.com`
    Then the output should contain:
      """
      Request correctly published
      """
    And the output should contain:
      """
      * Code    : 116073578
      """
    And the output should contain:
      """
      * Status  : 1000
      """
    And the output should contain:
      """
      2014-05-20T16:49:29.026Z
      """
    And the output should contain:
      """
      * Property: www.foo.com (hostheader)
      """
    And the output should contain:
      """
      with exact match
      """
    And the output should contain:
      """
      * Notes   : ECCU Request using AkamaiApi gem
      """
    And the output should contain:
      """
      * Uploaded by test1 on 2014-05-20T16:49:29.026Z
      """
    And the output should contain:
      """
      Content:
      """