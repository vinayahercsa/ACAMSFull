public with sharing class MyExtension {

Contact_Center_Scorecard__c request;
private ApexPages.StandardController controller;
public MyExtension(ApexPages.StandardController controller) {
this.controller = controller;
}

public PageReference saveAndredirectcase() {
  if(controller.save() != null) {
    PageReference caseformPage = Page.CCS_scorecard_view_mode_case;
    caseformPage.setRedirect(true);
    caseformPage.getParameters().put('id',controller.getId());
    return caseformPage;
  }  return null;
}

public PageReference recalculatecase() {
  if(controller.edit() != null) {
    PageReference recalculatecasePage = Page.CCS_scorecard_form_case;
    recalculatecasePage.setRedirect(true);
    recalculatecasePage.getParameters().put('id',controller.getId());
    return recalculatecasePage;
  }  return null;
}

public PageReference saveAndredirectphone() {
  if(controller.save() != null) {
    PageReference phoneformPage = Page.CCS_scorecard_view_mode_phone;
    phoneformPage.setRedirect(true);
    phoneformPage.getParameters().put('id',controller.getId());
    return phoneformPage;
  }  return null;
}

public PageReference recalculatephone() {
  if(controller.edit() != null) {
    PageReference recalculatephonePage = Page.CCS_scorecard_form_phone;
    recalculatephonePage.setRedirect(true);
    recalculatephonePage.getParameters().put('id',controller.getId());
    return recalculatephonePage;
  }  return null;
}

}