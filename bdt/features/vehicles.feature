Feature: Vehicles
  
  Scenario: I can enter the vehicles tab
    When I touch the "Vehicles" text
    And I take a screenshot with filename "screenshot_tab_vehicles"
    Then I should see text containing "Default vehicle"