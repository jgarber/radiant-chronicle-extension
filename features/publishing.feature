Feature: publishing
  As a content editor
  I should be able to publish pages
  So that the most current content
  is visible to the world
  
  Scenario: publishing a published page
    Given I have a published page
    When I edit the page
    And I save it as published
    Then the page should be saved
    And change the live version
  
  Scenario: publishing a draft page
    Given I have a page with a draft
    When I edit the page
    And I save it as published
    Then the page should be saved
    And change the live version
    