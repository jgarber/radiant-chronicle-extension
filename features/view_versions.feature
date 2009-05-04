Feature: view versions
  So I can understand a page's history
  As a content editor
  I should be able to see a timeline
  And view previous versions of pages
  
  Background:
    Given I am logged in as admin
  
  Scenario: view timeline when editing
    Given I have a page with more than one version
    When I edit the page
    Then I should see a timeline
    And the working version should have a chevron to indicate where I am
  
  Scenario: view timeline when viewing diff
    Given I have a page with more than one version
    When I view a version
    Then I should see a timeline
    And the diffed version should have a chevron to indicate where I am
    
    Scenario: click timeline to go to version diff
      Given I have a page with more than one version
      When I view a version
      And I click on a different version
      Then I should be taken to that version's diff
      And the diffed version should have a chevron to indicate where I am