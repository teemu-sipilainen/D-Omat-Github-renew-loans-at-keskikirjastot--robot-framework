
*** Settings ***
Documentation     Renew Loans at Keskikirjastot
Library           Browser
Resource          utils${/}browser_management.resource
Resource          pages${/}front_page.resource
Resource          pages${/}login_page.resource
Resource          pages${/}header.resource
Resource          pages${/}my_research_page.resource
Suite Setup       Open Browser And Login
Suite Teardown    Close Browser

*** Variables ***
${url}              https://keski.finna.fi/

*** Tasks ***
Renew Loans
    front_page.Click Login Button
    login_page.Fill Login Form And Submit
    my_research_page.Renew Loans

*** Keywords ***
Open Browser And Login
    browser_management.Setup Browser    url=${url}    headless=False

Close Browser
    Browser.Close Browser