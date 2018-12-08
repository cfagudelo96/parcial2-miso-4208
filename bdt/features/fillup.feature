Feature: Register fillup

  Scenario: I can register a valid fillup
    When I enter "5" into input field number 1
    And I enter "5" into "Gallons"
    And I enter "5" into "Odometer"
    And I press the "Save Fillup" button
    Then I should see "5,00 g"
