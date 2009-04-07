Feature: make draft edits
  As a content editor
  I should be able to save draft versions of pages
  In order to experiment and preview pages 
  before they go live
  
  Background:
    Given I am logged in as admin
  
  Scenario: save draft version of a published page
    Given I have a published page
    When I edit the page
    And I save it as a draft
    Then the page should be saved
    And not change the live version
    
  Scenario: save draft version of first-version draft
    Given I have a draft page
    When I edit the page
    And I save it as a draft
    Then the page should be saved
    And not change the live version
    
  Scenario: edit page with draft
    Given I have a published page with a draft
    When I go to edit the page
    Then the content I am editing should be the draft
    
  Scenario: save draft version of page with draft
    Given I have a published page with a draft
    When I edit the page
    And I save it as a draft
    Then the page should be saved
    And not change the live version