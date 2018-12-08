Feature: Register fillup

  Scenario: I can register a valid fillup
    When I enter "5" into input field number 1
    And I take a screenshot with filename "screenshot_fillup1"
    And I enter "5" into input field number 2
    And I take a screenshot with filename "screenshot_fillup2"
    And I enter "5" into input field number 3
    And I take a screenshot with filename "screenshot_fillup3"
    And I press the "Save Fillup" button
    And I take a screenshot with filename "screenshot_fillup4"
    Then I should see "5,00 g"
