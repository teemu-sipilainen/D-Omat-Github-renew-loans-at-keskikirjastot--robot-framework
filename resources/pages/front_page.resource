*** Settings ***
Library      Browser
Variables    locators${/}front_page.yaml

*** Keywords ***
Click Login Button
    Wait For Elements State    ${front_page_login_button}    visible    
    Click    ${front_page_login_button}
    
    # TOIMII
    # Click    css=#loginOptions a