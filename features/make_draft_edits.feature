Feature: make draft edits
  As a content editor
  I should be able to save draft versions of pages
  In order to experiment and preview pages 
  before they go live
  
  Scenario: draft version of published
    Given I have a published page
    When I edit the page
    And I save it as a draft
    Then the page should be saved
    And not change the live version
    
  Scenario: draft version of draft
    Given I have a page with a draft
    When I edit the page
    And I save it as a draft
    Then the page should be saved
    And not change the live version