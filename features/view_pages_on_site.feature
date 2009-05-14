Feature: view pages on site
  So that I can check my work
  As a content editor
  I want to easily view the page 
  on the live or dev sites
  
  Background:
    Given I am logged in as admin
    
  Scenario: click on a live marker
    Given I am looking at a timeline that has a live marker
    When I click the live marker
    Then I should be taken to the page in live mode

  Scenario: click on a dev marker
    Given I am looking at a timeline that has a dev marker
    When I click the dev marker
    Then I should be taken to the page in dev mode

  Scenario: click on a live+dev marker
    Given I am looking at a timeline that has a dev-and-live marker
    When I click the dev-and-live marker
    Then I should be taken to the page in dev mode
  
  Scenario: check the 'view page after saving' checkbox
    Given I am editing a published page
    And I changed the status to Draft
    When I check "View page after saving"
    And I press "Save and Continue Editing"
    Then the page should open on the dev site