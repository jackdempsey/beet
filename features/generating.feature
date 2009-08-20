Feature: Generating Projects
  In order to reduce the time needed to build new rails apps
  As a developer
  I want to generate apps with beet

  Scenario: Generating a rails app
    Given this will run in the projects tmp directory
    When I run local executable "beet" with arguments "-g rails_app"
    Then folder "rails_app" is created
    And "rails_app" should be a rails app
