Feature: Generating Projects
  In order to reduce the time needed to build new rails apps
  As a developer
  I want to generate apps with beet

  Background:
    Given this will run inside a clean "generated_output" directory

  Scenario: Generating a rails app
    When I run local executable "beet" with arguments "-g rails_app"
    Then folder "rails_app" is created
    And "rails_app" should be a rails app

  Scenario: Generating a rails app with rails/git recipe
    When I run local executable "beet" with arguments "-g rails_app -r rails/git"
    Then folder "rails_app" is created
    And "rails_app" should be a rails app
    And folder "rails_app/.git" is created

  Scenario: Generating a rails app then running rails/git recipe separately
    When I run local executable "beet" with arguments "-g rails_app"
    And inside "rails_app" I run local executable "beet" with arguments "-j -r rails/git"
    And folder "rails_app/.git" is created"

