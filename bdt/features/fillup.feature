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
    Then I should see text containing "5"
    
  Scenario: I can not register a fillup without Gallons
    When I enter "5" into input field number 1
    And I press the "Save Fillup" button
    And I take a screenshot with filename "screenshot_withoutgallons_fillup"
    Then I should see text containing "Invalid value for volume"

  Scenario: I can not register a fillup without Price per Gallons
    When I enter "5" into input field number 2
    And I press the "Save Fillup" button
    And I take a screenshot with filename "screenshot_withoutprice_fillup"
    Then I should see text containing "Invalid value for price"

  Scenario: I can not register a fillup without Odometer
    When I enter "5" into input field number 1
    And I enter "5" into input field number 2
    And I press the "Save Fillup" button
    And I take a screenshot with filename "screenshot_withoutodometer_fillup"
    Then I should see text containing "Invalid value for odometer"

  Scenario: I can register a fillup with a comment
    When I enter "5" into input field number 1
    And I enter "5" into input field number 2
    And I enter "5" into input field number 3
    And I enter "Test" into input field number 4
    And I take a screenshot with filename "screenshot_comment_fillup"
    And I press the "Save Fillup" button
    Then I should see text containing "5"

  Scenario: I can indicate that Tank was not filled to the top
    When I enter "5" into input field number 1
    And I enter "5" into input field number 2
    And I enter "5" into input field number 3
    And I toggle checkbox number 1
    And I take a screenshot with filename "screenshot_toggle_fillup"
    And I press the "Save Fillup" button
    Then I should see text containing "5"