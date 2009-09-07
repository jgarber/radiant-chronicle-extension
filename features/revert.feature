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
    And the older page content should be loaded
    And I should see "Loaded version 1. Click save to revert to this content."
  
  Scenario: revert page to previous version
    Given I have a page with more than one version
    When I edit a previous page version
    And I press "Save"
    Then I should see "Your page has been saved"
  
  Scenario: load previous snippet version for editing
    Given I have a snippet with more than one version
    When I view a previous version
    And I click the revert button
    Then I should be taken to the edit page
    And the older snippet content should be loaded
    And I should see "Loaded version 1. Click save to revert to this content."
  
  Scenario: revert snippet to previous version
    Given I have a snippet with more than one version
    When I edit a previous snippet version
    And I press "Save"
    Then I should see "Snippet saved below"
  
  Scenario: load previous layout version for editing
    Given I have a layout with more than one version
    When I view a previous version
    And I click the revert button
    Then I should be taken to the edit page
    And the older layout content should be loaded
    And I should see "Loaded version 1. Click save to revert to this content."

  Scenario: revert layout to previous version
    Given I have a layout with more than one version
    When I edit a previous layout version
    And I press "Save"
    Then I should see "Layout saved below"