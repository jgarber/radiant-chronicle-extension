Feature: revert
  So I can correct mistakes
  As a content editor
  I should be able to revert to a previous version
  
  Background:
    Given I am logged in as admin
  
  Scenario: load previous page version for editing
    Given I have a page with more than one version
    When I view a previous version
    And I click the revert button
    Then I should be taken to the edit page
    And the older content should be loaded
    And I should see "Loaded version 1. Click save to revert to this content."
  
  Scenario: revert page to previous version
    Given I have a page with more than one version
    When I edit a previous version
    And I press "Save"
    Then I should see "Your page has been saved"